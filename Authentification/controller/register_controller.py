"""
Controller pour la gestion de l'inscription (register)
"""
from flask import Blueprint, request, jsonify
import sys
import os

# Ajouter le chemin parent pour les imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from services.register_service import RegisterService
from controller.login_controller import generate_jwt_token

# Créer un Blueprint pour les routes d'inscription
register_bp = Blueprint('register', __name__, url_prefix='/api/auth')


@register_bp.route('/register', methods=['POST'])
def register():
    """
    Route d'inscription
    
    Body (JSON):
        - nom: str (requis)
        - email: str (requis)
        - password: str (requis)
        - role: str (optionnel, default: 'etudiant')
        
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
        
        nom = data.get('nom', '').strip()
        email = data.get('email', '').strip()
        password = data.get('password', '')
        role = data.get('role', 'etudiant')
        
        # Créer le compte utilisateur
        success, user, message = RegisterService.register_user(
            nom=nom,
            email=email,
            password=password,
            role=role
        )
        
        if success and user:
            # Générer le token JWT pour connecter automatiquement l'utilisateur (ou pas, selon besoin)
            # Ici on le génère mais le frontend choisit de rediriger vers login
            token = generate_jwt_token(user.id_user, user.email)
            
            return jsonify({
                'success': True,
                'message': message,
                'token': token,
                'user': user.to_dict(include_password=False)
            }), 201  # 201 Created
        else:
            return jsonify({
                'success': False,
                'message': message
            }), 400  # 400 Bad Request
            
    except Exception as e:
        print(f"Erreur dans le controller register: {e}")
        return jsonify({
            'success': False,
            'message': 'Erreur serveur lors de l\'inscription'
        }), 500


@register_bp.route('/check-email', methods=['POST'])
def check_email():
    """
    Route pour vérifier si un email est disponible
    
    Body (JSON):
        - email: str
        
    Returns:
        JSON avec success, available et message
    """
    try:
        data = request.get_json()
        
        if not data or 'email' not in data:
            return jsonify({
                'success': False,
                'message': 'Email manquant'
            }), 400
        
        email = data.get('email', '').strip()
        
        # Vérifier si l'email existe
        email_exists = RegisterService._email_exists(email)
        
        return jsonify({
            'success': True,
            'available': not email_exists,
            'message': 'Email déjà utilisé' if email_exists else 'Email disponible'
        }), 200
        
    except Exception as e:
        print(f"Erreur dans le controller check_email: {e}")
        return jsonify({
            'success': False,
            'message': 'Erreur serveur lors de la vérification'
        }), 500
