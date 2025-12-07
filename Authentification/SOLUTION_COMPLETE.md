# 🚀 GUIDE COMPLET - TOUT RÉSOUDRE EN 5 MINUTES

## ✅ TOUS LES FICHIERS SONT CRÉÉS ET PRÊTS !

---

## 📦 CE QUI A ÉTÉ CRÉÉ POUR VOUS

### Backend (Python/Flask)
- ✅ `setup_database.py` - Script de configuration automatique de la BDD
- ✅ `START_ALL.bat` - Script de démarrage automatique complet
- ✅ `controller/change_password_controller.py` - Endpoint modification mot de passe simple
- ✅ Mise à jour de `database_config.py` pour charger le .env

### Frontend (Flutter)
- ✅ `flutter_files/api_config.dart` - Configuration API
- ✅ `flutter_files/api_service.dart` - Service API complet avec logs
- ✅ `flutter_files/custom_snackbar.dart` - Widget messages succès/erreur

---

## 🎯 SOLUTION EN 3 ÉTAPES

### **ÉTAPE 1 : Configurer la base de données** (2 minutes)

#### Option A : Utiliser le script automatique ⭐ RECOMMANDÉ

```bash
cd c:\Users\rstev\Documents\DepotGit\kintana_project_GL\kintana_project_GL
python setup_database.py
```

Le script va :
1. ✅ Demander votre mot de passe PostgreSQL
2. ✅ Tester la connexion
3. ✅ Créer la base de données `kintana_project_gl`
4. ✅ Créer les tables `users` et `password_resets`
5. ✅ Sauvegarder la config dans `.env`
6. ✅ Installer python-dotenv

**C'est AUTOMATIQUE !**

#### Option B : Manuel

```bash
# 1. Se connecter à PostgreSQL
psql -U postgres

# 2. Dans psql :
CREATE DATABASE kintana_project_gl;
\c kintana_project_gl

# 3. Exécuter le script
\i 'c:/Users/rstev/Documents/DepotGit/kintana_project_GL/kintana_project_GL/repository/data_source/init_database.sql'

# 4. Vérifier
\dt
# Vous devez voir : users, password_resets

# 5. Quitter
\q
```

Puis créez `.env` manuellement :
```env
DB_PASSWORD=VOTRE_MOT_DE_PASSE
```

---

### **ÉTAPE 2 : Démarrer le backend** (30 secondes)

```bash
cd c:\Users\rstev\Documents\DepotGit\kintana_project_GL\kintana_project_GL
python app.py
```

**Vérifiez que ça marche** :
- Ouvrez http://localhost:5000/health dans votre navigateur
- Vous DEVEZ voir : `"database": "connected"`

---

### **ÉTAPE 3 : Copier les fichiers Flutter** (1 minute)

Les fichiers sont dans `flutter_files/`. Copiez-les dans votre projet :

```
flutter_files/api_config.dart 
  → Copiez vers: view/flutter_application/lib/services/api_config.dart

flutter_files/api_service.dart
  → Copiez vers: view/flutter_application/lib/services/api_service.dart

flutter_files/custom_snackbar.dart
  → Copiez vers: view/flutter_application/lib/widgets/custom_snackbar.dart
```

**Puis** :

```bash
cd view/flutter_application
flutter pub add http shared_preferences
flutter pub get
```

---

## 🎨 UTILISER DANS VOS ÉCRANS FLUTTER

### Dans votre écran d'inscription

Ajoutez les imports :
```dart
import '../services/api_service.dart';
import '../widgets/custom_snackbar.dart';
```

Fonction d'inscription :
```dart
Future<void> _handleRegister() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  final result = await ApiService.register(
    nom: _nomController.text.trim(),
    email: _emailController.text.trim(),
    password: _passwordController.text,
  );

  setState(() => _isLoading = false);

  if (result['success']) {
    if (mounted) {
      CustomSnackbar.success(context, result['message']);
      // Optionnel : Navigator.pushReplacementNamed(context, '/home');
    }
  } else {
    if (mounted) {
      CustomSnackbar.error(context, result['message']);
    }
  }
}
```

### Dans votre écran de connexion

```dart
Future<void> _handleLogin() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  final result = await ApiService.login(
    email: _emailController.text.trim(),
    password: _passwordController.text,
  );

  setState(() => _isLoading = false);

  if (result['success']) {
    if (mounted) {
      CustomSnackbar.success(context, result['message']);
      // Navigator.pushReplacementNamed(context, '/home');
    }
  } else {
    if (mounted) {
      CustomSnackbar.error(context, result['message']);
    }
  }
}
```

### Dans votre écran de modification de mot de passe

