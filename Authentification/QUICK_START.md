# 🎯 Guide de démarrage rapide - Kintana Project GL

Ce guide vous permet de démarrer rapidement avec le projet.

## ⚡ Démarrage en 5 minutes

### Étape 1 : Vérifier les prérequis

Assurez-vous d'avoir installé :
- ✅ Python 3.8+ : `python --version`
- ✅ PostgreSQL 12+ : `psql --version`
- ✅ pip : `pip --version`

### Étape 2 : Installer les dépendances

```powershell
pip install -r requirements.txt
```

### Étape 3 : Initialiser la base de données

**Option A : Via psql (ligne de commande)**

```powershell
# Se connecter à PostgreSQL
psql -U postgres

# Dans psql, exécuter :
CREATE DATABASE kintana_project_GL;
\q

# Initialiser les tables
psql -U postgres -d kintana_project_GL -f repository/data_source/init_database.sql
```

**Option B : Via pgAdmin (interface graphique)**

1. Ouvrir pgAdmin
2. Se connecter à votre serveur PostgreSQL (par défaut : localhost)
3. Clic droit sur "Databases" → "Create" → "Database..."
4. Nom : `kintana_project_GL`
5. Cliquer sur "Save"
6. Sélectionner la base `kintana_project_GL`
7. Clic droit → "Query Tool"
8. Ouvrir le fichier `repository/data_source/init_database.sql`
9. Copier tout le contenu et coller dans l'éditeur
10. Cliquer sur ▶ "Execute/Refresh" (ou F5)

✅ Vous devriez voir un message de confirmation avec 2 utilisateurs créés

### Étape 4 : Démarrer l'API

```powershell
python app.py
```

✅ L'API devrait démarrer sur `http://localhost:5000`

Vous devriez voir :
```
============================================================
🚀 Démarrage de l'API d'authentification Kintana Project
============================================================
✓ Connexion à la base de données établie

📡 L'API sera accessible sur: http://localhost:5000
📚 Documentation des endpoints: http://localhost:5000/
```

### Étape 5 : Tester l'API

**Option A : Via navigateur**

Ouvrir : http://localhost:5000/

Vous devriez voir la liste des endpoints disponibles.

**Option B : Via script de test**

Dans un nouveau terminal :

```powershell
python test_api.py
```

✅ Ce script testera tous les endpoints automatiquement

**Option C : Test manuel**

```powershell
# Test de connexion
curl -X POST http://localhost:5000/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"test@example.com\",\"password\":\"Test1234\"}'
```

## 📱 Démarrer le Frontend Flutter

Dans un autre terminal :

```powershell
cd view/flutter_application
flutter pub get
flutter run
```

Sélectionnez votre appareil (émulateur Android/iOS ou navigateur Chrome).

## 🔑 Comptes de test

Deux comptes sont créés automatiquement :

| Email | Mot de passe | Rôle |
|-------|--------------|------|
| test@example.com | Test1234 | Utilisateur |
| admin@kintana.com | Test1234 | Admin |

## 🎨 Interface Flutter

L'interface Flutter comprend :
- 📝 **Écran d'inscription** : Créer un nouveau compte
- 🔐 **Écran de connexion** : Se connecter
- 🔄 **Mot de passe oublié** : Réinitialiser le mot de passe

## 🧪 Tester les fonctionnalités

### 1. Inscription

Dans l'app Flutter ou via curl :

```powershell
curl -X POST http://localhost:5000/api/auth/register `
  -H "Content-Type: application/json" `
  -d '{
    \"email\":\"nouveau@example.com\",
    \"username\":\"nouveau_user\",
    \"password\":\"Test1234\",
    \"first_name\":\"Nouveau\",
    \"last_name\":\"Utilisateur\"
  }'
```

### 2. Connexion

```powershell
curl -X POST http://localhost:5000/api/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"test@example.com\",\"password\":\"Test1234\"}'
```

Récupérez le `token` dans la réponse.

### 3. Profil utilisateur

