"""
Service de gestion de la réinitialisation de mot de passe (forgot password)
"""
import bcrypt
import secrets
from typing import Optional, Tuple
from datetime import datetime, timedelta
import sys
import os

# Ajouter le chemin parent pour les imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from repository.data_source.database_config import DatabaseConnection
from models.user_model import User
from models.password_reset_model import PasswordReset


class ForgotPasswordService:
    """Service pour gérer la réinitialisation de mot de passe"""
    
    # Durée de validité du token (en heures)
    TOKEN_EXPIRY_HOURS = 24
    
    @staticmethod
    def request_password_reset(email: str) -> Tuple[bool, Optional[str], str]:
        """
        Créer une demande de réinitialisation de mot de passe
        
        Args:
            email: Email de l'utilisateur
            
        Returns:
            Tuple (success, token, message)
        """
        try:
            # Vérifier que l'email est fourni
            if not email:
                return False, None, "Email requis"
            
            # Récupérer l'utilisateur
            user = ForgotPasswordService._get_user_by_email(email)
            
            if not user:
                # Modifié pour afficher explicitement "Email inexistant" à la demande de l'utilisateur
                return False, None, "Email inexistant"
            
            # Invalider tous les anciens tokens pour cet utilisateur
            ForgotPasswordService._invalidate_old_tokens(user.id_user)
            
            # Générer un nouveau token
            token = ForgotPasswordService._generate_token()
            
            # Calculer la date d'expiration
            expires_at = datetime.now() + timedelta(hours=ForgotPasswordService.TOKEN_EXPIRY_HOURS)
            
            # Créer l'enregistrement de réinitialisation
            reset = PasswordReset(
                user_id=user.id_user,
                token=token,
                is_used=False,
                expires_at=expires_at,
                created_at=datetime.now()
            )
            
            # Sauvegarder dans la base de données
            success = ForgotPasswordService._save_reset_token(reset)
            
            if success:
                # Dans une application réelle, vous enverriez un email ici
                return True, token, "Token de réinitialisation créé avec succès"
            else:
                return False, None, "Erreur lors de la création du token"
            
        except Exception as e:
            print(f"Erreur lors de la demande de réinitialisation: {e}")
            return False, None, "Erreur lors de la demande de réinitialisation"
    
    @staticmethod
    def reset_password(token: str, new_password: str) -> Tuple[bool, str]:
        """
        Réinitialiser le mot de passe avec un token
        
        Args:
            token: Token de réinitialisation
            new_password: Nouveau mot de passe
            
        Returns:
            Tuple (success, message)
        """
        try:
            # Valider les entrées
            if not token or not new_password:
                return False, "Token et nouveau mot de passe requis"
            
            # Valider le mot de passe
            is_valid, validation_message = ForgotPasswordService._validate_password(new_password)
            if not is_valid:
                return False, validation_message
            
            # Récupérer le token de réinitialisation
            reset = ForgotPasswordService._get_reset_by_token(token)
            
            if not reset:
                return False, "Token invalide ou expiré"
            
            # Vérifier si le token est valide
            if not reset.is_valid():
                return False, "Token invalide ou expiré"
            
            # Récupérer l'utilisateur pour vérifier l'ancien mot de passe
            user = ForgotPasswordService._get_user_by_id(reset.user_id)
            if not user:
                return False, "Utilisateur introuvable"
            
            # Vérifier si le nouveau mot de passe est identique à l'ancien
            if bcrypt.checkpw(new_password.encode('utf-8'), user.password.encode('utf-8')):
                return False, "Veuillez saisir un mot de passe différent de l'ancien."

            # Hasher le nouveau mot de passe
            password_hash = ForgotPasswordService._hash_password(new_password)
            
            # Mettre à jour le mot de passe de l'utilisateur
            success = ForgotPasswordService._update_user_password(reset.user_id, password_hash)
            
            if success:
                # Marquer le token comme utilisé
                ForgotPasswordService._mark_token_as_used(reset.id)
                return True, "Mot de passe réinitialisé avec succès"
            else:
                return False, "Erreur lors de la réinitialisation du mot de passe"
            
        except Exception as e:
            print(f"Erreur lors de la réinitialisation: {e}")
            return False, "Erreur lors de la réinitialisation"
    
    @staticmethod
    def verify_token(token: str) -> Tuple[bool, str]:
        """
        Vérifier si un token est valide
        
        Args:
            token: Token à vérifier
            
        Returns:
            Tuple (is_valid, message)
        """
        try:
            reset = ForgotPasswordService._get_reset_by_token(token)
            
            if not reset:
                return False, "Token invalide"
            
            if reset.is_valid():
                return True, "Token valide"
            else:
                return False, "Token expiré ou déjà utilisé"
            
        except Exception as e:
            print(f"Erreur lors de la vérification du token: {e}")
            return False, "Erreur lors de la vérification"
    
    @staticmethod
    def _get_user_by_email(email: str) -> Optional[User]:
        """Récupérer un utilisateur par son email"""
        try:
            with DatabaseConnection(commit=False) as cursor:
                query = """
                    SELECT id_user, nom, email, password, date_creation
                    FROM users
                    WHERE email = %s
                """
                cursor.execute(query, (email,))
                result = cursor.fetchone()
                
                if result:
                    return User.from_dict(dict(result))
                return None
                
        except Exception as e:
            print(f"Erreur lors de la récupération de l'utilisateur: {e}")
            return None

    @staticmethod
    def _get_user_by_id(user_id: int) -> Optional[User]:
        """Récupérer un utilisateur par son ID"""
        try:
            with DatabaseConnection(commit=False) as cursor:
                query = """
                    SELECT id_user, nom, email, password, date_creation
                    FROM users
                    WHERE id_user = %s
                """
                cursor.execute(query, (user_id,))
                result = cursor.fetchone()
                
                if result:
                    return User.from_dict(dict(result))
                return None
        except Exception as e:
            print(f"Erreur lors de la récupération de l'utilisateur par ID: {e}")
            return None
    
    @staticmethod
    def _generate_token() -> str:
        """Générer un token sécurisé"""
        return secrets.token_urlsafe(32)
    
    @staticmethod
    def _invalidate_old_tokens(user_id: int) -> bool:
        """Invalider tous les anciens tokens d'un utilisateur"""
        try:
            with DatabaseConnection(commit=True) as cursor:
                query = """
                    UPDATE password_resets
                    SET is_used = TRUE
                    WHERE user_id = %s AND is_used = FALSE
                """
                cursor.execute(query, (user_id,))
                return True
                
        except Exception as e:
            print(f"Erreur lors de l'invalidation des tokens: {e}")
            return False
    
    @staticmethod
    def _save_reset_token(reset: PasswordReset) -> bool:
        """Sauvegarder un token de réinitialisation"""
        try:
            with DatabaseConnection(commit=True) as cursor:
                query = """
                    INSERT INTO password_resets (user_id, token, is_used, expires_at, created_at)
                    VALUES (%s, %s, %s, %s, %s)
                    RETURNING id
                """
                cursor.execute(query, (
                    reset.user_id,
                    reset.token,
                    reset.is_used,
                    reset.expires_at,
                    reset.created_at
                ))
                
                result = cursor.fetchone()
                return result is not None
                
        except Exception as e:
            print(f"Erreur lors de la sauvegarde du token: {e}")
            return False
    
    @staticmethod
    def _get_reset_by_token(token: str) -> Optional[PasswordReset]:
        """Récupérer un token de réinitialisation"""
        try:
            with DatabaseConnection(commit=False) as cursor:
                query = """
                    SELECT id, user_id, token, is_used, expires_at, created_at
                    FROM password_resets
                    WHERE token = %s
                """
                cursor.execute(query, (token,))
                result = cursor.fetchone()
                
                if result:
                    return PasswordReset.from_dict(dict(result))
                return None
                
        except Exception as e:
            print(f"Erreur lors de la récupération du token: {e}")
            return None
    
    @staticmethod
    def _validate_password(password: str) -> Tuple[bool, str]:
        """Valider un mot de passe"""
        import re
        
        if len(password) < 8:
            return False, "Le mot de passe doit contenir au moins 8 caractères"
        
        if not re.search(r'[A-Z]', password):
            return False, "Le mot de passe doit contenir au moins une majuscule"
        
        if not re.search(r'[a-z]', password):
            return False, "Le mot de passe doit contenir au moins une minuscule"
        
        if not re.search(r'[0-9]', password):
            return False, "Le mot de passe doit contenir au moins un chiffre"
        
        return True, "Mot de passe valide"
    
    @staticmethod
    def _hash_password(password: str) -> str:
        """Hasher le mot de passe"""
        salt = bcrypt.gensalt()
        hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
        return hashed.decode('utf-8')
    
    @staticmethod
    def _update_user_password(user_id: int, password_hash: str) -> bool:
        """Mettre à jour le mot de passe d'un utilisateur"""
        try:
            with DatabaseConnection(commit=True) as cursor:
                query = """
                    UPDATE users
                    SET password = %s
                    WHERE id_user = %s
                """
                cursor.execute(query, (password_hash, user_id))
                return True
                
        except Exception as e:
            print(f"Erreur lors de la mise à jour du mot de passe: {e}")
            return False
    
    @staticmethod
    def _mark_token_as_used(reset_id: int) -> bool:
        """Marquer un token comme utilisé"""
        try:
            with DatabaseConnection(commit=True) as cursor:
                query = """
                    UPDATE password_resets
                    SET is_used = TRUE
                    WHERE id = %s
                """
                cursor.execute(query, (reset_id,))
                return True
                
        except Exception as e:
            print(f"Erreur lors du marquage du token: {e}")
            return False
