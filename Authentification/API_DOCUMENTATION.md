# API d'Authentification - Kintana Project

## 📋 Description

API REST Flask pour la gestion de l'authentification des utilisateurs avec PostgreSQL.

### Fonctionnalités

- ✅ **Inscription** : Création de compte avec validation complète
- ✅ **Connexion** : Authentification avec JWT
- ✅ **Réinitialisation de mot de passe** : Système de tokens sécurisés
- ✅ **Vérification de token** : Validation des sessions utilisateur
- ✅ **Profil utilisateur** : Récupération des informations

## 🚀 Installation

### Prérequis

- Python 3.8+
- PostgreSQL 12+
- pip

### Étapes d'installation

1. **Installer les dépendances Python**

```bash
pip install -r requirements.txt
```

2. **Configurer PostgreSQL**

Assurez-vous que PostgreSQL est en cours d'exécution et créez la base de données :

```sql
CREATE DATABASE kintana_project_GL;
```

3. **Initialiser les tables**

Exécutez le script SQL pour créer les tables :

```bash
psql -U postgres -d kintana_project_GL -f repository/data_source/init_database.sql
```

Ou via pgAdmin :
- Ouvrez pgAdmin
- Connectez-vous à votre serveur PostgreSQL
- Sélectionnez la base de données `kintana_project_GL`
- Ouvrez l'éditeur de requêtes (Query Tool)
- Copiez le contenu de `repository/data_source/init_database.sql`
- Exécutez le script

4. **Configurer les variables d'environnement** (optionnel)

```bash
cp .env.example .env
```

Modifiez le fichier `.env` selon vos besoins.

5. **Démarrer l'API**

```bash
python app.py
```

L'API sera accessible sur : `http://localhost:5000`

## 📚 Endpoints de l'API

### 1. Health Check

**GET** `/health`

Vérifier l'état de l'API et la connexion à la base de données.

**Réponse :**
```json
{
  "status": "healthy",
  "database": "connected",
  "api_version": "1.0.0"
}
```

### 2. Inscription

**POST** `/api/auth/register`

Créer un nouveau compte utilisateur.

**Body :**
```json
{
  "email": "user@example.com",
  "username": "username",
  "password": "Password123",
  "first_name": "John",
  "last_name": "Doe"
}
```

**Réponse :**
```json
{
  "success": true,
  "message": "Inscription réussie",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "username": "username",
    "first_name": "John",
    "last_name": "Doe"
  }
}
```

### 3. Connexion

**POST** `/api/auth/login`

Se connecter avec email et mot de passe.

**Body :**
```json
{
  "email": "user@example.com",
  "password": "Password123"
}
```

**Réponse :**
```json
{
  "success": true,
  "message": "Connexion réussie",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "username": "username"
  }
}
```

### 4. Vérifier le token

**GET** `/api/auth/verify`

Vérifier la validité d'un token JWT.

**Headers :**
```
Authorization: Bearer <token>
```

**Réponse :**
```json
{
  "success": true,
  "message": "Token valide",
  "user": {
    "id": 1,
    "email": "user@example.com"
  }
}
```

### 5. Récupérer le profil

**GET** `/api/auth/profile`

Récupérer les informations de l'utilisateur connecté.

**Headers :**
```
Authorization: Bearer <token>
```

**Réponse :**
```json
{
  "success": true,
  "message": "Profil récupéré avec succès",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "username": "username",
    "first_name": "John",
    "last_name": "Doe"
  }
}
```

### 6. Demander une réinitialisation de mot de passe

**POST** `/api/auth/forgot-password`

Générer un token de réinitialisation de mot de passe.

**Body :**
```json
{
  "email": "user@example.com"
}
```

**Réponse :**
```json
{
  "success": true,
  "message": "Token de réinitialisation créé avec succès",
  "token": "abc123xyz..." 
}
```

> ⚠️ **Note** : En production, le token ne devrait PAS être retourné dans la réponse. Il doit être envoyé par email.

### 7. Réinitialiser le mot de passe

**POST** `/api/auth/reset-password`

Réinitialiser le mot de passe avec un token.

**Body :**
```json
{
  "token": "abc123xyz...",
  "new_password": "NewPassword123"
}
```

**Réponse :**
```json
{
  "success": true,
  "message": "Mot de passe réinitialisé avec succès"
}
```

### 8. Vérifier un token de réinitialisation

**POST** `/api/auth/verify-reset-token`

Vérifier si un token de réinitialisation est valide.

**Body :**
```json
{
  "token": "abc123xyz..."
}
```

