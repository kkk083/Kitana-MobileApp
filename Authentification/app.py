"""
Application Flask unifiée pour l'authentification et le chatbot
"""
from flask import Flask, jsonify, request
from flask_cors import CORS
import sys
import os
import requests
import re

# Ajouter le chemin du projet pour les imports
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from controller.login_controller import login_bp
from controller.register_controller import register_bp
from controller.forgot_password_controller import forgot_password_bp
from controller.change_password_controller import password_bp
from repository.data_source.database_config import DatabaseConfig, test_connection

# ============================================================================
# CONFIGURATION CHATBOT
# ============================================================================
GEMINI_API_KEY = "AIzaSyCZXfULvhC85pkZa-suZFfGGAoYkeoTi0A"
GEMINI_API_URL = f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key={GEMINI_API_KEY}"

# Texte de référence (OCR désactivé pour l'instant)
PDF_TEXT = """
L'endométriose est une maladie gynécologique chronique qui touche environ 10% des femmes en âge de procréer.
Elle se caractérise par la présence de tissu semblable à l'endomètre en dehors de l'utérus.
Les symptômes incluent des douleurs pelviennes, des règles douloureuses et parfois l'infertilité.
Le diagnostic se fait par échographie, IRM ou laparoscopie.
Les traitements incluent des médicaments hormonaux, des analgésiques et parfois la chirurgie.
"""

# ============================================================================
# FONCTIONS UTILITAIRES CHATBOT
# ============================================================================
def contains_personal_info(text):
    """Détecte les informations personnelles dans le texte"""
    patterns = [
        r"je m'?appelle\s+\w+",
        r"j'ai\s+\d+\s*ans",
        r"j'ai\s+\d+\s*mois",
        r"(mon adresse|j'habite à)\s+[\w\s\d]+",
        r"(mon email|mon e-?mail)\s+[\w\.\-]+@[\w\.\-]+\.\w+",
        r"(mon numéro|mon téléphone|tél)\s+[\d\s]+",
    ]
    return any(re.search(pattern, text, re.IGNORECASE) for pattern in patterns)

def contains_alert_keywords(text):
    """Détecte les mots-clés sensibles"""
    alert_patterns = [
        r"suicid",
        r"idées?\s+suicidaires?",
        r"automutil",
        r"dépression",
        r"je veux me tuer",
        r"je n'en peux plus",
        r"je me fais du mal",
        r"en finir",
        r"idées noires",
    ]
    return any(re.search(pattern, text, re.IGNORECASE) for pattern in alert_patterns)


