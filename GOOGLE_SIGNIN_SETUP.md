# Configuration Google Sign-In pour BRIKE.STORE

## ✅ Code Flutter implémenté

L'authentification Google est maintenant intégrée dans l'application Flutter :
- Package `google_sign_in` installé
- Méthode `signInWithGoogle()` dans AuthService
- Boutons Google fonctionnels sur login_screen et register_screen
- Backend endpoint `/auth/google` déjà configuré

## 🔧 Configuration requise par plateforme

### 1. **Web (Chrome/Edge)**

Le Google Sign-In fonctionne **déjà** sur Web sans configuration supplémentaire grâce au package `google_sign_in_web`.

**Pour tester :**
```bash
flutter run -d chrome
```

### 2. **Android**

#### Étape 1 : Obtenir le SHA-1 de votre keystore

```bash
# Debug keystore (développement)
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Production keystore
keytool -list -v -keystore /path/to/your/keystore.jks -alias your-alias
```

#### Étape 2 : Configurer Google Cloud Console

1. Allez sur [Google Cloud Console](https://console.cloud.google.com/)
2. Sélectionnez votre projet (ou créez-en un)
3. Activez **Google+ API**
4. Allez dans **Credentials** → **Create Credentials** → **OAuth 2.0 Client ID**
5. Type : **Android**
6. Package name : `com.briquestore.app` (vérifiez dans `android/app/build.gradle`)
7. Collez le **SHA-1** obtenu à l'étape 1
8. Créez le client ID

#### Étape 3 : Mettre à jour android/app/build.gradle

Vérifiez que le package name correspond :
```gradle
defaultConfig {
    applicationId "com.briquestore.app"
    ...
}
```

### 3. **iOS**

#### Étape 1 : Configurer Google Cloud Console

1. Dans **Credentials**, créez un **OAuth 2.0 Client ID**
2. Type : **iOS**
3. Bundle ID : `com.briquestore.app` (vérifiez dans `ios/Runner.xcodeproj`)
4. Notez le **iOS URL scheme** généré (format : `com.googleusercontent.apps.XXXXXXX`)

#### Étape 2 : Mettre à jour ios/Runner/Info.plist

Ajoutez avant `</dict></plist>` :

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Remplacez par votre iOS URL scheme -->
            <string>com.googleusercontent.apps.XXXXXXX-XXXXXXX</string>
        </array>
    </dict>
</array>
```

#### Étape 3 : Mettre à jour ios/Runner/AppDelegate.swift

```swift
import UIKit
import Flutter
import GoogleSignIn

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey : Any] = [:]
  ) -> Bool {
    return GIDSignIn.sharedInstance.handle(url)
  }
}
```

## 🔑 Variables d'environnement Backend

Vérifiez que votre backend a ces variables dans `.env` :

```env
GOOGLE_CLIENT_ID=votre-client-id.apps.googleusercontent.com
```

Le `GOOGLE_CLIENT_ID` doit être le **Web client ID** de Google Cloud Console.

## 🧪 Test de l'authentification Google

### Sur Web (Chrome)
```bash
cd flutter
flutter run -d chrome
```

1. Cliquez sur "Continuer avec Google"
2. Sélectionnez un compte Google
3. L'app doit vous connecter et rediriger vers `/home`

### Sur Android
```bash
flutter run -d <device-id>
```

### Sur iOS
```bash
flutter run -d <device-id>
```

## 🐛 Dépannage

### Erreur "PlatformException(sign_in_failed)"
- Vérifiez que le SHA-1 est correct dans Google Cloud Console
- Vérifiez que le package name correspond
- Nettoyez et rebuilder : `flutter clean && flutter pub get`

### Erreur "idpiframe_initialization_failed" (Web)
- Vérifiez que le domaine est autorisé dans Google Cloud Console
- Ajoutez `http://localhost:PORT` dans les origines autorisées

### Token invalide côté backend
- Vérifiez que `GOOGLE_CLIENT_ID` dans le backend correspond au Web client ID
- Le backend utilise `google-auth-library` pour valider les tokens

## 📝 Notes importantes

1. **Développement** : Utilisez le debug keystore SHA-1 pour Android
2. **Production** : Créez un nouveau OAuth client avec le SHA-1 de votre keystore de production
3. **Multi-plateforme** : Vous pouvez avoir plusieurs OAuth clients (Web, Android, iOS) pour le même projet
4. Le backend accepte les tokens de **tous** les clients OAuth configurés (Web, Android, iOS)

## 🔗 Liens utiles

- [Google Cloud Console](https://console.cloud.google.com/)
- [google_sign_in package](https://pub.dev/packages/google_sign_in)
- [Documentation Google Sign-In](https://developers.google.com/identity/sign-in/web/sign-in)
