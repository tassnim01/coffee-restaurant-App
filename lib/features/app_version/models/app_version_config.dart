class AppVersionConfig {
  final String minVersion;
  final String latestVersion;
  final String apkUrl;
  final String storeUrlAndroid;
  final String storeUrlIos;
  final String message;

  const AppVersionConfig({
    this.minVersion = '0.0.0',
    this.latestVersion = '0.0.0',
    this.apkUrl = '',
    this.storeUrlAndroid = '',
    this.storeUrlIos = '',
    this.message = '',
  });

  factory AppVersionConfig.fromMap(Map<String, dynamic> map) =>
      AppVersionConfig(
        minVersion: map['minVersion'] as String? ?? '0.0.0',
        latestVersion: map['latestVersion'] as String? ?? '0.0.0',
        apkUrl: map['apkUrl'] as String? ?? '',
        storeUrlAndroid: map['storeUrlAndroid'] as String? ?? '',
        storeUrlIos: map['storeUrlIos'] as String? ?? '',
        message: map['message'] as String? ?? '',
      );
}

int compareVersions(String a, String b) {
  final pa = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final pb = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();

  final len = pa.length > pb.length ? pa.length : pb.length;

  for (var i = 0; i < len; i++) {
    final va = i < pa.length ? pa[i] : 0;
    final vb = i < pb.length ? pb[i] : 0;

    if (va != vb) return va - vb;
  }

  return 0;
}