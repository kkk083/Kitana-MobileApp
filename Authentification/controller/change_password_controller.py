"""
Controller pour la modification simple du mot de passe (sans email)
"""
from flask import Blueprint, request, jsonify
import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from services.forgot_password_service import ForgotPasswordService
from controller.login_controller import token_required

# Créer un Blueprint pour les routes de gestion du mot de passe
password_bp = Blueprint('password', __name__, url_prefix='/api/auth')


@password_bp.route('/change-password', methods=['POST'])
@token_required
def change_password(current_user):
    """
    Route pour changer le mot de passe d'un utilisateur connecté
    
    Headers:
        - Authorization: Bearer <token>
    
    Body (JSON):
        - current_password: str (mot de passe actuel)
        - new_password: str (nouveau mot de passe)
        
    Returns:
        JSON avec success et message
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({
                'success': False,
                'message': 'Données manquantes'
            }), 400
        
        current_password = data.get('current_password', '')
        new_password = data.get('new_password', '')
        
        # Vérifier que les champs sont remplis
        if not current_password or not new_password:
            return jsonify({
                'success': False,
                'message': 'Mot de passe actuel et nouveau mot de passe requis'
            }), 400
        
        # Vérifier si le mot de passe actuel est correct
        from services.login_service import LoginService
        if not LoginService._verify_password(current_password, current_user.password):
            return jsonify({
                'success': False,
                'message': 'Mot de passe actuel incorrect'
            }), 400
        
        # Valider le nouveau mot de passe
        is_valid, validation_message = ForgotPasswordService._validate_password(new_password)
        if not is_valid:
            return jsonify({
                'success': False,
                'message': validation_message
            }), 400
        
        # Mettre à jour le mot de passe
        password_hash = ForgotPasswordService._hash_password(new_password)
        success = ForgotPasswordService._update_user_password(current_user.id_user, password_hash)
        
        if success:
            return jsonify({
                'success': True,
                'message': 'Mot de passe modifié avec succès'
            }), 200
        else:
            return jsonify({
                'success': False,
                'message': 'Erreur lors de la modification du mot de passe'
            }), 500
            
    except Exception as e:
        print(f"Erreur dans change_password: {e}")
        return jsonify({
            'success': False,
            'message': 'Erreur serveur lors de la modification'
        }), 500
