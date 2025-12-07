# 🚀 Kintana Project GL - API d'Authentification

Projet de gestion d'authentification avec Flask (Backend) et Flutter (Frontend).

## 📋 Table des matières

- [Description](#description)
- [Architecture](#architecture)
- [Installation](#installation)
- [Utilisation](#utilisation)
- [Documentation API](#documentation-api)
- [Structure du projet](#structure-du-projet)
- [Technologies](#technologies)

## 📖 Description

Ce projet propose un système d'authentification complet avec :
- **Backend** : API REST Flask + PostgreSQL
- **Frontend** : Application Flutter mobile

### Fonctionnalités d'authentification

✅ **Inscription** - Création de compte avec validation  
✅ **Connexion** - Authentification avec JWT  
✅ **Mot de passe oublié** - Système de réinitialisation avec tokens  
✅ **Vérification de token** - Validation des sessions  
✅ **Profil utilisateur** - Gestion des informations  

## 🏗️ Architecture

```
├── Frontend (Flutter)
│   └── view/flutter_application/
│
└── Backend (Flask + PostgreSQL)
    ├── controller/          # Routes Flask (API endpoints)
    ├── services/            # Logique métier
    ├── models/              # Modèles de données
    └── repository/          # Accès base de données
```

## 🔧 Installation

### Prérequis

- **Python 3.8+**
- **PostgreSQL 12+**
- **Flutter 3.0+** (pour le frontend)
- **pip** (gestionnaire de packages Python)

### 1. Installation du Backend

#### Étape 1 : Cloner le projet

```bash
git clone <repository-url>
cd kintana_project_GL
```

#### Étape 2 : Installer les dépendances Python

```bash
pip install -r requirements.txt
```

#### Étape 3 : Configurer PostgreSQL

1. **Démarrer PostgreSQL** (si ce n'est pas déjà fait)

2. **Créer la base de données** :
   ```sql
   CREATE DATABASE kintana_project_GL;
   ```

3. **Initialiser les tables** :
   ```bash
   psql -U postgres -d kintana_project_GL -f repository/data_source/init_database.sql
   ```

   **OU** via pgAdmin :
   - Ouvrir pgAdmin
   - Se connecter au serveur PostgreSQL
   - Sélectionner la base `kintana_project_GL`
   - Ouvrir l'éditeur de requêtes
   - Copier/coller le contenu de `init_database.sql`
   - Exécuter

#### Étape 4 : Configurer l'environnement (optionnel)

```bash
cp .env.example .env
```

Modifier le fichier `.env` si nécessaire.

### 2. Installation du Frontend (Flutter)

```bash
cd view/flutter_application
flutter pub get
```

## 🚀 Utilisation

### Démarrer le Backend

**Option 1 : Script PowerShell (Windows)**
```powershell
.\start_api.ps1
```

**Option 2 : Commande directe**
```bash
python app.py
```

L'API sera accessible sur : `http://localhost:5000`

### Démarrer le Frontend

```bash
cd view/flutter_application
flutter run
```

### Tester l'API

Exécutez le script de test :

```bash
python test_api.py
```

Ce script testera automatiquement tous les endpoints de l'API.

## 📚 Documentation API

Consultez [API_DOCUMENTATION.md](API_DOCUMENTATION.md) pour la documentation complète des endpoints.

### Endpoints principaux

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| POST | `/api/auth/register` | Inscription |
| POST | `/api/auth/login` | Connexion |
| GET | `/api/auth/verify` | Vérifier token |
| GET | `/api/auth/profile` | Profil utilisateur |
| POST | `/api/auth/forgot-password` | Demande réinitialisation |
| POST | `/api/auth/reset-password` | Réinitialiser mot de passe |
| POST | `/api/auth/check-email` | Vérifier disponibilité email |
| POST | `/api/auth/check-username` | Vérifier disponibilité username |

### Comptes de test

Le script d'initialisation crée deux comptes de test :

- **Email** : `test@example.com` | **Password** : `Test1234`
- **Email** : `admin@kintana.com` | **Password** : `Test1234`

## 📁 Structure du projet

```
kintana_project_GL/
│
├── app.py                           # Application Flask principale
├── requirements.txt                 # Dépendances Python
├── .env.example                     # Template configuration
├── .gitignore                       # Fichiers à ignorer
├── start_api.ps1                    # Script de démarrage
├── test_api.py                      # Tests automatisés
├── API_DOCUMENTATION.md             # Documentation API
│
├── controller/                      # Controllers (routes Flask)
│   ├── __init__.py
│   ├── login_controller.py         # Routes connexion
│   ├── register_controller.py      # Routes inscription
│   └── forgot_password_controller.py  # Routes réinitialisation
│
├── services/                        # Logique métier
│   ├── __init__.py
│   ├── login_service.py            # Service connexion
│   ├── register_service.py         # Service inscription
│   └── forgot_password_service.py  # Service réinitialisation
│
├── models/                          # Modèles de données
│   ├── __init__.py
│   ├── user_model.py               # Modèle User
│   └── password_reset_model.py     # Modèle PasswordReset
│
├── repository/                      # Accès données
│   ├── __init__.py
│   └── data_source/
│       ├── __init__.py
│       ├── database_config.py      # Configuration PostgreSQL
│       └── init_database.sql       # Script initialisation DB
│
└── view/                            # Frontend Flutter
    └── flutter_application/
        ├── lib/
        ├── android/
        └── ios/
```

## 🛠️ Technologies

### Backend
- **Flask** - Framework web Python
- **PostgreSQL** - Base de données relationnelle
- **psycopg2** - Adaptateur PostgreSQL
- **bcrypt** - Hashage sécurisé des mots de passe
- **PyJWT** - Gestion tokens JWT
- **Flask-CORS** - Gestion requêtes cross-origin

### Frontend
- **Flutter** - Framework mobile cross-platform
- **Dart** - Langage de programmation

## 🔐 Sécurité

- Mots de passe hashés avec **bcrypt**
- Authentification via **JWT** (24h de validité)
- Tokens de réinitialisation avec expiration
- Validation complète des données côté backend
- Protection CORS configurée

## 📝 Notes

### En production

1. ⚠️ Changez `SECRET_KEY` et `JWT_SECRET_KEY`
2. ⚠️ Désactivez `debug=True` dans `app.py`
3. ⚠️ Configurez CORS pour vos domaines uniquement
4. ⚠️ N'envoyez jamais les tokens de réinitialisation dans les réponses HTTP
5. ⚠️ Utilisez HTTPS
6. ⚠️ Configurez un serveur WSGI (gunicorn, uwsgi)

### Développement

- Les tokens de réinitialisation sont retournés dans les réponses pour faciliter les tests
- Deux comptes de test sont créés automatiquement
- CORS est ouvert à tous les domaines (`*`)

## 🤝 Contribution

Pour contribuer au projet :
1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📧 Contact

Pour toute question, contactez l'équipe de développement.

## 📄 Licence

Ce projet est sous licence MIT.

---

**Version** : 1.0.0  
**Date** : Décembre 2025