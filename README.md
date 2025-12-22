# 🌟 KINTANA - Application Mobile

**KINTANA** est une application mobile éducative sur les menstruations, combinant un système d'authentification sécurisé et un chatbot intelligent propulsé par l'IA.

> *"Car nous sommes tous enfants des étoiles"*

---

## 📱 Fonctionnalités

### ✨ Authentification
- Inscription et connexion sécurisées
- Persistance des sessions utilisateur

### 🤖 Chatbot IA
- Assistant conversationnel sur l'endométriose
- Réponses basées sur des sources médicales fiables
- Détection des informations sensibles pour la sécurité des utilisateurs
- Interface moderne et intuitive

---

## 🛠️ Technologies

### Frontend
- **Flutter** - Framework multi-plateforme
- **Dart** - Langage de programmation

### Backend
- **Flask** - Framework Python
- **PostgreSQL** - Base de données
- **Google Gemini AI** - Intelligence artificielle

---

## 🚀 Installation

### Prérequis
- Flutter SDK (>= 3.9.2)
- Python (>= 3.12)
- PostgreSQL (>= 14)

### Backend
```bash
cd Authentification

# Installer les dépendances Python
pip install -r requirements.txt

# Configurer la base de données
# 1. Créer la base 'kintana_project_GL' dans PostgreSQL
# 2. Exécuter le script SQL d'initialisation

# Configurer les variables d'environnement
cp .env.example .env
# Éditer .env avec vos configurations

# Lancer le serveur
python app.py
```

### Frontend
```bash
cd Authentification/view/flutter_application

# Installer les dépendances Flutter
flutter pub get

# Lancer l'application
flutter run
```

---

## 📖 Utilisation

1. **Inscription** : Créez un compte étudiant
2. **Connexion** : Accédez à l'application
3. **Chatbot** : Posez vos questions sur l'endométriose
4. **Déconnexion** : Utilisez le bouton de déconnexion en haut à droite

---

## 👥 Équipe de Développement

- **Amy** - Dév ecosysteme du chat
- **Bryan** - Développeur : authentification
- **Jean Paul** - Analyste : modelisation
- **Emie** - Analyste modelisation
- **Junior** - Développeur : Integration chatbot et auth + corrections des bugs

---

## 📄 Licence

Ce projet est développé dans un cadre éducatif.

---

## 🔐 Sécurité

- Les mots de passe sont hashés avec bcrypt
- Protection contre les injections SQL
- Détection automatique des informations personnelles
- Alertes pour contenus sensibles

---

## 📞 Support

Pour toute question ou problème, contactez l'équipe de développement.

---

**Développé par l'équipe KINTANA**
