"""
Script de test de l'API d'authentification
Exécutez ce script pour vérifier que l'API fonctionne correctement
"""
import requests
import json
from datetime import datetime

# Configuration
BASE_URL = "http://localhost:5000"
TEST_EMAIL = f"test_{datetime.now().timestamp()}@example.com"
TEST_NOM = f"User Test {int(datetime.now().timestamp())}"
TEST_PASSWORD = "Test1234"

# Couleurs pour l'affichage
class Colors:
    GREEN = '\033[92m'
    RED = '\033[91m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    RESET = '\033[0m'

def print_success(message):
    print(f"{Colors.GREEN}✓ {message}{Colors.RESET}")

def print_error(message):
    print(f"{Colors.RED}✗ {message}{Colors.RESET}")

def print_info(message):
    print(f"{Colors.BLUE}ℹ {message}{Colors.RESET}")

def print_section(title):
    print(f"\n{Colors.YELLOW}{'='*60}{Colors.RESET}")
    print(f"{Colors.YELLOW}{title}{Colors.RESET}")
    print(f"{Colors.YELLOW}{'='*60}{Colors.RESET}\n")

def test_health_check():
    """Test 1: Health Check"""
    print_section("Test 1: Health Check")
    try:
        response = requests.get(f"{BASE_URL}/health")
        if response.status_code == 200:
            data = response.json()
            print_success(f"API Status: {data.get('status')}")
            print_success(f"Database: {data.get('database')}")
            return True
        else:
            print_error(f"Health check failed: {response.status_code}")
            return False
    except Exception as e:
        print_error(f"Connection error: {e}")
        return False

def test_register():
    """Test 2: Inscription"""
    print_section("Test 2: Inscription")
    try:
        data = {
            "nom": TEST_NOM,
            "email": TEST_EMAIL,
            "password": TEST_PASSWORD
        }
        
        response = requests.post(f"{BASE_URL}/api/auth/register", json=data)
        result = response.json()
        
        if response.status_code == 201 and result.get('success'):
            print_success("Inscription réussie")
            print_info(f"User ID: {result['user']['id_user']}")
            print_info(f"Email: {result['user']['email']}")
            print_info(f"Nom: {result['user']['nom']}")
            return result.get('token')
        else:
            print_error(f"Inscription échouée: {result.get('message')}")
            return None
    except Exception as e:
        print_error(f"Error: {e}")
        return None

def test_login():
    """Test 3: Connexion"""
    print_section("Test 3: Connexion")
    try:
        data = {
            "email": TEST_EMAIL,
            "password": TEST_PASSWORD
        }
        
        response = requests.post(f"{BASE_URL}/api/auth/login", json=data)
        result = response.json()
        
        if response.status_code == 200 and result.get('success'):
            print_success("Connexion réussie")
            print_info(f"Token reçu: {result['token'][:50]}...")
            return result.get('token')
        else:
            print_error(f"Connexion échouée: {result.get('message')}")
            return None
    except Exception as e:
        print_error(f"Error: {e}")
        return None

def test_verify_token(token):
    """Test 4: Vérification du token"""
    print_section("Test 4: Vérification du token")
    try:
        headers = {"Authorization": f"Bearer {token}"}
        response = requests.get(f"{BASE_URL}/api/auth/verify", headers=headers)
        result = response.json()
        
        if response.status_code == 200 and result.get('success'):
            print_success("Token valide")
            print_info(f"User: {result['user']['email']}")
            return True
        else:
            print_error(f"Token invalide: {result.get('message')}")
            return False
    except Exception as e:
        print_error(f"Error: {e}")
        return False

def test_profile(token):
    """Test 5: Récupération du profil"""
    print_section("Test 5: Récupération du profil")
    try:
        headers = {"Authorization": f"Bearer {token}"}
        response = requests.get(f"{BASE_URL}/api/auth/profile", headers=headers)
        result = response.json()
        
        if response.status_code == 200 and result.get('success'):
            print_success("Profil récupéré")
            print_info(f"Email: {result['user']['email']}")
            print_info(f"Nom: {result['user']['nom']}")
            return True
        else:
            print_error(f"Échec: {result.get('message')}")
            return False
    except Exception as e:
        print_error(f"Error: {e}")
        return False

def test_forgot_password():
    """Test 6: Mot de passe oublié"""
    print_section("Test 6: Demande de réinitialisation")
    try:
        data = {"email": TEST_EMAIL}
        response = requests.post(f"{BASE_URL}/api/auth/forgot-password", json=data)
        result = response.json()
        
        if response.status_code == 200 and result.get('success'):
            print_success("Token de réinitialisation créé")
            print_info(f"Token: {result.get('token', 'N/A')[:50]}...")
            return result.get('token')
        else:
            print_error(f"Échec: {result.get('message')}")
            return None
    except Exception as e:
        print_error(f"Error: {e}")
        return None

def test_reset_password(reset_token):
    """Test 7: Réinitialisation du mot de passe"""
    print_section("Test 7: Réinitialisation du mot de passe")
    try:
        data = {
            "token": reset_token,
            "new_password": "NewPassword123"
        }
        response = requests.post(f"{BASE_URL}/api/auth/reset-password", json=data)
        result = response.json()
        
        if response.status_code == 200 and result.get('success'):
            print_success("Mot de passe réinitialisé")
            return True
        else:
            print_error(f"Échec: {result.get('message')}")
            return False
    except Exception as e:
        print_error(f"Error: {e}")
        return False

def test_check_email():
    """Test 8: Vérification d'email"""
    print_section("Test 8: Vérification de disponibilité d'email")
    try:
        data = {"email": "nouveau@example.com"}
        response = requests.post(f"{BASE_URL}/api/auth/check-email", json=data)
        result = response.json()
        
        if response.status_code == 200 and result.get('success'):
            available = result.get('available')
            if available:
                print_success("Email disponible")
            else:
                print_info("Email déjà utilisé")
            return True
        else:
            print_error(f"Échec: {result.get('message')}")
            return False
    except Exception as e:
        print_error(f"Error: {e}")
        return False

def run_all_tests():
    """Exécuter tous les tests"""
    print(f"\n{Colors.BLUE}{'='*60}{Colors.RESET}")
    print(f"{Colors.BLUE}     TESTS DE L'API D'AUTHENTIFICATION KINTANA PROJECT{Colors.RESET}")
    print(f"{Colors.BLUE}{'='*60}{Colors.RESET}")
    
    results = []
    
    # Test 1: Health Check
    results.append(("Health Check", test_health_check()))
    
    # Test 2: Inscription
    token = test_register()
    results.append(("Inscription", token is not None))
    
    if token:
        # Test 3: Connexion
        login_token = test_login()
        results.append(("Connexion", login_token is not None))
        
        if login_token:
            # Test 4: Vérification du token
            results.append(("Vérification Token", test_verify_token(login_token)))
            
            # Test 5: Profil
            results.append(("Profil", test_profile(login_token)))
        
        # Test 6: Mot de passe oublié
        reset_token = test_forgot_password()
        results.append(("Demande Reset", reset_token is not None))
        
        if reset_token:
            # Test 7: Réinitialisation
            results.append(("Réinitialisation", test_reset_password(reset_token)))
        
        # Test 8: Vérification d'email
        results.append(("Check Email", test_check_email()))
    
    # Résumé
    print_section("RÉSUMÉ DES TESTS")
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for test_name, result in results:
        if result:
            print_success(f"{test_name}")
        else:
            print_error(f"{test_name}")
    
    print(f"\n{Colors.BLUE}{'='*60}{Colors.RESET}")
    if passed == total:
        print_success(f"Tous les tests réussis! ({passed}/{total})")
    else:
        print_error(f"Certains tests ont échoué: {passed}/{total} réussis")
    print(f"{Colors.BLUE}{'='*60}{Colors.RESET}\n")

if __name__ == "__main__":
    try:
        run_all_tests()
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}Tests interrompus par l'utilisateur{Colors.RESET}")
    except Exception as e:
        print_error(f"Erreur générale: {e}")
