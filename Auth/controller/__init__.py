"""
Package controller
Contient les controllers (routes Flask) de l'application
"""

from .login_controller import login_bp
from .register_controller import register_bp
from .forgot_password_controller import forgot_password_bp

__all__ = ['login_bp', 'register_bp', 'forgot_password_bp']