def create_app():
    """Créer et configurer l'application Flask"""
    app = Flask(__name__)
    
    # Configuration
    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'votre_cle_secrete_changez_moi_en_production')
    app.config['JSON_SORT_KEYS'] = False
    
    # Activer CORS pour toutes les routes
    CORS(app, resources={
        r"/*": {
            "origins": "*",
            "methods": ["GET", "POST", "PUT", "DELETE", "OPTIONS"],
            "allow_headers": ["Content-Type", "Authorization"]
        }
    })
    
    # ========================================================================
    # BLUEPRINTS AUTHENTIFICATION
    # ========================================================================
    app.register_blueprint(login_bp)
    app.register_blueprint(register_bp)
    app.register_blueprint(forgot_password_bp)
    app.register_blueprint(password_bp)
    
    # ========================================================================
    # ROUTES AUTHENTIFICATION
    # ========================================================================
    @app.route('/health', methods=['GET'])
    def health_check():
        """Route pour vérifier l'état de l'API"""
        db_status = test_connection()
        return jsonify({
            'status': 'healthy' if db_status else 'unhealthy',
            'database': 'connected' if db_status else 'disconnected',
            'api_version': '1.0.0'
        }), 200 if db_status else 503
    
    @app.route('/', methods=['GET'])
    def index():
        """Route d'accueil de l'API"""
        return jsonify({
            'message': 'API Kintana Project - Authentification & ChatBot',
            'version': '1.0.0',
            'endpoints': {
                'auth': {
                    'health': '/health',
                    'login': '/api/auth/login',
                    'register': '/api/auth/register',
                    'forgot_password': '/api/auth/forgot-password',
                },
                'chatbot': {
                    'ask': '/ask',
                    'debug_pdf': '/debug-pdf'
                }
            }
        }), 200
    
    # ========================================================================
    # ROUTES CHATBOT
    # ========================================================================
    @app.route("/debug-pdf", methods=["GET"])
    def debug_pdf():
        """Affiche le texte extrait du PDF pour debug"""
        return jsonify({
            "pdf_length": len(PDF_TEXT),
            "pdf_preview": PDF_TEXT[:2000],
            "total_chars": len(PDF_TEXT),
            "contains_endometriosis": "endometriosis" in PDF_TEXT.lower()
        })

    @app.route("/ask", methods=["POST"])
    def ask():
        """Endpoint principal du chatbot"""
        data = request.get_json()
        question = data.get("question", "").strip()
       
        if not question:
            return jsonify({"error": "Question vide"}), 400

        # Vérifications de sécurité
        if contains_personal_info(question):
            return jsonify({"answer": "Attention, pour ta sécurité, ne diffuse pas d'informations personnelles te concernant"})

        if contains_alert_keywords(question):
            print(f"⚠️ ALERT: mot sensible détecté: {question}")
            return jsonify({"answer": "Si tu ne te sens pas bien, c'est toujours mieux d'en parler à un adulte de confiance qu'une machine! ;)"})
        
        # ✨ NOUVEAU : Détecter les salutations et questions générales
        greetings = ["salut", "bonjour", "hello", "hi", "coucou", "bonsoir", "hey"]
        farewells = ["au revoir", "bye", "à bientôt", "ciao", "merci", "ok"]
        
        question_lower = question.lower()
        
        # Salutations
        if any(greeting in question_lower for greeting in greetings) and len(question.split()) <= 3:
            return jsonify({"answer": "Bonjour ! Je suis KINTANA, ton assistant sur l'endométriose. Pose-moi tes questions ! 😊"})
        
        # Au revoir
        if any(farewell in question_lower for farewell in farewells) and len(question.split()) <= 3:
            return jsonify({"answer": "À bientôt ! N'hésite pas si tu as d'autres questions. 👋"})
        
        # Comment vas-tu / ça va
        if any(phrase in question_lower for phrase in ["comment vas", "ça va", "tu vas bien", "comment tu vas"]):
            return jsonify({"answer": "Je vais très bien, merci ! Et toi ? Si tu as des questions sur l'endométriose, je suis là pour t'aider ! 😊"})
        
        # Préparer le contexte pour les vraies questions
        max_chars = 400000
        pdf_content = PDF_TEXT if len(PDF_TEXT) <= max_chars else PDF_TEXT[:max_chars] + "\n\n[...TRUNCATED...]"
       
        print(f"📊 Longueur du contexte envoyé: {len(pdf_content)} caractères")

        # Préparer la requête Gemini
        body = {
            "contents": [
                {
                    "parts": [
                        {
                            "text": f"""You are a medical assistant that answers questions ONLY based on the provided PDF document about endometriosis.

INSTRUCTIONS:
- Answer in French
- Answer the question using ONLY information from the PDF below.
- Give only a concise definition or short answer. Do NOT provide long explanations.
- If the PDF contains the answer, provide a short definition.
- If the information is not in the PDF, say: "Je ne peux pas répondre à ce genre de questions, restez dans le thème que l'instructeur a donné s'il vous plait"

PDF DOCUMENT CONTENT:
{pdf_content}

USER QUESTION: {question}

ANSWER:"""
                        }
                    ]
                }
            ],
            "generationConfig": {
                "temperature": 0.1,
                "maxOutputTokens": 1000,
                "topP": 0.95,
                "topK": 40
            }
        }

        try:
            print(f"📤 Envoi de la question à Gemini: {question}")
            response = requests.post(GEMINI_API_URL, json=body, timeout=60)
            response.raise_for_status()
            result = response.json()
           
            answer = result["candidates"][0]["content"]["parts"][0]["text"]
            print(f"✅ Réponse reçue ({len(answer)} chars): {answer[:200]}...")
           
        except requests.exceptions.HTTPError as e:
            print(f"❌ Erreur HTTP {response.status_code}: {e}")
            print(f"📄 Réponse API: {response.text}")
            
            # Meilleure gestion des erreurs
            if response.status_code == 403:
                answer = "⚠️ Problème avec la clé API. Veuillez contacter l'administrateur."
            elif response.status_code == 429:
                answer = "⏳ Trop de requêtes. Réessayez dans quelques instants."
            else:
                answer = "❌ Erreur de connexion au service IA. Réessayez plus tard."
                
        except KeyError as e:
            print(f"❌ Erreur de structure: {e}")
            answer = "❌ Erreur de traitement de la réponse."
        except Exception as e:
            print(f"❌ Erreur: {e}")
            answer = "❌ Une erreur s'est produite. Réessayez."

        return jsonify({"answer": answer})
    
    # ========================================================================
    # GESTIONNAIRES D'ERREURS
    # ========================================================================
    @app.errorhandler(404)
    def not_found(error):
        return jsonify({
            'success': False,
            'message': 'Route non trouvée'
        }), 404
    
    @app.errorhandler(500)
    def internal_error(error):
        return jsonify({
            'success': False,
            'message': 'Erreur serveur interne'
        }), 500
    
    return app


if __name__ == '__main__':
    app = create_app()
    
    # Informations de démarrage
    print("\n" + "="*60)
    print("🚀 Démarrage de l'API Kintana Project")
    print("   ✓ Authentification")
    print("   ✓ ChatBot avec Gemini")
    print("="*60)
    
    if test_connection():
        print("✓ Connexion à la base de données établie")
    else:
        print("✗ ATTENTION: Impossible de se connecter à la base de données")
    
    print("✓ Utilisation du modèle: gemini-2.5-flash")
    print("✓ Texte de référence chargé (OCR désactivé)")
    print("\n📡 L'API sera accessible sur: http://localhost:5000")
    print("   - Auth: http://localhost:5000/api/auth/*")
    print("   - ChatBot: http://localhost:5000/ask")
    print("="*60 + "\n")
    
    # Démarrer l'application
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=True
    )