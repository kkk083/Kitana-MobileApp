import requests
import json
import random
import string

BASE_URL = "http://localhost:5000/api/auth"

def random_string(length=10):
    return ''.join(random.choice(string.ascii_letters) for i in range(length))

def test_register_with_role():
    print("Test d'inscription AVEC RÔLE...")
    
    email = f"user_{random_string()}@test.com"
    password = "Password123"
    nom = "Test Role User"
    role = "professeur"
    
    payload = {
        "nom": nom,
        "email": email,
        "password": password,
        "role": role
    }
    
    try:
        response = requests.post(f"{BASE_URL}/register", json=payload)
        
        print(f"Status: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code == 201:
            data = response.json()
            if data['user']['role'] == role:
                print("✅ SUCCÈS : Utilisateur créé avec le bon rôle !")
                return True
            else:
                print(f"❌ ÉCHEC : Rôle incorrect. Attendu: {role}, Reçu: {data['user'].get('role')}")
                return False
        else:
            print("❌ ÉCHEC : Erreur lors de l'inscription")
            return False
            
    except Exception as e:
        print(f"❌ ERREUR DE CONNEXION : {e}")
        return False

if __name__ == "__main__":
    test_register_with_role()
