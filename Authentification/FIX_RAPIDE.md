# 🚨 SOLUTION RAPIDE - Frontend ne communique pas avec Backend

## ❌ PROBLÈME IDENTIFIÉ

L'API affiche : `"database": "disconnected"`

**La base de données PostgreSQL n'est PAS configurée !**

C'est pour ça que le frontend ne peut pas communiquer avec le backend.

---

## ✅ SOLUTION EN 2 MINUTES

### **ÉTAPE 1 : Configurer PostgreSQL**

#### Option A : Mot de passe vide (plus simple)

Si votre PostgreSQL n'a pas de mot de passe :

```bash
# 1. Créez le fichier .env
echo DB_PASSWORD= > .env

# 2. Dans un nouveau terminal PowerShell :
psql -U postgres -c "CREATE DATABASE kintana_project_gl;"
psql -U postgres -d kintana_project_gl -f repository/data_source/init_database.sql
```

#### Option B : Avec mot de passe

```bash
# Dans le terminal qui exécute setup_database.py :
# Entrez votre mot de passe PostgreSQL quand demandé
# (Le script fait tout automatiquement)
```

---

### **ÉTAPE 2 : Redémarrer l'API**

Dans le terminal où `python app.py` tourne :

1. Appuyez sur **Ctrl + C** pour arrêter
2. Relancez :

```bash
python app.py
```

Vous DEVEZ voir maintenant :
```
✓ Connexion à la base de données établie
```

---

### **ÉTAPE 3 : Copier les fichiers Flutter**

**Les fichiers sont dans `flutter_files/` mais ne sont PAS dans votre projet Flutter !**

#### Avec PowerShell (dans le répertoire du projet) :

```powershell
# Créer les dossiers si nécessaire
New-Item -ItemType Directory -Force -Path "view\flutter_application\lib\services"
New-Item -ItemType Directory -Force -Path "view\flutter_application\lib\widgets"

# Copier les fichiers
Copy-Item "flutter_files\api_config.dart" "view\flutter_application\lib\services\"
Copy-Item "flutter_files\api_service.dart" "view\flutter_application\lib\services\"
Copy-Item "flutter_files\custom_snackbar.dart" "view\flutter_application\lib\widgets\"

# Vérifier
dir "view\flutter_application\lib\services\"
dir "view\flutter_application\lib\widgets\"
```

Vous devez voir :
- `api_config.dart`
- `api_service.dart`
- `custom_snackbar.dart`

---

### **ÉTAPE 4 : Installer les dépendances Flutter**

```bash
cd view/flutter_application
flutter pub add http shared_preferences
flutter pub get
```

---

### **ÉTAPE 5 : Redémarrer Flutter**

Dans le terminal où `flutter run -d chrome` tourne :

1. Appuyez sur **r** (hot reload) ou **R** (hot restart)
2. Ou arrêtez (Ctrl + C) et relancez : `flutter run -d chrome`

---

## 🔍 **VÉRIFICATION**

### Test 1 : L'API est connectée ?

Navigateur : http://localhost:5000/health

✅ Résultat attendu :
```json
{
  "database": "connected",  ← Doit être "connected" !
  "status": "healthy"
}
```

### Test 2 : Les fichiers Flutter existent ?

```powershell
dir view\flutter_application\lib\services\api_service.dart
dir view\flutter_application\lib\services\api_config.dart
dir view\flutter_application\lib\widgets\custom_snackbar.dart
```

Chaque commande doit trouver le fichier.

### Test 3 : L'inscription fonctionne ?

```bash
curl -X POST http://localhost:5000/api/auth/register -H "Content-Type: application/json" -d "{\"nom\":\"Test\",\"email\":\"test@example.com\",\"password\":\"Test1234\"}"
```

✅ Résultat attendu : `"success": true`

---

## 📱 **UTILISER DANS VOS ÉCRANS FLUTTER**

Une fois les fichiers copiés, dans votre écran d'inscription (`register_screen.dart` ou similaire) :

### 1. Ajouter les imports (en haut du fichier)

```dart
import '../services/api_service.dart';
import '../widgets/custom_snackbar.dart';
```

### 2. Remplacer votre fonction d'inscription

```dart
Future<void> _handleRegister() async {
  // Validation du formulaire
  if (!_formKey.currentState!.validate()) return;
  
  // Afficher le loading
  setState(() => _isLoading = true);
  
  // Appeler l'API
  final result = await ApiService.register(
    nom: _nomController.text.trim(),
    email: _emailController.text.trim(),
    password: _passwordController.text,
  );
  
  // Masquer le loading
  setState(() => _isLoading = false);
  
  // Afficher le résultat
  if (result['success']) {
    if (mounted) {
      CustomSnackbar.success(context, result['message']);
      // Optionnel : naviguer vers une autre page
      // Navigator.pushReplacementNamed(context, '/home');
    }
  } else {
    if (mounted) {
      CustomSnackbar.error(context, result['message']);
    }
  }
}
```

### 3. Utiliser cette fonction dans votre bouton

```dart
ElevatedButton(
  onPressed: _isLoading ? null : _handleRegister,
  child: _isLoading
      ? CircularProgressIndicator()
      : Text('S\'inscrire'),
)
```

---

## 🐛 **SI ÇA NE MARCHE TOUJOURS PAS**

### Vérifiez dans la console Chrome (F12) :

1. Ouvrez votre app Flutter dans Chrome
2. Appuyez sur **F12** pour ouvrir les outils développeur
3. Allez dans l'onglet **Console**
4. Essayez de vous inscrire
5. Regardez les messages :

✅ **Si vous voyez** :
```
📤 Envoi inscription: nom=..., email=...
📥 Réponse reçue: 201
✅ Token sauvegardé
```
→ **Ça marche !**

❌ **Si vous voyez** :
```
❌ Erreur: ...
```
→ Copiez le message d'erreur et envoyez-le moi

### Vérifiez les logs de l'API :

Dans le terminal où `python app.py` tourne, vous devriez voir :
```
127.0.0.1 - - [07/Dec/2025 00:xx:xx] "POST /api/auth/register HTTP/1.1" 201 -
```

---

## 📋 **CHECKLIST FINALE**

```
□ PostgreSQL est démarré
□ Base de données kintana_project_gl créée
□ Tables users et password_resets créées
□ Fichier .env créé (même si vide)
□ python app.py redémarré
□ http://localhost:5000/health → "connected"
□ Fichiers Flutter copiés dans lib/
□ flutter pub add http shared_preferences
□ Imports ajoutés dans vos écrans
□ Fonction _handleRegister() mise à jour
□ flutter run -d chrome relancé
□ F12 ouvert pour voir les logs
```

---

## 🎯 **RÉSUMÉ**

**Le problème** : PostgreSQL n'est PAS configuré  
**La solution** : Configurer PostgreSQL + Copier les fichiers Flutter

**Une fois fait, vous verrez** :
- ✅ Snackbar vert "Inscription réussie !"
- ✅ Logs dans F12 : `📤 📥 ✅`
- ✅ Nouvel utilisateur dans la base de données

---

**COMMENCEZ PAR CONFIGURER POSTGRESQL (ÉTAPE 1) !** 🚀
