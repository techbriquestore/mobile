# Guide Flutter - Comment ça fonctionne

## 1. Qu'est-ce que Flutter ?

**Flutter** est un framework open-source créé par Google pour développer des applications **multiplateformes** (Android, iOS, Web, Windows, macOS, Linux) à partir d'un **seul code source**.

### Avantages principaux
- **Un seul code** pour toutes les plateformes
- **Hot Reload** : voir les changements instantanément
- **Performances natives** : compilation en code machine
- **UI personnalisable** : widgets riches et flexibles
- **Grande communauté** et écosystème de packages

---

## 2. Architecture de Flutter

```
┌─────────────────────────────────────────────────────────┐
│                    Ton Application                      │
│                   (Code Dart/Flutter)                   │
├─────────────────────────────────────────────────────────┤
│                    Framework Flutter                    │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐   │
│  │   Widgets   │ │  Rendering  │ │    Animation    │   │
│  └─────────────┘ └─────────────┘ └─────────────────┘   │
├─────────────────────────────────────────────────────────┤
│                      Engine (C++)                       │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────┐   │
│  │    Skia     │ │    Dart     │ │   Text Layout   │   │
│  │  (Graphique)│ │   Runtime   │ │                 │   │
│  └─────────────┘ └─────────────┘ └─────────────────┘   │
├─────────────────────────────────────────────────────────┤
│              Plateforme (Android/iOS/Web)               │
└─────────────────────────────────────────────────────────┘
```

### Composants clés

| Composant | Rôle |
|-----------|------|
| **Dart** | Langage de programmation utilisé par Flutter |
| **Widgets** | Blocs de construction de l'interface utilisateur |
| **Skia** | Moteur graphique 2D pour le rendu |
| **Engine** | Cœur C++ qui gère le rendu et la communication plateforme |

---

## 3. Le langage Dart

Flutter utilise **Dart**, un langage moderne créé par Google.

### Caractéristiques
```dart
// Variables typées
String nom = "BRIQUES.STORE";
int quantite = 100;
double prix = 1500.50;
bool enStock = true;

// Null safety (sécurité contre les valeurs nulles)
String? description; // Peut être null
String titre = "Brique"; // Ne peut PAS être null

// Fonctions
double calculerTotal(int quantite, double prixUnitaire) {
  return quantite * prixUnitaire;
}

// Fonctions fléchées (raccourci)
double calculerTVA(double montant) => montant * 0.18;

// Classes
class Produit {
  final String nom;
  final double prix;
  
  Produit({required this.nom, required this.prix});
}

// Async/Await (opérations asynchrones)
Future<List<Produit>> chargerProduits() async {
  final response = await api.get('/products');
  return response.data;
}
```

---

## 4. Les Widgets - Cœur de Flutter

**Tout est Widget** dans Flutter. Un widget est un élément d'interface.

### Types de Widgets

#### StatelessWidget (Sans état)
Ne change pas après sa création.

```dart
class MonBouton extends StatelessWidget {
  final String texte;
  
  const MonBouton({required this.texte});
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: Text(texte),
    );
  }
}
```

#### StatefulWidget (Avec état)
Peut changer dynamiquement.

```dart
class Compteur extends StatefulWidget {
  @override
  State<Compteur> createState() => _CompteurState();
}

class _CompteurState extends State<Compteur> {
  int _compte = 0;
  
  void _incrementer() {
    setState(() {  // Déclenche la reconstruction du widget
      _compte++;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Compte: $_compte'),
        ElevatedButton(
          onPressed: _incrementer,
          child: Text('Ajouter'),
        ),
      ],
    );
  }
}
```

### Widgets courants

| Widget | Description |
|--------|-------------|
| `Container` | Boîte avec padding, margin, couleur, etc. |
| `Row` | Disposition horizontale |
| `Column` | Disposition verticale |
| `Stack` | Superposition d'éléments |
| `ListView` | Liste scrollable |
| `Text` | Afficher du texte |
| `Image` | Afficher une image |
| `TextField` | Champ de saisie |
| `ElevatedButton` | Bouton surélevé |
| `Scaffold` | Structure de page (AppBar, Body, etc.) |

---

## 5. Structure d'un projet Flutter

```
mon_projet/
├── lib/                    # Code source Dart
│   ├── main.dart          # Point d'entrée
│   ├── core/              # Code partagé
│   │   ├── constants/     # Constantes
│   │   ├── theme/         # Thème de l'app
│   │   ├── network/       # API client
│   │   └── utils/         # Utilitaires
│   ├── features/          # Fonctionnalités
│   │   ├── auth/          # Authentification
│   │   ├── catalog/       # Catalogue produits
│   │   └── cart/          # Panier
│   └── shared/            # Widgets partagés
├── assets/                 # Images, fonts, etc.
├── android/               # Code natif Android
├── ios/                   # Code natif iOS
├── web/                   # Configuration web
├── test/                  # Tests
├── pubspec.yaml           # Dépendances et config
└── README.md
```

---

## 6. pubspec.yaml - Configuration du projet

```yaml
name: briques_store
description: Application de vente de briques

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^3.2.1
  
  # Navigation
  go_router: ^17.1.0
  
  # Réseau
  dio: ^5.9.1
  
  # UI
  shimmer: ^3.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.1.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
  
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
```

---

## 7. Navigation avec GoRouter

