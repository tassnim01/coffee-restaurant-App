import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

enum OrderStatus { received, preparing, ready, delivered }

OrderStatus orderStatusFromKey(String? key) => OrderStatus.values.firstWhere(
  (s) => s.name == key,
  orElse: () => OrderStatus.received,
);

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.received:
        return 'Reçue';
      case OrderStatus.preparing:
        return 'En cours';
      case OrderStatus.ready:
        return 'Prête';
      case OrderStatus.delivered:
        return 'Livrée';
    }
  }

  OrderStatus? get next {
    switch (this) {
      case OrderStatus.received:
        return OrderStatus.preparing;
      case OrderStatus.preparing:
        return OrderStatus.ready;
      case OrderStatus.ready:
        return OrderStatus.delivered;
      case OrderStatus.delivered:
        return null;
    }
  }

  String? get actionLabel {
    switch (this) {
      case OrderStatus.received:
        return 'Démarrer la préparation';
      case OrderStatus.preparing:
        return 'Marquer comme prête';
      case OrderStatus.ready:
        return 'Marquer comme livrée';
      case OrderStatus.delivered:
        return null;
    }
  }

  String get trackingTitle {
    switch (this) {
      case OrderStatus.received:
        return 'Votre commande a bien été reçue';
      case OrderStatus.preparing:
        return 'Votre commande est en cours\nde préparation';
      case OrderStatus.ready:
        return 'Votre commande est prête';
      case OrderStatus.delivered:
        return 'Votre commande a été livrée';
    }
  }

  String get trackingSubtitle {
    switch (this) {
      case OrderStatus.received:
        return 'Elle sera prise en charge très vite.';
      case OrderStatus.preparing:
        return 'Elle sera prête bientôt !';
      case OrderStatus.ready:
        return 'Elle peut être récupérée à la caisse.';
      case OrderStatus.delivered:
        return 'Bon appétit !';
    }
  }

  IconData get trackingIcon {
    switch (this) {
      case OrderStatus.received:
        return Icons.receipt_long_outlined;
      case OrderStatus.preparing:
        return Icons.soup_kitchen_outlined;
      case OrderStatus.ready:
        return Icons.room_service_outlined;
      case OrderStatus.delivered:
        return Icons.verified_outlined;
    }
  }

  Color get background {
    switch (this) {
      case OrderStatus.received:
        return AppColors.burgundy.withValues(alpha: 0.12);
      case OrderStatus.preparing:
        return AppColors.warmBeige.withValues(alpha: 0.75);
      case OrderStatus.ready:
        return AppColors.forestGreen.withValues(alpha: 0.16);
      case OrderStatus.delivered:
        return AppColors.gray.withValues(alpha: 0.28);
    }
  }

  Color get foreground {
    switch (this) {
      case OrderStatus.received:
        return AppColors.burgundy;
      case OrderStatus.preparing:
        return AppColors.textPrimary;
      case OrderStatus.ready:
        return AppColors.forestGreen;
      case OrderStatus.delivered:
        return const Color(0xFF5E5E63);
    }
  }
}

/// Onglets de l'écran "Gestion des commandes".
enum OrderTab { all, received, inProgress, ready, delivered }

extension OrderTabX on OrderTab {
  String get label {
    switch (this) {
      case OrderTab.all:
        return 'Toutes';
      case OrderTab.received:
        return 'Reçues';
      case OrderTab.inProgress:
        return 'En cours';
      case OrderTab.ready:
        return 'Prêtes';
      case OrderTab.delivered:
        return 'Livrées';
    }
  }

  bool includes(OrderStatus status) {
    switch (this) {
      case OrderTab.all:
        return true;
      case OrderTab.received:
        return status == OrderStatus.received;
      case OrderTab.inProgress:
        return status == OrderStatus.preparing;
      case OrderTab.ready:
        return status == OrderStatus.ready;
      case OrderTab.delivered:
        return status == OrderStatus.delivered;
    }
  }
}