```powershell
curl -X GET http://localhost:5000/api/auth/profile `
  -H "Authorization: Bearer VOTRE_TOKEN_ICI"
```

### 4. Réinitialisation de mot de passe

```powershell
# Demander un token
curl -X POST http://localhost:5000/api/auth/forgot-password `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"test@example.com\"}'

# Utiliser le token pour réinitialiser
curl -X POST http://localhost:5000/api/auth/reset-password `
  -H "Content-Type: application/json" `
  -d '{
    \"token\":\"TOKEN_RECU\",
    \"new_password\":\"NewPassword123\"
  }'
```

## 🛠️ Dépannage rapide

### ❌ Erreur : "Connection refused" ou "Unable to connect"

**Cause** : PostgreSQL n'est pas démarré

**Solution** :
```powershell
# Windows - Démarrer PostgreSQL
net start postgresql-x64-14
```

### ❌ Erreur : "database does not exist"

**Cause** : La base de données n'a pas été créée

**Solution** :
```powershell
psql -U postgres -c "CREATE DATABASE kintana_project_GL;"
psql -U postgres -d kintana_project_GL -f repository/data_source/init_database.sql
```

### ❌ Erreur : "relation 'users' does not exist"

**Cause** : Les tables n'ont pas été créées

**Solution** :
```powershell
psql -U postgres -d kintana_project_GL -f repository/data_source/init_database.sql
```

### ❌ Erreur : "No module named 'flask'"

**Cause** : Dépendances Python non installées

**Solution** :
```powershell
pip install -r requirements.txt
```

### ❌ Erreur : "Port 5000 already in use"

**Cause** : Un autre processus utilise le port 5000

**Solution** :
```powershell
# Trouver le processus
netstat -ano | findstr :5000

# Tuer le processus (remplacer PID par le numéro)
taskkill /PID <PID> /F

# OU changer le port dans app.py
```

### ❌ L'API démarre mais pas de connexion à la base

**Causes possibles** :
1. Mauvais mot de passe PostgreSQL
2. PostgreSQL n'accepte pas les connexions locales

**Solution** :
1. Vérifier le mot de passe dans `database_config.py` ligne 15
2. Vérifier `pg_hba.conf` de PostgreSQL

## 📊 Vérifier que tout fonctionne

### ✅ Checklist complète

Cochez chaque élément :

- [ ] PostgreSQL est démarré
- [ ] Base de données `kintana_project_GL` créée
- [ ] Tables créées (users, password_resets)
- [ ] Dépendances Python installées
- [ ] API démarre sans erreur sur port 5000
- [ ] Page http://localhost:5000/ affiche la liste des endpoints
- [ ] Test de connexion avec compte test réussit
- [ ] Script `test_api.py` s'exécute sans erreur

Si tous les points sont cochés : **🎉 Félicitations, tout est prêt !**

## 📚 Documentation complète

- **README.md** : Vue d'ensemble du projet
- **API_DOCUMENTATION.md** : Documentation détaillée de l'API
- **COMMANDS.md** : Guide de toutes les commandes utiles

## 🚀 Prochaines étapes

1. **Personnaliser** : Modifier les couleurs et le style dans Flutter
2. **Sécuriser** : Changer les clés secrètes dans `.env`
3. **Étendre** : Ajouter de nouvelles fonctionnalités
4. **Déployer** : Préparer pour la production

## 💡 Astuces

- **Arrêter l'API** : Ctrl + C dans le terminal
- **Recharger l'API** : L'API se recharge automatiquement en mode debug
- **Voir les logs** : Tous les logs s'affichent dans le terminal
- **Base de données** : Utilisez pgAdmin pour visualiser les données

## 📞 Besoin d'aide ?

1. Consultez **COMMANDS.md** pour les commandes utiles
2. Consultez **API_DOCUMENTATION.md** pour la doc de l'API
3. Vérifiez la section Dépannage ci-dessus
4. Contactez l'équipe de développement

---

**Bon développement ! 🚀**