```dart
Future<void> _handleChangePassword() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  final result = await ApiService.changePassword(
    currentPassword: _currentPasswordController.text,
    newPassword: _newPasswordController.text,
  );

  setState(() => _isLoading = false);

  if (result['success']) {
    if (mounted) {
      CustomSnackbar.success(context, result['message']);
      Navigator.pop(context); // Retour
    }
  } else {
    if (mounted) {
      CustomSnackbar.error(context, result['message']);
    }
  }
}
```

---

## 🧪 TESTER QUE TOUT FONCTIONNE

### Test 1 : Backend

```bash
# Terminal 1
python app.py

# Navigateur
http://localhost:5000/health
# Résultat attendu : "database": "connected", "status": "healthy"
```

### Test 2 : Inscription via curl

```bash
curl -X POST http://localhost:5000/api/auth/register -H "Content-Type: application/json" -d "{\"nom\":\"Test User\",\"email\":\"test@example.com\",\"password\":\"Test1234\"}"
```

Résultat attendu :
```json
{
  "success": true,
  "message": "Inscription réussie",
  "user": {...}
}
```

### Test 3 : Flutter

```bash
# Terminal 2
cd view/flutter_application
flutter run -d chrome
```

Ouvrez F12 (console du navigateur) et testez une inscription.

**Dans la console**, vous devriez voir :
```
📤 Envoi inscription: nom=..., email=...
📥 Réponse reçue: 201
✅ Token sauvegardé
✅ User sauvegardé: ...
```

**Sur l'interface**, vous devriez voir :
- Un Snackbar vert avec "Inscription réussie !"

---

## 📊 MESSAGES D'ERREUR/SUCCÈS AUTOMATIQUES

Tous les messages viennent **directement de la base de données** :

| Situation | Message |
|-----------|---------|
| ✅ Inscription OK | "Inscription réussie" |
| ❌ Email existe | "Cet email est déjà utilisé" |
| ❌ Mot de passe faible | "Le mot de passe doit contenir au moins 8 caractères" |
| ❌ Serveur down | "Impossible de se connecter au serveur" |
| ✅ Connexion OK | "Connexion réussie" |
| ❌ Login incorrect | "Email ou mot de passe incorrect" |
| ✅ Mot de passe modifié | "Mot de passe modifié avec succès" |
| ❌ Ancien mot de passe faux | "Mot de passe actuel incorrect" |

---

## 🔍 DÉBOGAGE

### Problème : "database disconnected"

```bash
# Vérifiez que PostgreSQL est démarré
# Relancez setup_database.py
python setup_database.py
```

### Problème : Flutter ne se connecte pas

1. Vérifiez que l'API tourne : http://localhost:5000/health
2. Ouvrez F12 dans Chrome → onglet Console
3. Regardez les logs (📤, 📥, ❌, ✅)
4. Vérifiez l'URL dans `api_config.dart` : doit être `http://localhost:5000/api/auth`

### Problème : "Token missing" lors de changePassword

Vous devez être connecté (avoir un token) pour changer le mot de passe.
Faites d'abord une connexion.

---

## ✅ CHECKLIST FINALE

- [ ] PostgreSQL est démarré
- [ ] `python setup_database.py` → ✅ succès
- [ ] `.env` créé avec le mot de passe
- [ ] `python app.py` → ✅ API démarrée
- [ ] http://localhost:5000/health → `"connected"`
- [ ] Les 3 fichiers Flutter copiés dans `lib/`
- [ ] `flutter pub add http shared_preferences`
- [ ] Les imports ajoutés dans les écrans
- [ ] Les fonctions `_handleRegister()`, etc. mises à jour
- [ ] `flutter run -d chrome`
- [ ] Test d'inscription → ✅ Snackbar vert !

---

## 🎉 RÉSULTAT FINAL

Quand tout est configuré :

1. **Inscription** : Données envoyées à l'API → Sauvegardées en BDD → Message "Inscription réussie !"
2. **Connexion** : Email/password vérifiés en BDD → Token généré → Message "Connexion réussie !"
3. **Modification mot de passe** : Ancien mot de passe vérifié → Nouveau sauvegardé en BDD → Message "Mot de passe modifié avec succès"

**Toutes les erreurs sont gérées et affichées automatiquement !**

---

## 🆘 EN CAS DE PROBLÈME

Envoyez-moi :
1. Le résultat de `http://localhost:5000/health`
2. Les logs du terminal Python
3. Les logs de la console Chrome (F12)
4. Les messages d'erreur exacts

---

**TOUT EST PRÊT ! IL SUFFIT DE SUIVRE LES 3 ÉTAPES CI-DESSUS !** 🚀
