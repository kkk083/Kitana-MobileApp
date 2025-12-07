"""
Script pour configurer et initialiser la base de données
"""
import psycopg2
import getpass
import os

def get_postgres_password():
    """Demander le mot de passe PostgreSQL"""
    print("\n" + "="*60)
    print("Configuration de la connexion PostgreSQL")
    print("="*60)
    
    password = getpass.getpass("Entrez le mot de passe PostgreSQL (vide si aucun) : ")
    return password

def test_connection(password):
    """Tester la connexion avec le mot de passe"""
    try:
        conn = psycopg2.connect(
            host='localhost',
            port=5432,
            user='postgres',
            password=password,
            database='postgres'  # Base par défaut pour tester
        )
        conn.close()
        print("✓ Connexion réussie à PostgreSQL")
        return True
    except Exception as e:
        print(f"✗ Erreur de connexion: {e}")
        return False

def create_database(password):
    """Créer la base de données si elle n'existe pas"""
    try:
        # Se connecter à la base postgres par défaut
        conn = psycopg2.connect(
            host='localhost',
            port=5432,
            user='postgres',
            password=password,
            database='postgres'
        )
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Vérifier si la base existe
        cursor.execute("SELECT 1 FROM pg_database WHERE datname='kintana_project_gl'")
        exists = cursor.fetchone()
        
        if not exists:
            print("Création de la base de données kintana_project_GL...")
            cursor.execute("CREATE DATABASE kintana_project_gl")
            print("✓ Base de données créée")
        else:
            print("✓ Base de données kintana_project_GL existe déjà")
        
        cursor.close()
        conn.close()
        return True
    except Exception as e:
        print(f"✗ Erreur lors de la création de la base: {e}")
        return False

def init_tables(password):
    """Initialiser les tables"""
    try:
        # Lire le script SQL
        script_path = os.path.join(
            os.path.dirname(__file__),
            'repository', 'data_source', 'init_database.sql'
        )
        
        with open(script_path, 'r', encoding='utf-8') as f:
            sql_script = f.read()
        
        # Se connecter à la base kintana_project_GL
        conn = psycopg2.connect(
            host='localhost',
            port=5432,
            user='postgres',
            password=password,
            database='kintana_project_gl'
        )
        cursor = conn.cursor()
        
        print("Exécution du script d'initialisation...")
        cursor.execute(sql_script)
        conn.commit()
        
        print("✓ Tables créées avec succès")
        
        # Vérifier les tables
        cursor.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public'
        """)
        tables = cursor.fetchall()
        print(f"\nTables créées: {[t[0] for t in tables]}")
        
        cursor.close()
        conn.close()
        return True
    except Exception as e:
        print(f"✗ Erreur lors de l'initialisation: {e}")
        return False

def save_config(password):
    """Sauvegarder la configuration dans un fichier .env"""
    env_content = f"""# Configuration de la base de données PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_NAME=kintana_project_gl
DB_USER=postgres
DB_PASSWORD={password}

# Configuration JWT
JWT_SECRET_KEY=votre_cle_secrete_changez_moi_en_production

# Configuration Flask
FLASK_ENV=development
FLASK_DEBUG=True
"""
    
    try:
        # Chercher un fichier .env existant
        env_path = os.path.join(os.path.dirname(__file__), '.env')
        
        # Sauvegarder
        with open(env_path, 'w', encoding='utf-8') as f:
            f.write(env_content)
        
        print(f"✓ Configuration sauvegardée dans .env")
        
        # Installer python-dotenv si nécessaire
        try:
            import dotenv
            print("✓ python-dotenv est installé")
        except ImportError:
            print("\n⚠️  Installation de python-dotenv...")
            os.system("pip install python-dotenv")
        
        return True
    except Exception as e:
        print(f"✗ Erreur lors de la sauvegarde: {e}")
        return False

def main():
    """Fonction principale"""
    print("\n🚀 Configuration de la base de données Kintana Project\n")
    
    # 1. Demander le mot de passe
    password = get_postgres_password()
    
    # 2. Tester la connexion
    print("\n📡 Test de connexion...")
    if not test_connection(password):
        print("\n❌ Impossible de se connecter. Vérifiez :")
        print("  - Que PostgreSQL est démarré")
        print("  - Que le mot de passe est correct")
        return
    
    # 3. Créer la base de données
    print("\n📦 Création de la base de données...")
    if not create_database(password):
        return
    
    # 4. Initialiser les tables
    print("\n🔨 Initialisation des tables...")
    if not init_tables(password):
        return
    
    # 5. Sauvegarder la configuration
    print("\n💾 Sauvegarde de la configuration...")
    if not save_config(password):
        return
    
    print("\n" + "="*60)
    print("✅ CONFIGURATION TERMINÉE AVEC SUCCÈS !")
    print("="*60)
    print("\n📝 Prochaines étapes :")
    print("  1. Redémarrez l'API : python app.py")
    print("  2. Testez : http://localhost:5000/health")
    print("  3. Créez les fichiers Flutter (voir CREER_FICHIERS_FLUTTER.md)")
    print("\n" + "="*60 + "\n")

if __name__ == "__main__":
    main()
