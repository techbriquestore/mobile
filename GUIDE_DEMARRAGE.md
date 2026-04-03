#  Guide de Démarrage BRIQUES.STORE

##  Pourquoi l'écran reste bloqué sur "BRIQUES.STORE" ?

L'application Flutter essaie de se connecter au **backend NestJS** pour vérifier si vous êtes déjà connecté. Si le backend n'est pas démarré ou n'est pas accessible, l'écran de chargement reste bloqué.

---

##  Solution : Démarrer le Backend AVANT l'Application

### Étape 1 : Démarrer le Backend NestJS

Ouvrez un **premier terminal** et exécutez :

```powershell
cd "c:\Users\OFFO ANGE EMMANUEL\Desktop\BRIKE.STORE\backend"
npm run start:dev
```

**Attendez** de voir ce message :
```
[Nest] LOG [NestApplication] Nest application successfully started
Application is running on: http://localhost:3000
```

### Étape 2 : Vérifier que le Backend fonctionne

Dans un navigateur, allez sur :
```
http://localhost:3000/api/v1/health
```

Vous devriez voir une réponse JSON (ou un message de bienvenue).

### Étape 3 : Lancer l'Application Flutter

Ouvrez un **deuxième terminal** et exécutez :

```powershell
cd "c:\Users\OFFO ANGE EMMANUEL\Desktop\BRIKE.STORE\flutter"
flutter run -d emulator-5554
```

---

##  Configuration Requise

### Variables d'environnement Backend (.env)

Le fichier `backend/.env` doit contenir :

```env
# Base de données PostgreSQL
DATABASE_URL="postgresql://user:password@localhost:5432/briques_store?schema=public"

# JWT
JWT_SECRET="votre-secret-jwt-tres-long-et-securise"
JWT_EXPIRES_IN="15m"
JWT_REFRESH_SECRET="votre-refresh-secret-tres-long"
JWT_REFRESH_EXPIRES_IN="7d"

# Google OAuth (optionnel pour l'instant)
GOOGLE_CLIENT_ID="votre-google-client-id.apps.googleusercontent.com"

# Port
PORT=3000
```

### Base de données PostgreSQL

1. **Installer PostgreSQL** si ce n'est pas fait
2. **Créer la base de données** :
   ```sql
   CREATE DATABASE briques_store;
   ```
3. **Appliquer les migrations Prisma** :
   ```powershell
   cd backend
   npx prisma migrate dev
   npx prisma generate
   ```

---

##  Architecture de l'Application

```
BRIKE.STORE/
├── backend/                 # API NestJS
│   ├── src/
│   │   ├── modules/
│   │   │   ├── auth/       # Authentification (login, register, Google OAuth)
│   │   │   ├── users/      # Gestion des utilisateurs
│   │   │   ├── products/   # Catalogue produits
│   │   │   ├── orders/     # Commandes
│   │   │   ├── payments/   # Paiements
│   │   │   └── promotions/ # Promotions
│   │   └── ...
│   └── prisma/             # Schéma de base de données
│
└── flutter/                 # Application Mobile
    ├── lib/
    │   ├── core/           # Configuration, API, Router
    │   ├── features/       # Fonctionnalités (auth, home, catalog, orders...)
    │   └── shared/         # Widgets partagés
    └── ...
```

---

##  Flux d'Authentification

### Au démarrage de l'app :

1. **Splash Screen** s'affiche
2. L'app vérifie si des **tokens sont stockés** localement
3. Si oui → Appel API `GET /users/me` pour valider le token
4. Si token valide → Redirection vers **Home**
5. Si pas de token ou token invalide → Redirection vers **Login**

### Problème actuel :

L'étape 3 **bloque** car le backend n'est pas accessible :
- Soit le backend n'est pas démarré
- Soit la base de données n'est pas configurée
- Soit l'émulateur ne peut pas atteindre `localhost:3000`

---

##  Dépannage

### L'écran reste bloqué sur le logo

**Cause** : Le backend n'est pas accessible

**Solutions** :
1. Vérifiez que le backend est démarré (`npm run start:dev`)
2. Vérifiez que PostgreSQL est en cours d'exécution
3. Vérifiez les logs du backend pour des erreurs

### Erreur de connexion à la base de données

**Cause** : PostgreSQL n'est pas configuré

**Solution** :
```powershell
# Vérifier que PostgreSQL est installé et démarré
# Créer la base de données
# Configurer DATABASE_URL dans .env
# Exécuter les migrations
cd backend
npx prisma migrate dev
```

### L'émulateur ne peut pas atteindre le backend

**Cause** : L'émulateur Android utilise une adresse IP spéciale

**Note** : L'app est déjà configurée pour utiliser `10.0.2.2:3000` qui est l'équivalent de `localhost` pour l'émulateur Android.

---

##  Tester sur différentes plateformes

### Android Emulator
```powershell
flutter run -d emulator-5554
```
L'app utilise `http://10.0.2.2:3000/api/v1` (équivalent de localhost)

### Chrome (Web)
```powershell
flutter run -d chrome
```
L'app utilise `http://localhost:3000/api/v1`

### Appareil physique Android
Modifiez `api_constants.dart` pour utiliser l'IP de votre PC :
```dart
static const String baseUrl = 'http://192.168.x.x:3000/api/v1';
```

---

##  Checklist de Démarrage

- [ ] PostgreSQL installé et démarré
- [ ] Base de données `briques_store` créée
- [ ] Fichier `backend/.env` configuré
- [ ] Migrations Prisma appliquées (`npx prisma migrate dev`)
- [ ] Backend démarré (`npm run start:dev`)
- [ ] Backend accessible (`http://localhost:3000`)
- [ ] Flutter app lancée (`flutter run`)

---

##  Besoin d'aide ?

Si le problème persiste :

1. **Vérifiez les logs du backend** dans le terminal
2. **Vérifiez les logs Flutter** dans la console
3. **Testez l'API manuellement** avec Postman ou curl :
   ```bash
   curl http://localhost:3000/api/v1/auth/health
   ```

---

##  Commandes Utiles

```powershell
# Backend
cd backend
npm run start:dev          # Démarrer en mode développement
npx prisma studio          # Interface graphique pour la DB
npx prisma migrate dev     # Appliquer les migrations
npx prisma generate        # Régénérer le client Prisma

# Flutter
cd flutter
flutter run -d chrome      # Lancer sur Chrome
flutter run -d emulator-5554  # Lancer sur émulateur Android
flutter clean              # Nettoyer le build
flutter pub get            # Installer les dépendances
```
