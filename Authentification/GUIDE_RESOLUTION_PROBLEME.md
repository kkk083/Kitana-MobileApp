# 🚨 GUIDE DE RÉSOLUTION - Communication Frontend/Backend

## ❌ PROBLÈME IDENTIFIÉ

1. ✅ L'API Flask tourne sur le port 5000
2. ❌ **La base de données PostgreSQL n'est PAS connectée**
3. ❌ Les fichiers Flutter n'ont pas été créés (bloqués par .gitignore)

---

## 🔧 SOLUTION ÉTAPE PAR ÉTAPE

### ÉTAPE 1 : Configurer la base de données ⚠️ CRITIQUE

#### Option A : PostgreSQL sans mot de passe

```bash
# Vérifier que PostgreSQL est démarré
# Vérifier dans les services Windows ou exécuter :
pg_ctl status

# Se connecter à PostgreSQL
psql -U postgres

# Créer/Vérifier la base de données
CREATE DATABASE kintana_project_GL;
\c kintana_project_GL

# Exécuter le script d'initialisation
\i c:/Users/rstev/Documents/DepotGit/kintana_project_GL/kintana_project_GL/repository/data_source/init_database.sql

# Vérifier que les tables existent
\dt

# Quitter
\q
```

#### Option B : PostgreSQL avec mot de passe

Si votre PostgreSQL a un mot de passe, créez un fichier `.env` :

**Fichier** : `c:\Users\rstev\Documents\DepotGit\kintana_project_GL\kintana_project_GL\.env`

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=kintana_project_GL
DB_USER=postgres
DB_PASSWORD=VOTRE_MOT_DE_PASSE_ICI
```

Puis installez python-dotenv :
```bash
pip install python-dotenv
```

---

### ÉTAPE 2 : Vérifier la connexion à la base de données

```bash
cd c:\Users\rstev\Documents\DepotGit\kintana_project_GL\kintana_project_GL
python repository/data_source/database_config.py
```

Vous DEVEZ voir :
```
✓ Connexion réussie à PostgreSQL
  Version: PostgreSQL XX.X ...
```

---

### ÉTAPE 3 : Redémarrer l'API Flask

**Arrêtez** le serveur Flask actuel (Ctrl+C dans le terminal) puis relancez :

```bash
python app.py
```

Vous DEVEZ voir :
```
✓ Connexion à la base de données établie
```

Testez dans le navigateur : http://localhost:5000/health

Réponse attendue :
```json
{
  "status": "healthy",
  "database": "connected",
  "api_version": "1.0.0"
}
```

---

### ÉTAPE 4 : Créer les fichiers Flutter

Les fichiers sont listés dans `CREER_FICHIERS_FLUTTER.md`.

#### 4.1 Installer les dépendances

```bash
cd view/flutter_application
flutter pub add http shared_preferences
flutter pub get
```

#### 4.2 Créer les 3 fichiers essentiels

**FICHIER 1** : `lib/services/api_config.dart`

```dart
class ApiConfig {
  // Pour Web/Chrome
  static const String baseUrl = 'http://localhost:5000/api/auth';
}
```

**FICHIER 2** : `lib/services/api_service.dart`

Copiez TOUT le code depuis `CREER_FICHIERS_FLUTTER.md` section "FICHIER 2"

**FICHIER 3** : `lib/widgets/custom_snackbar.dart`

Copiez TOUT le code depuis `CREER_FICHIERS_FLUTTER.md` section "FICHIER 3"

---

### ÉTAPE 5 : Modifier votre écran d'inscription

Ajoutez ces imports en haut :
```dart
import '../services/api_service.dart';
import '../widgets/custom_snackbar.dart';
```

Modifiez votre fonction d'inscription pour appeler l'API :

```dart
Future<void> _handleRegister() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  print('🚀 Envoi de l\'inscription...');
  
  final result = await ApiService.register(
    nom: _nomController.text.trim(),
    email: _emailController.text.trim(),
    password: _passwordController.text,
  );

  setState(() => _isLoading = false);

  print('📥 Résultat: ${result['success']}');

  if (result['success']) {
    if (mounted) {
      CustomSnackbar.success(context, result['message']);
      print('✅ Inscription réussie !');
    }
  } else {
    if (mounted) {
      CustomSnackbar.error(context, result['message']);
      print('❌ Erreur: ${result['message']}');
    }
  }
}
```

---

### ÉTAPE 6 : Tester l'inscription

1. **Relancez Flutter** :
   ```bash
   # Arrêtez Flutter (Ctrl+C)
   # Relancez
   flutter run -d chrome
   ```

2. **Ouvrez la console du navigateur** (F12 dans Chrome)

3. **Testez une inscription** avec :
   - Nom : `Jean Dupont`
   - Email : `jean@test.com`
   - Mot de passe : `Test1234`

4. **Regardez les logs** :
   - Dans la console Chrome (F12) → onglet Console
   - Dans le terminal Flask

---

## 🔍 DÉBOGAGE

### Test 1 : L'API fonctionne ?

```bash
curl http://localhost:5000/health
```

✅ Doit afficher : `"database": "connected"`
❌ Si `"database": "disconnected"` → Retournez à l'ÉTAPE 1

### Test 2 : L'inscription via curl fonctionne ?

```bash
curl -X POST http://localhost:5000/api/auth/register -H "Content-Type: application/json" -d "{\"nom\":\"Test\",\"email\":\"test@example.com\",\"password\":\"Test1234\"}"
```

✅ Doit afficher : `"success": true`

### Test 3 : Flutter peut atteindre l'API ?

Dans la console Chrome (F12), tapez :

```javascript
fetch('http://localhost:5000/health')
  .then(r => r.json())
  .then(console.log)
```

✅ Doit afficher l'objet JSON de santé

---

## 📋 CHECKLIST FINALE

- [ ] PostgreSQL est démarré
- [ ] La base `kintana_project_GL` existe
- [ ] Les tables `users` et `password_resets` existent
- [ ] `python repository/data_source/database_config.py` → ✅ succès
- [ ] `http://localhost:5000/health` → `"database": "connected"`
- [ ] Les 3 fichiers Flutter sont créés (`api_config.dart`, `api_service.dart`, `custom_snackbar.dart`)
- [ ] Les dépendances Flutter sont installées (`http`, `shared_preferences`)
- [ ] L'écran d'inscription appelle `ApiService.register()`
- [ ] Les logs s'affichent dans la console Chrome (F12)
- [ ] Les logs s'affichent dans le terminal Flask

---

## 🎯 RÉSULTAT ATTENDU

Quand vous cliquez sur "S'inscrire" :

1. **Console Chrome** : Vous voyez `🚀 Envoi de l'inscription...`
2. **Terminal Flask** : Vous voyez `POST /api/auth/register` avec le code 201
3. **Console Chrome** : Vous voyez `✅ Inscription réussie !`
4. **Interface Flutter** : Un Snackbar vert s'affiche avec "Inscription réussie !"
5. **Base de données** : Le nouvel utilisateur est inséré

---

## 🆘 SI ÇA NE MARCHE TOUJOURS PAS

Envoyez-moi :
1. Le résultat de `http://localhost:5000/health`
2. Les logs du terminal Flask
3. Les logs de la console Chrome (F12)
4. Le contenu de votre fonction `_handleRegister()`

---

**La clé est de vérifier que PostgreSQL est bien connecté avant tout !** ⚠️
