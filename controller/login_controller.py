"""
Controller pour la gestion de la connexion (login)
"""
from flask import Blueprint, request, jsonify
from functools import wraps
import jwt
import sys
import os
from datetime import datetime, timedelta

# Ajouter le chemin parent pour les imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from services.login_service import LoginService

# Créer un Blueprint pour les routes de connexion
login_bp = Blueprint('login', __name__, url_prefix='/api/auth')

# Clé secrète pour JWT (à mettre dans un fichier de configuration en production)
SECRET_KEY = os.getenv('JWT_SECRET_KEY', 'votre_cle_secrete_changez_moi_en_production')
JWT_EXPIRY_HOURS = 24


def generate_jwt_token(user_id: int, email: str) -> str:
    """Générer un token JWT pour l'utilisateur"""
    payload = {
        'user_id': user_id,
        'email': email,
        'exp': datetime.utcnow() + timedelta(hours=JWT_EXPIRY_HOURS),
        'iat': datetime.utcnow()
    }
    
    token = jwt.encode(payload, SECRET_KEY, algorithm='HS256')
    return token


def token_required(f):
    """Décorateur pour protéger les routes avec JWT"""
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        
        # Récupérer le token depuis les headers
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            try:
                token = auth_header.split(' ')[1]  # Format: "Bearer <token>"
            except IndexError:
                return jsonify({
                    'success': False,
                    'message': 'Format de token invalide'
                }), 401
        
        if not token:
            return jsonify({
                'success': False,
                'message': 'Token manquant'
            }), 401
        
        try:
            # Décoder le token
            payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
            current_user_id = payload['user_id']
            
            # Récupérer l'utilisateur
            user = LoginService.get_user_by_id(current_user_id)
            
            if not user:
                return jsonify({
                    'success': False,
                    'message': 'Utilisateur non trouvé'
                }), 401
            
        except jwt.ExpiredSignatureError:
            return jsonify({
                'success': False,
                'message': 'Token expiré'
            }), 401
        except jwt.InvalidTokenError:
            return jsonify({
                'success': False,
                'message': 'Token invalide'
            }), 401
        
        return f(current_user=user, *args, **kwargs)
    
    return decorated


@login_bp.route('/login', methods=['POST'])
def login():
    """
    Route de connexion
    
    Body (JSON):
        - email: str
        - password: str
        
    Returns:
        JSON avec success, message, token et user_data
    """
    try:
        # Récupérer les données de la requête
        data = request.get_json()
        
        if not data:
            return jsonify({
                'success': False,
                'message': 'Données manquantes'
            }), 400
        
        email = data.get('email', '').strip()
        password = data.get('password', '')
        
        # Authentifier l'utilisateur
        success, user, message = LoginService.authenticate_user(email, password)
        
        if success and user:
            # Générer le token JWT
            token = generate_jwt_token(user.id_user, user.email)
            
            return jsonify({
                'success': True,
                'message': message,
                'token': token,
                'user': user.to_dict(include_password=False)
            }), 200
        else:
            return jsonify({
                'success': False,
                'message': message
            }), 401
            
    except Exception as e:
        print(f"Erreur dans le controller login: {e}")
        return jsonify({
            'success': False,
            'message': 'Erreur serveur lors de la connexion'
        }), 500


@login_bp.route('/verify', methods=['GET'])
@token_required
def verify_token(current_user):
    """
    Route pour vérifier la validité d'un token
    
    Headers:
        - Authorization: Bearer <token>
        
    Returns:
        JSON avec success, message et user_data
    """
    try:
        return jsonify({
            'success': True,
            'message': 'Token valide',
            'user': current_user.to_dict(include_password=False)
        }), 200
        
    except Exception as e:
        print(f"Erreur dans le controller verify: {e}")
        return jsonify({
            'success': False,
            'message': 'Erreur serveur lors de la vérification'
        }), 500


@login_bp.route('/logout', methods=['POST'])
@token_required
def logout(current_user):
    """
    Route de déconnexion
    
    Headers:
        - Authorization: Bearer <token>
        
    Returns:
        JSON avec success et message
    """
    try:
        # Dans une implémentation JWT stateless, la déconnexion se fait côté client
        # En supprimant le token. Vous pouvez implémenter une liste noire de tokens
        # si nécessaire pour une sécurité accrue.
        
        return jsonify({
            'success': True,
            'message': 'Déconnexion réussie'
        }), 200
        
    except Exception as e:
        print(f"Erreur dans le controller logout: {e}")
        return jsonify({
            'success': False,
            'message': 'Erreur serveur lors de la déconnexion'
        }), 500


@login_bp.route('/profile', methods=['GET'])
@token_required
def get_profile(current_user):
    """
    Route pour récupérer le profil de l'utilisateur connecté
    
    Headers:
        - Authorization: Bearer <token>
        
    Returns:
        JSON avec success, message et user_data
    """
    try:
        return jsonify({
            'success': True,
            'message': 'Profil récupéré avec succès',
            'user': current_user.to_dict(include_password=False)
        }), 200
        
    except Exception as e:
        print(f"Erreur dans le controller profile: {e}")
        return jsonify({
            'success': False,
            'message': 'Erreur serveur lors de la récupération du profil'
        }), 500
