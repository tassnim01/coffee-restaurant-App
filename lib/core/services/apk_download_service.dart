import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class ApkDownloadService {
  final Dio _dio = Dio();

  Future<String> downloadApk({
    required String url,
    required Function(int received, int total) onProgress,
  }) async {
    // Dossier temporaire de l'application
    final directory = await getTemporaryDirectory();

    final apkPath = '${directory.path}/coffee_shop_update.apk';

    final apkFile = File(apkPath);

    // Supprimer l'ancien APK s'il existe
    if (await apkFile.exists()) {
      await apkFile.delete();
    }

    try {
      // Télécharger le nouvel APK
      final response = await _dio.download(
        url,
        apkPath,
        onReceiveProgress: (received, total) {
          onProgress(received, total);
        },
      );

      // Vérifier le résultat du téléchargement
      final statusCode = response.statusCode ?? 0;
      if (statusCode < 200 || statusCode >= 300) {
        throw Exception('Échec du téléchargement');
      }

      // Vérifier que le fichier existe
      if (!await apkFile.exists()) {
        throw Exception('Le fichier APK n’existe pas');
      }

      // Vérifier que le fichier n'est pas vide
      final fileSize = await apkFile.length();

      if (fileSize == 0) {
        throw Exception('Le fichier APK est vide');
      }

      return apkPath;
    } catch (e) {
      // Supprimer le fichier incomplet en cas d'erreur
      if (await apkFile.exists()) {
        await apkFile.delete();
      }

      rethrow;
    }
  }
}