**Réponse :**
```json
{
  "success": true,
  "valid": true,
  "message": "Token valide"
}
```

### 9. Vérifier la disponibilité d'un email

**POST** `/api/auth/check-email`

Vérifier si un email est déjà utilisé.

**Body :**
```json
{
  "email": "user@example.com"
}
```

**Réponse :**
```json
{
  "success": true,
  "available": false,
  "message": "Email déjà utilisé"
}
```

### 10. Vérifier la disponibilité d'un username

**POST** `/api/auth/check-username`

Vérifier si un nom d'utilisateur est déjà utilisé.

**Body :**
```json
{
  "username": "john_doe"
}
```

**Réponse :**
```json
{
  "success": true,
  "available": true,
  "message": "Nom d'utilisateur disponible"
}
```

## 🔐 Sécurité

### Validation du mot de passe

Les mots de passe doivent respecter les critères suivants :
- Minimum 8 caractères
- Au moins une majuscule
- Au moins une minuscule
- Au moins un chiffre

### JWT (JSON Web Tokens)

- Durée de validité : 24 heures
- Algorithme : HS256
- Le token doit être inclus dans le header `Authorization: Bearer <token>`

## 🧪 Tests

### Comptes de test

Le script d'initialisation crée deux comptes de test :

1. **Utilisateur standard**
   - Email : `test@example.com`
   - Mot de passe : `Test1234`

2. **Administrateur**
   - Email : `admin@kintana.com`
   - Mot de passe : `Test1234`

### Tester avec curl

**Connexion :**
```bash
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"test@example.com\",\"password\":\"Test1234\"}"
```

**Inscription :**
```bash
curl -X POST http://localhost:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"newuser@example.com\",\"username\":\"newuser\",\"password\":\"Test1234\"}"
```

## 📁 Structure du projet

```
kintana_project_GL/
├── app.py                          # Application Flask principale
├── requirements.txt                # Dépendances Python
├── .env.example                    # Template de configuration
│
├── controller/                     # Controllers (routes Flask)
│   ├── login_controller.py        # Routes de connexion
│   ├── register_controller.py     # Routes d'inscription
│   └── forgot_password_controller.py  # Routes de réinitialisation
│
├── services/                       # Logique métier
│   ├── login_service.py           # Service de connexion
│   ├── register_service.py        # Service d'inscription
│   └── forgot_password_service.py # Service de réinitialisation
│
├── models/                         # Modèles de données
│   ├── user_model.py              # Modèle User
│   └── password_reset_model.py    # Modèle PasswordReset
│
└── repository/                     # Accès aux données
    └── data_source/
        ├── database_config.py     # Configuration PostgreSQL
        └── init_database.sql      # Script d'initialisation
```

## 🛠️ Technologies utilisées

- **Flask** : Framework web Python
- **PostgreSQL** : Base de données relationnelle
- **psycopg2** : Adaptateur PostgreSQL pour Python
- **bcrypt** : Hashage sécurisé des mots de passe
- **PyJWT** : Gestion des tokens JWT
- **Flask-CORS** : Gestion des requêtes cross-origin

## 📝 Notes importantes

1. **En production** :
   - Changez `SECRET_KEY` et `JWT_SECRET_KEY`
   - Désactivez `debug=True` dans app.py
   - Configurez CORS pour autoriser uniquement vos domaines
   - N'envoyez jamais le token de réinitialisation dans la réponse HTTP
   - Utilisez HTTPS
   - Configurez un serveur WSGI (gunicorn, uwsgi)

2. **Variables d'environnement** :
   - Créez un fichier `.env` basé sur `.env.example`
   - Ne committez JAMAIS le fichier `.env` dans Git

3. **Mots de passe** :
   - Tous les mots de passe sont hashés avec bcrypt
   - Les mots de passe en clair ne sont jamais stockés

## 🐛 Dépannage

### Erreur de connexion à PostgreSQL

Vérifiez que :
- PostgreSQL est en cours d'exécution
- Les identifiants dans `database_config.py` sont corrects
- La base de données `kintana_project_GL` existe

### Erreur d'importation de modules

```bash
pip install -r requirements.txt
```

### Port 5000 déjà utilisé

Modifiez le port dans `app.py` :
```python
app.run(host='0.0.0.0', port=5001, debug=True)
```

## 📞 Support

Pour toute question ou problème, contactez l'équipe de développement.

---

**Version** : 1.0.0  
**Date** : Décembre 2025  
**Projet** : Kintana Project GL
