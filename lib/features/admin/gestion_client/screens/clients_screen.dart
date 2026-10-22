import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../menu/widgets/menu_search_field.dart';
import '../models/restaurant_client.dart';
import '../providers/client_provider.dart';
import '../widgets/client_card.dart';
import '../widgets/client_form_sheet.dart';

class ClientsScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const ClientsScreen({super.key, this.onMenuTap});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String _query = '';

  void _showInfo(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openForm([RestaurantClient? client]) async {
    final provider = context.read<ClientsProvider>();
    final result = await showClientFormSheet(
      context,
      client: client,
      isPhoneTaken: (phone) =>
          provider.phoneExists(phone, excludeId: client?.id),
    );
    if (result == null || !mounted) return;
    try {
      if (client == null) {
        await provider.addClient(result);
        if (mounted) _showInfo('Client ajouté.');
      } else {
        await provider.updateClient(result);
        if (mounted) _showInfo('Client modifié.');
      }
    } catch (_) {
      if (mounted) _showInfo("Erreur lors de l'enregistrement.");
    }
  }

  Future<void> _confirmDelete(RestaurantClient client) async {
    final provider = context.read<ClientsProvider>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Supprimer le client',
      message: 'Voulez-vous vraiment supprimer "${client.name}" ?',
    );
    if (!confirmed || !mounted) return;
    try {
      await provider.deleteClient(client.id);
      if (mounted) _showInfo('"${client.name}" a été supprimé.');
    } catch (_) {
      if (mounted) _showInfo('Erreur lors de la suppression.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              MenuSearchField(
                hint: 'Rechercher un client...',
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 14),
              Expanded(child: _buildList()),
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton.icon(
                    onPressed: () => _openForm(),
                    icon: const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Ajouter un client',
                      style: AppTextStyles.button,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.forestGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        IconButton(
          onPressed: widget.onMenuTap ?? () => Navigator.of(context).maybePop(),
          icon: Icon(
            widget.onMenuTap != null
                ? Icons.menu_rounded
                : Icons.chevron_left_rounded,
            size: 28,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text('Gestion des clients', style: AppTextStyles.screenTitle),
        ),
      ],
    );
  }

  Widget _buildList() {
    final provider = context.watch<ClientsProvider>();

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(provider.error!, style: AppTextStyles.body),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: provider.retry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
              ),
              child: Text('Réessayer', style: AppTextStyles.button),
            ),
          ],
        ),
      );
    }

    final clients = provider.filtered(_query);

    if (clients.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.people_outline_rounded,
              size: 46,
              color: AppColors.gray,
            ),
            const SizedBox(height: 10),
            Text(
              'Aucun client trouvé',
              style: AppTextStyles.body.copyWith(color: AppColors.gray),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 12),
      itemCount: clients.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final client = clients[i];
        return ClientCard(
          client: client,
          onEdit: () => _openForm(client),
          onDelete: () => _confirmDelete(client),
        );
      },
    );
  }
}
