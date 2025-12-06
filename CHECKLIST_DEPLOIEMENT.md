# ✅ Checklist de Déploiement

## 📋 Étapes à suivre pour déployer les changements

---

## 🔴 **ÉTAPE 1 : Sauvegarde (CRITIQUE)**

- [ ] **Sauvegarder la base de données actuelle**
  ```bash
  pg_dump -U postgres kintana_project_GL > backup_$(date +%Y%m%d_%H%M%S).sql
  ```

- [ ] **Sauvegarder le code actuel**
  ```bash
  git add .
  git commit -m "Sauvegarde avant migration structure BDD"
  git push
  ```

---

## 🟡 **ÉTAPE 2 : Recréer la base de données**

- [ ] **Se connecter à PostgreSQL**
  ```bash
  psql -U postgres
  ```

- [ ] **Supprimer et recréer la base de données**
  ```sql
  DROP DATABASE IF EXISTS kintana_project_GL;
  CREATE DATABASE kintana_project_GL;
  \q
  ```

- [ ] **Exécuter le script d'initialisation**
  ```bash
  psql -U postgres -d kintana_project_GL -f repository/data_source/init_database.sql
  ```

- [ ] **Vérifier la création des tables**
  ```bash
  psql -U postgres -d kintana_project_GL -c "\dt"
  psql -U postgres -d kintana_project_GL -c "SELECT * FROM users;"
  ```

---

## 🟢 **ÉTAPE 3 : Tester le backend**

- [ ] **Installer les dépendances (si nécessaire)**
  ```bash
  pip install -r requirements.txt
  ```

- [ ] **Démarrer le serveur API**
  ```bash
  python app.py
  ```
  OU
  ```powershell
  .\start_api.ps1
  ```

- [ ] **Dans un autre terminal, lancer les tests**
  ```bash
  python test_api.py
  ```

- [ ] **Vérifier que tous les tests passent** ✅
  - Health Check
  - Inscription
  - Connexion
  - Vérification Token
  - Profil
  - Demande Reset
  - Réinitialisation
  - Check Email

---

## 🔵 **ÉTAPE 4 : Mettre à jour le frontend (Flutter)**

### Si vous avez un frontend Flutter existant :

- [ ] **Mettre à jour le modèle User**
  ```dart
  class User {
    final int idUser;  // Changé de 'id'
    final String nom;  // Changé de 'username'
    final String email;
    final DateTime dateCreation;  // Changé de 'createdAt'
    
    // Supprimer : username, firstName, lastName, isActive, isVerified, etc.
  }
  ```

- [ ] **Mettre à jour le formulaire d'inscription**
  ```dart
  // AVANT
  {
    "email": email,
    "username": username,
    "password": password,
    "first_name": firstName,
    "last_name": lastName
  }
  
  // APRÈS
  {
    "nom": nom,
    "email": email,
    "password": password
  }
  ```

- [ ] **Mettre à jour l'affichage des profils**
  - Remplacer `user.username` par `user.nom`
  - Remplacer `user.id` par `user.idUser`
  - Supprimer les références à firstName, lastName, etc.

- [ ] **Supprimer les validations de username**
  - Retirer les champs username des formulaires
  - Retirer les validateurs de username

- [ ] **Tester le frontend**
  - Inscription ✅
  - Connexion ✅
  - Affichage profil ✅
  - Réinitialisation mot de passe ✅

---

## 🟣 **ÉTAPE 5 : Documentation**

- [ ] **Lire le rapport de migration**
  - Fichier : `MIGRATION_REPORT.md`
  - Comprendre tous les changements

- [ ] **Lire la liste des erreurs corrigées**
  - Fichier : `ERREURS_CORRIGEES.md`
  - Vérifier que tout est corrigé

- [ ] **Mettre à jour l'API documentation si nécessaire**
  - Fichier : `API_DOCUMENTATION.md`

---

## ⚫ **ÉTAPE 6 : Validation finale**

### Tests manuels via Postman/Insomnia :

