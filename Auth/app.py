"""
Application Flask principale pour l'API d'authentification
"""
from flask import Flask, jsonify
from flask_cors import CORS
import sys
import os

# Ajouter le chemin du projet pour les imports
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from controller.login_controller import login_bp
from controller.register_controller import register_bp
from controller.forgot_password_controller import forgot_password_bp
from repository.data_source.database_config import DatabaseConfig, test_connection


def create_app():
    """Créer et configurer l'application Flask"""
    app = Flask(__name__)
    
    # Configuration
    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'votre_cle_secrete_changez_moi_en_production')
    app.config['JSON_SORT_KEYS'] = False
    
    # Activer CORS pour permettre les requêtes depuis Flutter
    CORS(app, resources={
        r"/api/*": {
            "origins": "*",  # En production, spécifiez les origines autorisées
            "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
            "allow_headers": ["Content-Type", "Authorization"]
        }
    })
    
    # Enregistrer les blueprints
    app.register_blueprint(login_bp)
    app.register_blueprint(register_bp)
    app.register_blueprint(forgot_password_bp)
    
    # Route de santé
    @app.route('/health', methods=['GET'])
    def health_check():
        """Route pour vérifier l'état de l'API"""
        db_status = test_connection()
        
        return jsonify({
            'status': 'healthy' if db_status else 'unhealthy',
            'database': 'connected' if db_status else 'disconnected',
            'api_version': '1.0.0'
        }), 200 if db_status else 503
    
    # Route d'accueil
    @app.route('/', methods=['GET'])
    def index():
        """Route d'accueil de l'API"""
        return jsonify({
            'message': 'API d\'authentification Kintana Project',
            'version': '1.0.0',
            'endpoints': {
                'health': '/health',
                'login': '/api/auth/login',
                'register': '/api/auth/register',
                'verify_token': '/api/auth/verify',
                'logout': '/api/auth/logout',
                'profile': '/api/auth/profile',
                'forgot_password': '/api/auth/forgot-password',
                'reset_password': '/api/auth/reset-password',
                'verify_reset_token': '/api/auth/verify-reset-token',
                'check_email': '/api/auth/check-email',
                'check_username': '/api/auth/check-username'
            }
        }), 200
    
    # Gestionnaire d'erreurs 404
    @app.errorhandler(404)
    def not_found(error):
        return jsonify({
            'success': False,
            'message': 'Route non trouvée'
        }), 404
    
    # Gestionnaire d'erreurs 500
    @app.errorhandler(500)
    def internal_error(error):
        return jsonify({
            'success': False,
            'message': 'Erreur serveur interne'
        }), 500
    
    return app


if __name__ == '__main__':
    app = create_app()
    
    # Tester la connexion à la base de données au démarrage
    print("\n" + "="*60)
    print("🚀 Démarrage de l'API d'authentification Kintana Project")
    print("="*60)
    
    if test_connection():
        print("✓ Connexion à la base de données établie")
    else:
        print("✗ ATTENTION: Impossible de se connecter à la base de données")
        print("  Vérifiez que PostgreSQL est en cours d'exécution")
        print("  et que les tables sont créées (voir init_database.sql)")
    
    print("\n📡 L'API sera accessible sur: http://localhost:5000")
    print("📚 Documentation des endpoints: http://localhost:5000/\n")
    print("="*60 + "\n")
    
    # Démarrer l'application
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=True  # Mettre à False en production
    )
