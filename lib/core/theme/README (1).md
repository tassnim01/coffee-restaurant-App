# Documentation des fichiers de design – Application Flutter Restaurant

Ce README explique les quatre fichiers étudiés : `app_colors.dart`, `app_text_styles.dart`, `app_theme.dart` et `category_icons.dart`.

## 1. Organisation proposée

```text
lib/
├── theme/
│   ├── app_colors.dart
│   ├── app_text_styles.dart
│   └── app_theme.dart
├── utils/
│   └── category_icons.dart
└── main.dart
```

Les chemins sont indicatifs : adaptez les imports à l'organisation réelle du projet.

## 2. `app_colors.dart` – Palette centralisée

La classe `AppColors` rassemble les couleurs utilisées dans l'application. Elle évite de répéter les codes hexadécimaux dans chaque page et facilite les modifications globales.

| Constante | Valeur | Utilisation |
|---|---|---|
| `black` | `#000000` | Noir |
| `forestGreen` | `#44693D` | Couleur principale, boutons, prix |
| `warmBeige` | `#D5C2A5` | Couleur secondaire |
| `burgundy` | `#7D221D` | Erreurs ou accents |
| `gray` | `#A3A3A8` | Textes secondaires, états inactifs |
| `background` | `#F6F0E6` | Fond des pages |
| `surface` | `#FBF8F2` | Fond des cartes et surfaces |
| `border` | `#E6DCC8` | Bordures |
| `chipBackground` | `#EADFCB` | Fond des étiquettes |
| `textPrimary` | `#1A1A1A` | Texte principal |
| `textSecondary` | `gray` | Texte secondaire |
| `darkPanel` | `#0E1A0F` | Panneau latéral sombre |

```dart
Container(color: AppColors.forestGreen)
```

- `static` : accès par le nom de la classe, sans créer d'objet.
- `const` : valeur constante.
- `AppColors._()` : constructeur privé, empêchant l'instanciation normale de cette classe utilitaire.
- `Color(0xFF44693D)` : `FF` indique l'opacité complète ; `44693D` est la couleur RGB.

## 3. `app_text_styles.dart` – Styles des textes

La classe `AppTextStyles` définit des styles réutilisables avec la police **Inter** du package `google_fonts`.

| Getter | Taille | Graisse | Couleur | Usage |
|---|---:|---|---|---|
| `screenTitle` | 18 | `w700` | `textPrimary` | Titre de page |
| `productName` | 15 | `w600` | `textPrimary` | Nom d'un produit |
| `price` | 13 | `w600` | `forestGreen` | Prix |
| `chip` | 11 | `w500` | `textPrimary` | Texte des catégories/filtres |
| `body` | 14 | `w400` | `textPrimary` | Texte courant |
| `hint` | 14 | `w400` | `gray` | Indication dans un champ de saisie |
| `button` | 14 | `w600` | Blanc | Texte de bouton |
| `toggle` | 14 | `w600` | Non précisée | Texte d'un sélecteur |

```dart
Text('Pizza Margherita', style: AppTextStyles.productName)
Text('25 DT', style: AppTextStyles.price)
TextField(
  decoration: InputDecoration(
    hintText: 'Rechercher un plat...',
    hintStyle: AppTextStyles.hint,
  ),
)
```

**Vocabulaire :** un *chip* est une petite étiquette, éventuellement interactive, utilisée pour une catégorie ou un filtre. Un *hint* est un texte indicatif qui apparaît dans un champ vide. Un *toggle* permet de basculer entre des états ou des choix ; ici, `toggle` désigne seulement le style du texte, pas le composant interactif lui-même.

`static TextStyle get price => ...` est un getter statique qui retourne un `TextStyle`. `w400` = normal, `w500` = medium, `w600` = semi-bold, `w700` = bold.

## 4. `app_theme.dart` – Thème global

`AppTheme.light` retourne un objet `ThemeData` qui configure l'apparence générale de l'application.

```dart
final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
return base.copyWith(/* personnalisations */);
```