#### Test 1 : Inscription
- [ ] **POST** `http://localhost:5000/api/auth/register`
  ```json
  {
    "nom": "Jean Dupont",
    "email": "jean@example.com",
    "password": "Test1234"
  }
  ```
  - Vérifier : Status 201 ✅
  - Vérifier : `user.id_user` existe ✅
  - Vérifier : `user.nom` = "Jean Dupont" ✅
  - Vérifier : Réception du token ✅

#### Test 2 : Connexion
- [ ] **POST** `http://localhost:5000/api/auth/login`
  ```json
  {
    "email": "jean@example.com",
    "password": "Test1234"
  }
  ```
  - Vérifier : Status 200 ✅
  - Vérifier : Réception du token ✅

#### Test 3 : Profil
- [ ] **GET** `http://localhost:5000/api/auth/profile`
  - Header : `Authorization: Bearer <token>`
  - Vérifier : Status 200 ✅
  - Vérifier : Données utilisateur correctes ✅

#### Test 4 : Mot de passe oublié
- [ ] **POST** `http://localhost:5000/api/auth/forgot-password`
  ```json
  {
    "email": "jean@example.com"
  }
  ```
  - Vérifier : Status 200 ✅
  - Vérifier : Réception du token ✅

#### Test 5 : Réinitialisation
- [ ] **POST** `http://localhost:5000/api/auth/reset-password`
  ```json
  {
    "token": "<reset_token>",
    "new_password": "NewPass123"
  }
  ```
  - Vérifier : Status 200 ✅

#### Test 6 : Connexion avec nouveau mot de passe
- [ ] **POST** `http://localhost:5000/api/auth/login`
  ```json
  {
    "email": "jean@example.com",
    "password": "NewPass123"
  }
  ```
  - Vérifier : Status 200 ✅

---

## 🟤 **ÉTAPE 7 : Vérification base de données**

- [ ] **Vérifier les données en base**
  ```sql
  -- Vérifier la structure
  \d users
  \d password_resets
  
  -- Vérifier les données
  SELECT id_user, nom, email, date_creation FROM users;
  SELECT id, user_id, token, expires_at, is_used FROM password_resets;
  ```

- [ ] **Vérifier les contraintes**
  ```sql
  -- Vérifier les foreign keys
  SELECT
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name 
  FROM information_schema.table_constraints AS tc 
  JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
  JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
  WHERE tc.constraint_type = 'FOREIGN KEY';
  ```

---

## ✅ **ÉTAPE 8 : Commit final**

- [ ] **Vérifier que tout fonctionne**
- [ ] **Commiter les changements**
  ```bash
  git add .
  git commit -m "Migration structure BDD : users et password_resets"
  git push
  ```

- [ ] **Créer un tag de version**
  ```bash
  git tag -a v2.0.0 -m "Migration nouvelle structure BDD"
  git push origin v2.0.0
  ```

---

## 📝 **Notes importantes**

⚠️ **ATTENTION** : Cette migration est **BREAKING**

- Les données existantes dans `users` seront **PERDUES**
- Les tokens JWT existants resteront **VALIDES** (même structure id_user/email)
- Les applications frontend devront être **MISES À JOUR**

---

## 🆘 **En cas de problème**

### Problème : Les tests échouent
```bash
# Vérifier les logs du serveur
# Vérifier la connexion à la base de données
psql -U postgres -d kintana_project_GL -c "SELECT 1"
```

### Problème : Erreur de connexion BDD
```python
# Vérifier le fichier .env
# Vérifier database_config.py
# Vérifier que PostgreSQL est démarré
```

### Rollback complet
```bash
# Restaurer la sauvegarde
psql -U postgres -d kintana_project_GL < backup_YYYYMMDD_HHMMSS.sql

# Revenir au commit précédent
git reset --hard HEAD~1
```

---

## 📊 **Critères de succès**

- ✅ Tous les tests automatiques passent
- ✅ Tests manuels réussis
- ✅ Base de données conforme à la nouvelle structure
- ✅ Aucune erreur dans les logs
- ✅ Frontend mis à jour (si applicable)
- ✅ Documentation à jour

---

**🎉 Une fois toutes les cases cochées, la migration est TERMINÉE !**
