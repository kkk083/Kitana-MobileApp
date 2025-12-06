"""
Controller pour la gestion de la réinitialisation de mot de passe (forgot password)
"""
from flask import Blueprint, request, jsonify
import sys
import os

# Ajouter le chemin parent pour les imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from services.forgot_password_service import ForgotPasswordService

# Créer un Blueprint pour les routes de réinitialisation de mot de passe
forgot_password_bp = Blueprint('forgot_password', __name__, url_prefix='/api/auth')


@forgot_password_bp.route('/forgot-password', methods=['POST'])
def request_password_reset():
    """
    Route pour demander une réinitialisation de mot de passe
    
    Body (JSON):
        - email: str
        
    Returns:
        JSON avec success, token (à des fins de test) et message
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
        
        # Créer une demande de réinitialisation
        success, token, message = ForgotPasswordService.request_password_reset(email)
        
        # Note: En production, ne jamais retourner le token dans la réponse
        # Le token devrait être envoyé par email uniquement
        # Ici, on le retourne pour faciliter les tests
        
        if success:
            return jsonify({
                'success': True,
                'message': message,
                'token': token  # À RETIRER EN PRODUCTION - seulement pour les tests
            }), 200
        else:
            return jsonify({
                'success': False,
                'message': message
            }), 400
            
    except Exception as e:
        print(f"Erreur dans le controller forgot_password: {e}")
        return jsonify({
            'success': False,
            'message': 'Erreur serveur lors de la demande de réinitialisation'
        }), 500


@forgot_password_bp.route('/reset-password', methods=['POST'])
def reset_password():
    """
    Route pour réinitialiser le mot de passe avec un token
    
    Body (JSON):
        - token: str
        - new_password: str
        
    Returns:
        JSON avec success et message
    """
    try:
        # Récupérer les données de la requête
        data = request.get_json()
        
        if not data:
            return jsonify({
                'success': False,
                'message': 'Données manquantes'
            }), 400
        
        token = data.get('token', '').strip()
        new_password = data.get('new_password', '')
        
        # Réinitialiser le mot de passe
        success, message = ForgotPasswordService.reset_password(token, new_password)
        
        if success:
            return jsonify({
                'success': True,
                'message': message
            }), 200
        else:
            return jsonify({
                'success': False,
                'message': message
            }), 400
            
    except Exception as e:
        print(f"Erreur dans le controller reset_password: {e}")
        return jsonify({
            'success': False,
            'message': 'Erreur serveur lors de la réinitialisation'
        }), 500


@forgot_password_bp.route('/verify-reset-token', methods=['POST'])
def verify_reset_token():
    """
    Route pour vérifier si un token de réinitialisation est valide
    
    Body (JSON):
        - token: str
        
    Returns:
        JSON avec success, valid et message
    """
    try:
        # Récupérer les données de la requête
        data = request.get_json()
        
        if not data:
            return jsonify({
                'success': False,
                'message': 'Données manquantes'
            }), 400
        
        token = data.get('token', '').strip()
        
        # Vérifier le token
        is_valid, message = ForgotPasswordService.verify_token(token)
        
        return jsonify({
            'success': True,
            'valid': is_valid,
            'message': message
        }), 200
            
    except Exception as e:
        print(f"Erreur dans le controller verify_reset_token: {e}")
        return jsonify({
            'success': False,
            'message': 'Erreur serveur lors de la vérification du token'
        }), 500