- `useMaterial3: true` : utilise Material Design 3.
- `Brightness.light` : thème clair.
- `copyWith()` : conserve la configuration de base tout en remplaçant certaines propriétés.
- `scaffoldBackgroundColor` : fond beige clair des pages `Scaffold`.
- `ColorScheme.fromSeed(seedColor: AppColors.forestGreen)` : crée une palette à partir du vert, puis `copyWith` fixe certaines couleurs précisément.

| Couleur du schéma | Valeur | Signification |
|---|---|---|
| `primary` | `forestGreen` | Couleur principale |
| `onPrimary` | Blanc | Contenu posé sur le primaire |
| `secondary` | `warmBeige` | Couleur secondaire |
| `error` | `burgundy` | Erreurs |
| `surface` | `surface` | Surface des composants |
| `onSurface` | `textPrimary` | Contenu posé sur les surfaces |

### Autres réglages

**`textTheme`** applique Inter aux styles typographiques du thème et définit les couleurs des textes. À distinguer des styles métiers spécifiques de `AppTextStyles`.

**`switchTheme`** personnalise les interrupteurs ON/OFF : bouton mobile (*thumb*) blanc, piste (*track*) verte quand `WidgetState.selected` est présent et grise sinon, contour transparent. `WidgetStatePropertyAll` fournit la même valeur pour tous les états ; `resolveWith` permet de choisir selon l'état.

**`snackBarTheme`** configure les messages temporaires : flottants, fond noir, texte blanc Inter de taille 13, coins arrondis de rayon 12.

**`progressIndicatorTheme`** rend les indicateurs de chargement verts.

Pour activer le thème global dans `main.dart` :

```dart
MaterialApp(
  theme: AppTheme.light,
  home: const MenuPage(), // importer la page réelle
)
```

Le thème fournit des valeurs par défaut aux widgets concernés ; un style local explicite peut les remplacer.

## 5. `category_icons.dart` – Correspondance entre clés et icônes

La classe `CategoryIcons` centralise les icônes des catégories grâce à une `Map<String, IconData>` : une clé texte correspond à une icône Flutter.

| Clé | Icône Flutter |
|---|---|
| `coffee` | `Icons.local_cafe_outlined` |
| `drink` | `Icons.local_drink_outlined` |
| `fastfood` | `Icons.fastfood_outlined` |
| `dish` | `Icons.restaurant_outlined` |
| `dessert` | `Icons.cake_outlined` |

```dart
static IconData byKey(String key) =>
    icons[key] ?? Icons.category_outlined;
```

`icons[key]` recherche la clé ; l'opérateur `??` fournit l'icône générique si la recherche renvoie `null` (clé inconnue).

```dart
Icon(
  CategoryIcons.byKey('coffee'),
  color: AppColors.forestGreen,
)
```

**Pourquoi stocker une chaîne dans Firestore ?** `IconData` n'est pas un type directement stockable dans Firestore. On enregistre donc une clé simple, par exemple :

```json
{
  "name": "Coffee",
  "iconKey": "coffee"
}
```

Après lecture de la donnée, `CategoryIcons.byKey(iconKey)` retrouve l'icône à afficher. Une clé inconnue affiche `Icons.category_outlined`.

## 6. Comment les fichiers travaillent ensemble

```text
app_colors.dart ──────┬──> app_text_styles.dart
                      ├──> app_theme.dart ──> MaterialApp(theme: AppTheme.light)
                      └──> widgets / écrans
category_icons.dart ────────────────────────> icônes des catégories
```

- `AppColors` : **quelles couleurs ?**
- `AppTextStyles` : **quel aspect pour chaque type de texte ?**
- `AppTheme` : **quelles règles visuelles par défaut pour toute l'application ?**
- `CategoryIcons` : **quelle icône correspond à la clé reçue ?**

Cette séparation améliore la cohérence graphique, la réutilisation, la lisibilité et la maintenance du projet. Modifier une couleur ou un style partagé à un seul endroit met à jour les widgets qui le réutilisent lors de leur reconstruction.

## 7. Dépendance nécessaire

Le fichier des styles et le thème utilisent `google_fonts`. Ajouter le package au projet si nécessaire :

```bash
flutter pub add google_fonts
```

Les autres classes présentées utilisent Flutter Material.
