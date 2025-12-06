"""
Modèle PasswordReset pour la gestion des tokens de réinitialisation de mot de passe
"""
from dataclasses import dataclass
from typing import Optional
from datetime import datetime


@dataclass
class PasswordReset:
    """Modèle représentant un token de réinitialisation de mot de passe"""
    
    id: Optional[int] = None
    user_id: int = 0
    token: str = ""
    expires_at: Optional[datetime] = None
    is_used: bool = False
    created_at: Optional[datetime] = None
    
    def to_dict(self) -> dict:
        """Convertir le token en dictionnaire"""
        return {
            'id': self.id,
            'user_id': self.user_id,
            'token': self.token,
            'expires_at': self.expires_at.isoformat() if self.expires_at else None,
            'is_used': self.is_used,
            'created_at': self.created_at.isoformat() if self.created_at else None
        }
    
    @classmethod
    def from_dict(cls, data: dict) -> 'PasswordReset':
        """Créer un token à partir d'un dictionnaire"""
        return cls(
            id=data.get('id'),
            user_id=data.get('user_id', 0),
            token=data.get('token', ''),
            expires_at=data.get('expires_at'),
            is_used=data.get('is_used', False),
            created_at=data.get('created_at')
        )
    
    def is_valid(self) -> bool:
        """Vérifier si le token est toujours valide"""
        if self.is_used:
            return False
        
        if self.expires_at and datetime.now() > self.expires_at:
            return False
        
        return True
    
    def __repr__(self) -> str:
        return f"PasswordReset(id={self.id}, user_id={self.user_id}, is_used={self.is_used})"
