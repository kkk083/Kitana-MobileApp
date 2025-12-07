# Interface d'Authentification Kintana

## 📱 Description

Cette interface d'authentification Flutter reproduit exactement le design fourni avec :

- **Fond beige/pêche** (#EFCBB3)
- **Logo doré** avec icône étoile
- **Formulaire de connexion** élégant et moderne
- **Navigation** entre Connexion et Inscription
- **Gestion des erreurs** avec messages d'alerte
- **Design responsive** et adaptatif

## 🎨 Caractéristiques du Design

### Palette de Couleurs
- **Fond principal** : `#EFCBB3` (Beige/Pêche)
- **Couleur primaire** : `#B8956A` (Doré)
- **Boutons actifs** : `#CCAA7F` (Doré clair)
- **Champ email** : `#E8EEF7` (Bleu clair)
- **Bordures** : `#E5E5E5` (Gris clair)

### Éléments de l'Interface
- ✨ **Logo** : Icône étoile dans un conteneur doré arrondi
- 📝 **Titre** : "KINTANA" en lettres capitales dorées
- 💫 **Sous-titre** : "Car nous sommes tous enfants des étoiles"
- 🔄 **Onglets** : Connexion / Inscription avec animation
- 📧 **Champ Email** : Avec icône et placeholder
- 🔒 **Champ Mot de passe** : Avec icône et toggle visibilité
- ⚠️ **Messages d'erreur** : Zone rouge pour "Failed to fetch"
- 🔘 **Bouton principal** : "Se connecter" en doré
- 🔗 **Lien** : "Mot de passe oublié ?"

## 📁 Structure du Projet

```
lib/
├── main.dart                 # Point d'entrée de l'application
└── screens/
    └── auth_screen.dart     # Écran d'authentification
```

## 🚀 Utilisation

### Lancer l'Application

```bash
# Depuis le répertoire du projet
cd flutter_application

# Installer les dépendances
flutter pub get

# Lancer l'application
flutter run
```

### Tests

```bash
# Exécuter les tests
flutter test
```

## 💡 Fonctionnalités Implémentées

### Frontend (UI seulement)

- [x] Interface de connexion
- [x] Basculement Connexion/Inscription
- [x] Champ email avec validation visuelle
- [x] Champ mot de passe avec toggle visibilité
- [x] Message d'erreur "Failed to fetch"
- [x] Bouton "Se connecter"
- [x] Lien "Mot de passe oublié"
- [x] Design responsive
- [x] Animations et transitions fluides

### À Implémenter (Backend)

- [ ] Connexion à une API backend
- [ ] Validation des champs (email, mot de passe)
- [ ] Gestion de l'authentification
- [ ] Navigation vers écran principal après connexion
- [ ] Récupération de mot de passe
- [ ] Inscription de nouveaux utilisateurs

## 🔧 Personnalisation

### Modifier les Couleurs

Dans `auth_screen.dart`, vous pouvez modifier les couleurs :

```dart
// Fond de l'application
backgroundColor: const Color(0xFFEFCBB3)

// Couleur du logo et des boutons
color: const Color(0xFFB8956A)

// Couleur des boutons actifs
color: const Color(0xFFCCAA7F)
```

### Ajouter la Logique Backend

Dans la méthode `_buildConnectButton()`, remplacez le code par votre logique :

```dart
onPressed: () {
  // Remplacer ceci :
  setState(() {
    errorMessage = 'Failed to fetch';
  });
  
  // Par votre logique, par exemple :
  // await authService.login(
  //   _emailController.text,
  //   _passwordController.text,
  // );
},
```

## 📝 Notes Importantes

- **Frontend seulement** : Cette interface ne contient aucune logique backend
- **Responsive** : L'interface s'adapte à différentes tailles d'écran
- **Prêt pour intégration** : Les contrôleurs de texte sont déjà configurés
- **État géré** : Utilisation de StatefulWidget pour la gestion d'état

## 🎯 Prochaines Étapes

1. Intégrer un service d'authentification (Firebase, API REST, etc.)
2. Ajouter la validation des champs
3. Implémenter la navigation vers d'autres écrans
4. Ajouter des animations supplémentaires
5. Implémenter la fonctionnalité d'inscription
6. Ajouter la récupération de mot de passe

## 📸 Aperçu

L'interface reproduit exactement le design fourni avec :
- Logo KINTANA avec icône étoile
- Formulaire centré sur fond beige
- Champs de saisie stylisés
- Boutons avec design moderne
- Message d'erreur intégré
