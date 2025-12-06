"""
Modèle User pour la table des utilisateurs
"""
from dataclasses import dataclass
from typing import Optional
from datetime import datetime


@dataclass
class User:
    """Modèle représentant un utilisateur dans le système"""
    
    id_user: Optional[int] = None
    nom: str = ""
    email: str = ""
    password: str = ""
    date_creation: Optional[datetime] = None
    
    def to_dict(self, include_password: bool = False) -> dict:
        """Convertir l'utilisateur en dictionnaire"""
        user_dict = {
            'id_user': self.id_user,
            'nom': self.nom,
            'email': self.email,
            'date_creation': self.date_creation.isoformat() if self.date_creation else None
        }
        
        if include_password:
            user_dict['password'] = self.password
        
        return user_dict
    
    @classmethod
    def from_dict(cls, data: dict) -> 'User':
        """Créer un utilisateur à partir d'un dictionnaire"""
        return cls(
            id_user=data.get('id_user'),
            nom=data.get('nom', ''),
            email=data.get('email', ''),
            password=data.get('password', ''),
            date_creation=data.get('date_creation')
        )
    
    def __repr__(self) -> str:
        return f"User(id_user={self.id_user}, nom={self.nom}, email={self.email})"
