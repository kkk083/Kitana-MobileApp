"""
Service de gestion de la connexion (login)
"""
import bcrypt
from typing import Optional, Tuple
from datetime import datetime
import sys
import os

# Ajouter le chemin parent pour les imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from repository.data_source.database_config import DatabaseConnection
from models.user_model import User


class LoginService:
    """Service pour gérer l'authentification des utilisateurs"""
    
    @staticmethod
    def authenticate_user(email: str, password: str) -> Tuple[bool, Optional[User], str]:
        """
        Authentifier un utilisateur avec son email et mot de passe
        
        Args:
            email: Email de l'utilisateur
            password: Mot de passe en clair
            
        Returns:
            Tuple (success, user, message)
        """
        try:
            # Validation des entrées
            if not email or not password:
                return False, None, "Email et mot de passe requis"
            
            # Récupérer l'utilisateur depuis la base de données
            user = LoginService._get_user_by_email(email)
            
            if not user:
                return False, None, "Email ou mot de passe incorrect"
            
            # Vérifier le mot de passe
            if not LoginService._verify_password(password, user.password):
                return False, None, "Email ou mot de passe incorrect"
            
            return True, user, "Connexion réussie"
            
        except Exception as e:
            print(f"Erreur lors de l'authentification: {e}")
            return False, None, "Erreur lors de l'authentification"
    
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
    def _verify_password(plain_password: str, hashed_password: str) -> bool:
        """Vérifier si le mot de passe correspond au hash"""
        try:
            return bcrypt.checkpw(
                plain_password.encode('utf-8'),
                hashed_password.encode('utf-8')
            )
        except Exception as e:
            print(f"Erreur lors de la vérification du mot de passe: {e}")
            return False
    
    @staticmethod
    def get_user_by_id(user_id: int) -> Optional[User]:
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
            print(f"Erreur lors de la récupération de l'utilisateur: {e}")
            return None
