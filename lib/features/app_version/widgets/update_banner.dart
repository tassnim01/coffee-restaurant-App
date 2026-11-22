import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/apk_download_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/app_version_provider.dart';

class UpdateGate extends StatefulWidget {
  final Widget child;

  const UpdateGate({super.key, required this.child});

  @override
  State<UpdateGate> createState() => _UpdateGateState();
}

class _UpdateGateState extends State<UpdateGate> {
  bool _dismissed = false;
  bool _isDownloading = false;
  double _downloadProgress = 0;

  Future<void> _openDownload(BuildContext context) async {
    final config = context.read<AppVersionProvider>().config;

    // iOS : ouvrir le lien App Store
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final url = config.storeUrlIos;

      if (url.isNotEmpty) {
        final uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    // Android : télécharger l'APK
    final apkUrl = config.apkUrl;

    if (apkUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lien de téléchargement indisponible'),
        ),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
    });

    try {
      final apkPath = await ApkDownloadService().downloadApk(
        url: apkUrl,
        onProgress: (received, total) {
          if (total > 0 && mounted) {
            setState(() {
              _downloadProgress = received / total;
            });
          }
        },
      );

if (!context.mounted) return;
      // Ouvrir l'installateur Android
      final result = await OpenFilex.open(apkPath);

if (result.type != ResultType.done && context.mounted) {        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Impossible d’ouvrir l’APK : ${result.message}',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de téléchargement : $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final version = context.watch<AppVersionProvider>();

    final blocked = version.mustUpdate;
    final hasUpdate = version.hasUpdate;

    final showUpdate = version.isReady && hasUpdate && !_dismissed;

    return PopScope(
      canPop: !blocked,
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (showUpdate)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: blocked ? () {} : null,
                child: Material(
                  color: Colors.black.withValues(alpha: 0.82),
                  child: SafeArea(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: _UpdateCard(
                          message: version.config.message,
                          requiredUpdate: blocked,
                          onUpdate: () => _openDownload(context),
                          onLater: (blocked || _isDownloading)
                              ? null
                              : () {
                                  setState(() {
                                    _dismissed = true;
                                  });
                                },
                          isDownloading: _isDownloading,
                          downloadProgress: _downloadProgress,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UpdateCard extends StatelessWidget {
  final String message;
  final bool requiredUpdate;
  final VoidCallback onUpdate;
  final VoidCallback? onLater;
  final bool isDownloading;
  final double downloadProgress;

  const _UpdateCard({
    required this.message,
    required this.requiredUpdate,
    required this.onUpdate,
    required this.onLater,
    required this.isDownloading,
    required this.downloadProgress,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.forestGreen.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.system_update_rounded,
                color: AppColors.forestGreen,
                size: 34,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              requiredUpdate
                  ? 'Mise à jour requise'
                  : 'Nouvelle version disponible',
              textAlign: TextAlign.center,
              style: AppTextStyles.screenTitle.copyWith(fontSize: 20),
            ),

            const SizedBox(height: 10),

            Text(
              message.isNotEmpty
                  ? message
                  : 'Une nouvelle version de l’application est disponible.',
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.gray,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            // Bouton téléchargement
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: isDownloading ? null : onUpdate,
                    icon: isDownloading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.download_rounded,
                            color: Colors.white,
                          ),
                    label: Text(
                      isDownloading
                          ? 'Téléchargement ${(downloadProgress * 100).toInt()}%'
                          : 'Mettre à jour',
                      style: AppTextStyles.button,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.forestGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                // Progression du téléchargement
                if (isDownloading) ...[
                  const SizedBox(height: 12),

                  LinearProgressIndicator(
                    value: downloadProgress,
                    backgroundColor: AppColors.gray.withValues(alpha: 0.2),
                    color: AppColors.forestGreen,
                    borderRadius: BorderRadius.circular(8),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Téléchargement de la mise à jour en cours...',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.gray,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),

            // Bouton Plus tard
            if (onLater != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onLater,
                child: const Text('Plus tard'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}