class SyncConfig {
  const SyncConfig({
    required this.webDavUrl,
    required this.username,
    required this.password,
    required this.targetFolder,
    required this.autoHotSync,
    required this.autoSyncInterval,
    required this.lastHotSyncAt,
  });

  final String webDavUrl;
  final String username;
  final String password;
  final String targetFolder;
  final bool autoHotSync;
  final int autoSyncInterval;
  final DateTime? lastHotSyncAt;

  static const SyncConfig defaults = SyncConfig(
    webDavUrl: '',
    username: '',
    password: '',
    targetFolder: 'AtimeLog2',
    autoHotSync: false,
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
    int? autoSyncInterval,
    DateTime? lastHotSyncAt,
  }) {
    return SyncConfig(
      webDavUrl: webDavUrl ?? this.webDavUrl,
      username: username ?? this.username,
      password: password ?? this.password,
      targetFolder: targetFolder ?? this.targetFolder,
      autoHotSync: autoHotSync ?? this.autoHotSync,
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
      autoSyncInterval: map['autoSyncInterval'] as int? ?? 10,
      lastHotSyncAt: lastHotSyncAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(lastHotSyncAt),
    );
  }
}
