"""
Service de gestion de l'inscription (register)
"""
import bcrypt
import re
from typing import Optional, Tuple
from datetime import datetime
import sys
import os

# Ajouter le chemin parent pour les imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from repository.data_source.database_config import DatabaseConnection
from models.user_model import User


class RegisterService:
    """Service pour gérer l'inscription des utilisateurs"""
    
    @staticmethod
    def register_user(nom: str, email: str, password: str) -> Tuple[bool, Optional[User], str]:
        """
        Créer un nouveau compte utilisateur
        
        Args:
            nom: Nom complet de l'utilisateur
            email: Email de l'utilisateur
            password: Mot de passe en clair
            
        Returns:
            Tuple (success, user, message)
        """
        try:
            # Validation des entrées
            is_valid, validation_message = RegisterService._validate_registration_data(
                nom, email, password
            )
            if not is_valid:
                return False, None, validation_message
            
            # Vérifier si l'email existe déjà
            if RegisterService._email_exists(email):
                return False, None, "Cet email est déjà utilisé"
            
            # Hasher le mot de passe
            password_hash = RegisterService._hash_password(password)
            
            # Créer l'utilisateur
            user = User(
                nom=nom,
                email=email,
                password=password_hash,
                date_creation=datetime.now()
            )
            
            # Insérer l'utilisateur dans la base de données
            user_id = RegisterService._insert_user(user)
            
            if user_id:
                user.id_user = user_id
                return True, user, "Inscription réussie"
            else:
                return False, None, "Erreur lors de la création du compte"
            
        except Exception as e:
            print(f"Erreur lors de l'inscription: {e}")
            return False, None, "Erreur lors de l'inscription"
    
    @staticmethod
    def _validate_registration_data(nom: str, email: str, password: str) -> Tuple[bool, str]:
        """Valider les données d'inscription"""
        # Vérifier que tous les champs obligatoires sont remplis
        if not nom or not email or not password:
            return False, "Tous les champs sont requis"
        
        # Valider la longueur du nom
        if len(nom) < 2:
            return False, "Le nom doit contenir au moins 2 caractères"
        
        if len(nom) > 100:
            return False, "Le nom ne peut pas dépasser 100 caractères"
        
        # Valider le format de l'email
        email_pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(email_pattern, email):
            return False, "Format d'email invalide"
        
        # Valider le mot de passe
        if len(password) < 8:
            return False, "Le mot de passe doit contenir au moins 8 caractères"
        
        # Vérifier la complexité du mot de passe (au moins une majuscule, une minuscule, un chiffre)
        if not re.search(r'[A-Z]', password):
            return False, "Le mot de passe doit contenir au moins une majuscule"
        
        if not re.search(r'[a-z]', password):
            return False, "Le mot de passe doit contenir au moins une minuscule"
        
        if not re.search(r'[0-9]', password):
            return False, "Le mot de passe doit contenir au moins un chiffre"
        
        return True, "Validation réussie"
    
    @staticmethod
    def _email_exists(email: str) -> bool:
        """Vérifier si l'email existe déjà"""
        try:
            with DatabaseConnection(commit=False) as cursor:
                query = "SELECT COUNT(*) as count FROM users WHERE email = %s"
                cursor.execute(query, (email,))
                result = cursor.fetchone()
                return result['count'] > 0
                
        except Exception as e:
            print(f"Erreur lors de la vérification de l'email: {e}")
            return True  # En cas d'erreur, on considère que l'email existe pour éviter les doublons
    
    @staticmethod
    def _hash_password(password: str) -> str:
        """Hasher le mot de passe avec bcrypt"""
        salt = bcrypt.gensalt()
        hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
        return hashed.decode('utf-8')
    
    @staticmethod
    def _insert_user(user: User) -> Optional[int]:
        """Insérer un nouvel utilisateur dans la base de données"""
        try:
            with DatabaseConnection(commit=True) as cursor:
                query = """
                    INSERT INTO users (nom, email, password, date_creation)
                    VALUES (%s, %s, %s, %s)
                    RETURNING id_user
                """
                cursor.execute(query, (
                    user.nom,
                    user.email,
                    user.password,
                    user.date_creation
                ))
                
                result = cursor.fetchone()
                return result['id_user'] if result else None
                
        except Exception as e:
            print(f"Erreur lors de l'insertion de l'utilisateur: {e}")
            return None
