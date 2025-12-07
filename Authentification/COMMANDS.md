# ============================================================================
# Guide de commandes rapides - Kintana Project GL
# ============================================================================

## Base de données PostgreSQL

### Créer la base de données
```powershell
# Via psql
psql -U postgres -c "CREATE DATABASE kintana_project_GL;"
```

### Initialiser les tables
```powershell
# Via psql
psql -U postgres -d kintana_project_GL -f repository/data_source/init_database.sql
```

### Se connecter à la base
```powershell
psql -U postgres -d kintana_project_GL
```

### Requêtes utiles
```sql
-- Lister toutes les tables
\dt

-- Voir les utilisateurs
SELECT id, email, username, is_active FROM users;

-- Voir les tokens de réinitialisation  
SELECT id, user_id, token, is_used, expires_at FROM password_resets;

-- Supprimer tous les utilisateurs (ATTENTION!)
TRUNCATE TABLE users CASCADE;

-- Réinitialiser la base complète
DROP TABLE IF EXISTS password_resets CASCADE;
DROP TABLE IF EXISTS users CASCADE;
```

## Backend (API Flask)

### Installer les dépendances
```powershell
pip install -r requirements.txt
```

### Démarrer l'API
```powershell
# Option 1: Script de démarrage
.\start_api.ps1

# Option 2: Commande directe
python app.py
```

### Tester la connexion à la base
```powershell
python -c "from repository.data_source.database_config import test_connection; test_connection()"
```

### Exécuter les tests
```powershell
# Tests automatisés complets
python test_api.py

# Test manuel avec curl
curl http://localhost:5000/health
```

## Frontend (Flutter)

### Obtenir les dépendances
```powershell
cd view/flutter_application
flutter pub get
```

### Lancer l'application
```powershell
cd view/flutter_application
flutter run
```

### Construire pour Android
```powershell
cd view/flutter_application
flutter build apk
```

### Construire pour iOS
```powershell
cd view/flutter_application
flutter build ios
```

## Tests API avec curl

### Health Check
```powershell
curl http://localhost:5000/health
```

### Inscription
```powershell
curl -X POST http://localhost:5000/api/auth/register `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"user@example.com\",\"username\":\"testuser\",\"password\":\"Test1234\"}'
```

### Connexion
```powershell
curl -X POST http://localhost:5000/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"test@example.com\",\"password\":\"Test1234\"}'
```

### Vérifier le token (remplacer YOUR_TOKEN)
```powershell
curl -X GET http://localhost:5000/api/auth/verify `
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Profil utilisateur (remplacer YOUR_TOKEN)
```powershell
curl -X GET http://localhost:5000/api/auth/profile `
  -H "Authorization: Bearer YOUR_TOKEN"
```

### Demander réinitialisation
```powershell
curl -X POST http://localhost:5000/api/auth/forgot-password `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"test@example.com\"}'
```

### Réinitialiser le mot de passe (remplacer YOUR_TOKEN)
```powershell
curl -X POST http://localhost:5000/api/auth/reset-password `
  -H "Content-Type: application/json" `
  -d '{\"token\":\"YOUR_TOKEN\",\"new_password\":\"NewPass123\"}'
```

## Maintenance

### Créer un environnement virtuel Python
```powershell
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### Backup de la base de données
```powershell
pg_dump -U postgres kintana_project_GL > backup.sql
```

### Restaurer la base de données
```powershell
psql -U postgres -d kintana_project_GL < backup.sql
```

### Mettre à jour les dépendances
```powershell
pip freeze > requirements.txt
```

## Dépannage

### PostgreSQL ne démarre pas
```powershell
# Windows - Démarrer le service
net start postgresql-x64-14

# Vérifier le statut
sc query postgresql-x64-14
```

### Port 5000 déjà utilisé
```powershell
# Trouver le processus
netstat -ano | findstr :5000

# Tuer le processus (remplacer PID)
taskkill /PID <PID> /F
```

### Réinstaller les dépendances Python
```powershell
pip uninstall -r requirements.txt -y
pip install -r requirements.txt
```

### Réinitialiser complètement la base
```powershell
psql -U postgres -c "DROP DATABASE IF EXISTS kintana_project_GL;"
psql -U postgres -c "CREATE DATABASE kintana_project_GL;"
psql -U postgres -d kintana_project_GL -f repository/data_source/init_database.sql
```

## Variables d'environnement

### Créer le fichier .env
```powershell
cp .env.example .env
```

### Variables importantes
```
DB_HOST=localhost
DB_PORT=5432
DB_NAME=kintana_project_GL
DB_USER=postgres
DB_PASSWORD=votre_mot_de_passe

SECRET_KEY=changez_moi_en_production
JWT_SECRET_KEY=changez_moi_aussi_en_production
```

## Production

### Démarrer avec Gunicorn (Linux/Mac)
```bash
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

### Créer un service systemd (Linux)
```bash
sudo nano /etc/systemd/system/kintana-api.service
# Ajouter la configuration du service
sudo systemctl start kintana-api
sudo systemctl enable kintana-api
```

---

**Note**: Remplacez les valeurs de test par vos vraies valeurs en production!
