class SyncConfig {
  const SyncConfig({
    required this.webDavUrl,
    required this.username,
    required this.password,
    required this.targetFolder,
    required this.autoHotSync,
    required this.hotSyncOnStartup,
    required this.autoSyncInterval,
    required this.lastHotSyncAt,
  });

  final String webDavUrl;
  final String username;
  final String password;
  final String targetFolder;
  final bool autoHotSync;
  final bool hotSyncOnStartup;
  final int autoSyncInterval;
  final DateTime? lastHotSyncAt;

  static const SyncConfig defaults = SyncConfig(
    webDavUrl: '',
    username: '',
    password: '',
    targetFolder: 'AtimeLog2',
    autoHotSync: false,
    hotSyncOnStartup: true,
    autoSyncInterval: 10,
    lastHotSyncAt: null,
  );

  bool get isReady {
    return webDavUrl.isNotEmpty && username.isNotEmpty && password.isNotEmpty;
  }

  SyncConfig copyWith({
    String? webDavUrl,
    String? username,
    String? password,
    String? targetFolder,
    bool? autoHotSync,
    bool? hotSyncOnStartup,
    int? autoSyncInterval,
    DateTime? lastHotSyncAt,
  }) {
    return SyncConfig(
      webDavUrl: webDavUrl ?? this.webDavUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      targetFolder: targetFolder ?? this.targetFolder,
      autoHotSync: autoHotSync ?? this.autoHotSync,
      hotSyncOnStartup: hotSyncOnStartup ?? this.hotSyncOnStartup,
      autoSyncInterval: autoSyncInterval ?? this.autoSyncInterval,
      lastHotSyncAt: lastHotSyncAt ?? this.lastHotSyncAt,
    );
  }

  Map<String, Object?> toStorageMap() {
    return {
      'webDavUrl': webDavUrl,
      'username': username,
      'targetFolder': targetFolder,
      'autoHotSync': autoHotSync,
      'hotSyncOnStartup': hotSyncOnStartup,
      'autoSyncInterval': autoSyncInterval,
      'lastHotSyncAt': lastHotSyncAt?.millisecondsSinceEpoch,
    };
  }

  factory SyncConfig.fromStorageMap(
    Map<String, Object?> map, {
    required String password,
  }) {
    final lastHotSyncAt = map['lastHotSyncAt'] as int?;
    return SyncConfig(
      webDavUrl: map['webDavUrl'] as String? ?? '',
      username: map['username'] as String? ?? '',
      password: password,
      targetFolder: map['targetFolder'] as String? ?? 'AtimeLog2',
      autoHotSync: map['autoHotSync'] as bool? ?? false,
      hotSyncOnStartup: map['hotSyncOnStartup'] as bool? ?? true,
      autoSyncInterval: map['autoSyncInterval'] as int? ?? 10,
      lastHotSyncAt: lastHotSyncAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastHotSyncAt),
    );
  }
}