```dart
// Définition des routes
final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ProductDetailScreen(productId: id);
      },
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => CartScreen(),
    ),
  ],
);

// Naviguer vers une page
context.go('/product/123');
context.push('/cart');
context.pop(); // Retour
```

---

## 8. Gestion d'état avec Riverpod

Riverpod permet de gérer l'état de l'application de manière réactive.

```dart
// Définir un provider
final compteurProvider = StateProvider<int>((ref) => 0);

// Provider pour données async
final produitsProvider = FutureProvider<List<Produit>>((ref) async {
  final api = ref.watch(apiClientProvider);
  return await api.getProduits();
});

// Utiliser dans un widget
class MonWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compteur = ref.watch(compteurProvider);
    final produits = ref.watch(produitsProvider);
    
    return produits.when(
      data: (liste) => ListView.builder(
        itemCount: liste.length,
        itemBuilder: (ctx, i) => Text(liste[i].nom),
      ),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => Text('Erreur: $err'),
    );
  }
}

// Modifier l'état
ref.read(compteurProvider.notifier).state++;
```

---

## 9. Appels API avec Dio

```dart
class ApiClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.briques.store/v1',
    connectTimeout: Duration(seconds: 15),
  ));
  
  Future<List<Produit>> getProduits() async {
    final response = await _dio.get('/products');
    return (response.data as List)
        .map((json) => Produit.fromJson(json))
        .toList();
  }
  
  Future<void> creerCommande(Commande commande) async {
    await _dio.post('/orders', data: commande.toJson());
  }
}
```

---

## 10. Cycle de vie d'un Widget

```
┌─────────────────────────────────────────┐
│            createState()                │  ← Widget créé
└─────────────────┬───────────────────────┘
                  ▼
┌─────────────────────────────────────────┐
│             initState()                 │  ← Initialisation
└─────────────────┬───────────────────────┘
                  ▼
┌─────────────────────────────────────────┐
│         didChangeDependencies()         │  ← Dépendances changées
└─────────────────┬───────────────────────┘
                  ▼
┌─────────────────────────────────────────┐
│              build()                    │  ← Construction UI
└─────────────────┬───────────────────────┘
                  ▼
         ┌────────┴────────┐
         │   setState()    │  ← Mise à jour → retour à build()
         └────────┬────────┘
                  ▼
┌─────────────────────────────────────────┐
│             dispose()                   │  ← Nettoyage
└─────────────────────────────────────────┘
```

---

## 11. Commandes Flutter essentielles

```bash
# Créer un projet
flutter create mon_app

# Lancer l'app
flutter run                    # Sur appareil connecté
flutter run -d chrome          # Sur Chrome
flutter run -d windows         # Sur Windows

# Hot Reload (pendant l'exécution)
r                              # Recharger à chaud
R                              # Redémarrer complètement

# Gérer les dépendances
flutter pub get                # Installer les packages
flutter pub add nom_package    # Ajouter un package
flutter pub remove nom_package # Retirer un package

# Générer du code (freezed, json_serializable)
dart run build_runner build --delete-conflicting-outputs

# Analyser le code
flutter analyze

# Tester
flutter test

# Construire pour production
flutter build apk              # Android APK
flutter build appbundle        # Android App Bundle
flutter build ios              # iOS
flutter build web              # Web
```

---

## 12. Structure Clean Architecture (ce projet)

```
lib/
├── core/                      # Couche transversale
│   ├── constants/            # Constantes API, app
│   ├── errors/               # Gestion des erreurs
│   ├── network/              # Client API
│   ├── theme/                # Thème et styles
│   ├── router/               # Navigation
│   └── di/                   # Injection de dépendances
│
├── features/                  # Fonctionnalités (par domaine)
│   └── auth/                 # Exemple: Authentification
│       ├── data/             # Couche données
│       │   ├── datasources/  # Sources (API, local)
│       │   ├── models/       # Modèles JSON
│       │   └── repositories/ # Implémentation repos
│       ├── domain/           # Couche métier
│       │   ├── entities/     # Entités pures
│       │   ├── repositories/ # Interfaces repos
│       │   └── usecases/     # Cas d'utilisation
│       └── presentation/     # Couche UI
│           ├── screens/      # Écrans
│           ├── widgets/      # Widgets spécifiques
│           └── providers/    # State management
│
└── shared/                    # Widgets réutilisables
    ├── widgets/
    └── layouts/
```

---

## 13. Ressources pour apprendre

- **Documentation officielle** : [flutter.dev/docs](https://flutter.dev/docs)
- **Dart** : [dart.dev](https://dart.dev)
- **Packages** : [pub.dev](https://pub.dev)
- **Codelabs** : [flutter.dev/codelabs](https://flutter.dev/codelabs)
- **YouTube** : Flutter Official Channel

---

## 14. Résumé

| Concept | Description |
|---------|-------------|
| **Widget** | Élément d'interface (tout est widget) |
| **StatelessWidget** | Widget sans état, ne change pas |
| **StatefulWidget** | Widget avec état, peut changer |
| **setState()** | Déclenche la reconstruction du widget |
| **BuildContext** | Contexte de l'arbre de widgets |
| **Provider/Riverpod** | Gestion d'état réactive |
| **GoRouter** | Navigation déclarative |
| **Dio** | Client HTTP pour les API |
| **Hot Reload** | Rechargement instantané du code |

---

*Document créé pour le projet BRIQUES.STORE - Février 2026*
