# FirebaseOrderRepository – Gestion des commandes

## Rôle du fichier

`firebase_order_repository.dart` implémente le contrat `OrderRepository` pour communiquer avec **Cloud Firestore**. Il utilise la collection **`orders`** afin de consulter les commandes en temps réel et de modifier leur statut.

## Méthodes principales

| Méthode | Rôle |
|---|---|
| `_fromDoc()` | Convertit un document Firestore en objet `RestaurantOrder`, notamment son horodatage. |
| `watchOrders()` | Écoute les commandes en temps réel avec `snapshots()`, triées de la plus récente à la plus ancienne. |
| `updateStatus(orderId, status)` | Modifie le statut d'une commande et enregistre `updatedAt` avec l'heure du serveur. |
| `_item(productId, quantity)` | Construit un article de commande à partir des produits fictifs de `MockMenuData`. |
| `seedIfEmpty()` | Ajoute six commandes de démonstration uniquement si la collection `orders` est vide. |

## Notions à retenir

- **`Stream` / `snapshots()`** : permettent de recevoir les changements Firestore en temps réel.
- **`Timestamp` / `toDate()`** : convertissent la date Firestore en `DateTime` Dart.
- **`FieldValue.serverTimestamp()`** : enregistre la date de modification côté serveur.
- **`batch.set()` / `batch.commit()`** : préparent et exécutent plusieurs écritures de manière atomique.
- **`seedIfEmpty()`** : sert aux tests ; elle doit être appelée explicitement et retirée du parcours normal quand l'application client créera de vraies commandes.

## À retenir pour la présentation

> `FirebaseOrderRepository` assure la gestion des commandes dans Cloud Firestore. Il permet leur consultation en temps réel, la mise à jour de leurs statuts et l'initialisation de données fictives pour tester l'application.

**Remarque :** contrairement au menu géré par `MockMenuRepository`, les écritures de ce repository sont réellement envoyées à Firestore lorsqu'elles sont exécutées avec succès. Ce fichier ne contient pas encore de méthode de création d'une vraie commande client : `seedIfEmpty()` crée seulement des données de démonstration.
