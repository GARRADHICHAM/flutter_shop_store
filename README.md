# MIAGED - Clothes Shopping App 👕

Une application Flutter moderne pour acheter et classifier des vêtements en utilisant l'intelligence artificielle (AWS Rekognition) et Firebase.

---

## � Identifiants de test

Pour tester l'application, vous pouvez utiliser les identifiants suivants:

| Utilisateur   | Identifiant | Mot de passe |
| ------------- | ----------- | ------------ |
| Utilisateur 1 | `user1`     | `password1`  |
| Utilisateur 2 | `user2`     | `password2`  |

---

## �📋 Table des matières

- [À propos du projet](#-à-propos-du-projet)
- [Fonctionnalités](#-fonctionnalités)
- [Prérequis](#-prérequis)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Utilisation](#-utilisation)
- [Architecture](#-architecture)
- [Informations techniques](#-informations-techniques)

---

## 🎯 À propos du projet

MIAGED est une application de shopping de vêtements qui intègre l'intelligence artificielle pour :

- **Classifier automatiquement** les vêtements uploadés via AWS Rekognition
- **Stocker les images** sur AWS S3
- **Gérer l'authentification** avec Firebase Authentication
- **Persister les données** avec Firestore

L'application offre une expérience utilisateur fluide avec un panier d'achat, des profils utilisateur et une boutique intégrée.

---

## ✨ Fonctionnalités

### 🤖 IA et Classification

- **Classification automatique des vêtements** : Upload une image et l'app détecte automatiquement le type de vêtement (T-shirt, pantalon, robe, etc.)
- **Intégration AWS Rekognition** : API puissante pour la vision par ordinateur
- **Upload sur AWS S3** : Stockage sécurisé et scalable des images

### 🛍️ Expérience Utilisateur

- **Écran d'accueil** : Découverte des produits
- **Boutique** : Catalogue des vêtements disponibles
- **Panier** : Gestion des articles à acheter
- **Profil utilisateur** : Gestion du compte
- **Page d'ajout** : Interface pour ajouter de nouveaux produits avec classification IA
- **Authentification** : Connexion sécurisée avec Firebase

### 💾 Backend

- **Firebase Authentication** : Gestion des utilisateurs
- **Firestore** : Base de données temps réel
- **AWS S3** : Stockage d'images
- **AWS Rekognition** : Classification d'images

---

## 🛠️ Prérequis

### Système

- **Flutter** : ^3.10.8 ou supérieur
- **Dart** : ^3.10.8 ou supérieur
- **iOS** : Xcode 14+ (pour tester sur iOS)
- **Android** : Android Studio avec SDK 31+

### Comptes requis

- Firebase Project
- AWS Account (pour Rekognition et S3)

### Device testé

L'application a été développée et testée sur:

- **Chrome** (Web) ✅ **Device principal utilisé**
- **Émulateur Android** (API 31+)
- **iPhone 14 Simulator** (iOS)

> ℹ️ **Note importante**: L'application fonctionne mieux sur **Chrome** (web). C'est le device principal recommandé pour tester l'application.

---

## 📥 Installation

### 1. Cloner le repository

```bash
git clone <your-repo-url>
cd clothes_app
```

### 2. Installer les dépendances Flutter

```bash
flutter pub get
```

### 3. Générer les fichiers Firebase (pour iOS/Android)

```bash
flutterfire configure
```

### 4. Lancer l'application

#### Sur le web (Chrome)

```bash
flutter run -d chrome
```

---

## ⚙️ Configuration

### Firebase Setup

1. Créer un projet Firebase sur [firebase.google.com](https://firebase.google.com)
2. Ajouter une application Flutter à votre projet
3. Télécharger les fichiers de configuration :
   - `GoogleService-Info.plist` pour iOS (placer dans `ios/Runner/`)
   - `google-services.json` pour Android (placer dans `android/app/`)
4. Générer le fichier `lib/firebase_options.dart` :
   ```bash
   flutterfire configure
   ```

### AWS Configuration

1. Créer un bucket S3 dans AWS :
   - Nom du bucket : `clothign-imgs-bucket`
   - Région : `eu-north-1`

2. Créer une fonction Lambda pour la classification avec Rekognition
   - Endpoint API : `https://xqap76lioe.execute-api.eu-north-1.amazonaws.com/detect-category`

3. Configurer les credentials AWS dans `lib/services/s3_upload_service.dart` :
   ```dart
   static const String _accessKey = 'YOUR_ACCESS_KEY';
   static const String _secretKey = 'YOUR_SECRET_KEY';
   static const String _region = 'eu-north-1';
   static const String _bucket = 'clothign-imgs-bucket';
   ```

### Firestore Rules

Configurer les règles Firestore pour autoriser la lecture/écriture :

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /products/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

---

## 🚀 Utilisation

### Workflows principaux

#### 1. Ajouter un produit avec classification IA

1. Naviguez vers la page "Ajouter" (add screen)
2. Cliquez sur le bouton pour prendre une photo ou sélectionner une image
3. L'image est envoyée à AWS S3
4. AWS Rekognition classifie automatiquement le type de vêtement
5. Le produit est sauvegardé dans Firestore avec sa classification

#### 2. Parcourir la boutique

1. Accédez à l'onglet "Boutique"
2. Découvrez les vêtements disponibles
3. Cliquez sur un article pour voir les détails

#### 3. Gérer le panier

1. Ajoutez des articles au panier depuis la boutique
2. Accédez au panier pour voir vos sélections
3. Modifiez les quantités ou supprimez des articles

#### 4. Gérer le profil

1. Consultez vos informations de profil
2. Déconnectez-vous si nécessaire

---

## 🏗️ Architecture

### Structure du projet

```
lib/
├── main.dart                    # Point d'entrée
├── firebase_options.dart        # Configuration Firebase
├── screens/
│   ├── home/                   # Écran d'accueil
│   ├── shop/                   # Boutique
│   ├── cart/                   # Panier
│   ├── profile/                # Profil utilisateur
│   ├── login/                  # Authentification
│   └── add/                    # Ajout de produits
└── services/
    ├── rekognition_service.dart  # Classification IA (AWS)
    └── s3_upload_service.dart    # Upload d'images (AWS)
```

### Flux de données

```
Image Upload → S3 Upload → Rekognition Classification → Firestore Save
```

---

## 📱 Informations techniques

### Dépendances principales

```yaml
flutter: SDK Flutter officiel
firebase_core: ^4.4.0 # Core Firebase
firebase_auth: ^6.1.4 # Authentification
cloud_firestore: ^6.1.2 # Base de données
image_picker: ^1.2.1 # Sélection d'images
http: ^1.1.0 # Requêtes HTTP
crypto: ^3.0.0 # Cryptographie (AWS Signatures)
```

### Versions

- **Flutter** : 3.10.8+
- **Dart** : 3.10.8+
- **Minimum SDK** : Android 31, iOS 11.0

### Services Cloud

- **Firebase** : Authentication, Firestore
- **AWS S3** : Stockage d'images
- **AWS Rekognition** : Classification d'images
- **AWS Lambda** : Endpoint de classification

---

## 🖼️ Images de classification

L'application utilise **AWS Rekognition** qui est entraîné sur des millions d'images incluant :

- Vêtements (T-shirts, pantalons, robes, etc.)
- Accessoires (chapeaux, sacs, etc.)
- Chaussures
- Et bien d'autres catégories

> ℹ️ Rekognition détecte automatiquement le type de vêtement sans nécessiter un modèle personnalisé.

---

## ⚡ Fonctionnalités supplémentaires

### Améliorations potentielles

- [ ] Système de paiement intégré (Stripe, PayPal)
- [ ] Recommandations personnalisées basées sur l'IA
- [ ] Recherche et filtres avancés
- [ ] Évaluations et avis utilisateurs
- [ ] Notifications push
- [ ] Mode hors ligne
- [ ] Tests unitaires et d'intégration complets

### Notes de développement

- L'authentification par défaut utilise l'ID `user1` pour les tests
- Les images uploadées sont stockées dans `products/{timestamp}.jpg` sur S3
- Les requêtes AWS utilisent la signature AWS v4

---

## 🐛 Troubleshooting

### L'app ne démarre pas

```bash
flutter clean
flutter pub get
flutter run
```

### Erreurs Firebase

- Vérifier que `firebase_options.dart` est généré correctement
- Vérifier les règles Firestore
- Vérifier que l'app est configurée dans Firebase Console

### Erreurs AWS

- Vérifier les credentials AWS dans `s3_upload_service.dart`
- Vérifier que le bucket S3 existe et est accessible
- Vérifier que l'endpoint Rekognition est correct

---

## 📞 Support

Pour toute question ou problème, veuillez consulter :

- [Documentation Flutter](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [AWS Rekognition Documentation](https://docs.aws.amazon.com/rekognition/)

---

## 📄 Licence

Ce projet est développé à titre éducatif.

---

**Dernière mise à jour** : Avril 2026

A new Flutter project.
