import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/sync_config.dart';
import '../repositories/sync_config_repository.dart';
import '../services/sync_manager.dart';

final syncConfigRepositoryProvider = Provider<SyncConfigRepository>((ref) {
  throw UnimplementedError();
});

final syncManagerProvider = Provider<SyncManager>((ref) {
  final manager = SyncManager();
  ref.onDispose(manager.dispose);
  return manager;
});

final syncViewModelProvider =
    NotifierProvider<SyncViewModel, SyncViewState>(SyncViewModel.new);

class SyncViewState {
  const SyncViewState({
    required this.config,
    required this.isLoading,
    required this.isSyncing,
    required this.syncStatus,
    required this.lastSyncedAt,
    required this.errorMessage,
    required this.errorId,
  });

  static const Object _errorSentinel = Object();

  final SyncConfig config;
  final bool isLoading;
  final bool isSyncing;
  final String syncStatus;
  final DateTime? lastSyncedAt;
  final String? errorMessage;
  final int errorId;

  SyncViewState copyWith({
    SyncConfig? config,
    bool? isLoading,
    bool? isSyncing,
    String? syncStatus,
    DateTime? lastSyncedAt,
    Object? errorMessage = _errorSentinel,
    int? errorId,
  }) {
    return SyncViewState(
      config: config ?? this.config,
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      errorMessage: errorMessage == _errorSentinel
          ? this.errorMessage
          : errorMessage as String?,
      errorId: errorId ?? this.errorId,
    );
  }
}

class SyncViewModel extends Notifier<SyncViewState> {
  Timer? _autoTimer;
  StreamSubscription<String>? _statusSubscription;
  _SyncLifecycleObserver? _observer;
  bool _skipNextResume = false;

  @override
  SyncViewState build() {
    ref.onDispose(() {
      _autoTimer?.cancel();
      _statusSubscription?.cancel();
      _observer?.dispose();
    });

    _statusSubscription = ref
        .read(syncManagerProvider)
        .statusStream
        .listen((status) {
      state = state.copyWith(syncStatus: status);
    });

    _observer = _SyncLifecycleObserver(_handleResume);
    WidgetsBinding.instance.addObserver(_observer!);

    _loadConfig();

    return SyncViewState(
      config: SyncConfig.defaults,
      isLoading: true,
      isSyncing: false,
      syncStatus: '未同步',
      lastSyncedAt: null,
      errorMessage: null,
      errorId: 0,
    );
  }

  Future<void> _loadConfig() async {
    final config = await ref.read(syncConfigRepositoryProvider).load();
    state = state.copyWith(
      config: config,
      isLoading: false,
      lastSyncedAt: config.lastHotSyncAt,
    );
    _syncAutoTimer(config);
    _triggerStartupSync(config);
  }

  Future<void> updateConfig(SyncConfig config) async {
    final next = _normalizeConfig(config);
    state = state.copyWith(
      config: next,
      lastSyncedAt: next.lastHotSyncAt,
    );
    await ref.read(syncConfigRepositoryProvider).save(next);
    _syncAutoTimer(next);
  }

  Future<void> triggerHotSync() async {
    if (state.isSyncing) {
      return;
    }
    final config = state.config;
    if (!config.isReady) {
      _setError('请先配置 WebDAV 信息');
      return;
    }

    state = state.copyWith(isSyncing: true, syncStatus: '正在连接云端...');
    try {
      await ref.read(syncManagerProvider).hotSync(config);
      final now = DateTime.now();
      final nextConfig = config.copyWith(lastHotSyncAt: now);
      state = state.copyWith(
        isSyncing: false,
        syncStatus: '同步完成',
        lastSyncedAt: now,
        config: nextConfig,
      );
      await ref.read(syncConfigRepositoryProvider).save(nextConfig);
    } catch (e) {
      final now = DateTime.now();
      final nextConfig = config.copyWith(lastHotSyncAt: now);
      state = state.copyWith(
        isSyncing: false,
        syncStatus: '同步失败',
        lastSyncedAt: now,
        config: nextConfig,
        errorMessage: e.toString(),
        errorId: state.errorId + 1,
      );
      await ref.read(syncConfigRepositoryProvider).save(nextConfig);
    }
  }

  Future<void> triggerColdSync() async {
    if (state.isSyncing) {
      return;
    }
    final config = state.config;
    if (!config.isReady) {
      _setError('请先配置 WebDAV 信息');
      return;
    }

    state = state.copyWith(isSyncing: true, syncStatus: '正在连接云端...');
    try {
      await ref.read(syncManagerProvider).coldSync(config);
      state = state.copyWith(isSyncing: false, syncStatus: '同步完成');
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        syncStatus: '同步失败',
        errorMessage: e.toString(),
        errorId: state.errorId + 1,
      );
    }
  }

  Future<String?> testConnection() async {
    final config = state.config;
    if (!config.isReady) {
      return '请先配置 WebDAV 信息';
    }
    try {
      await ref.read(syncManagerProvider).testConnection(config);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void _syncAutoTimer(SyncConfig config) {
    _autoTimer?.cancel();
    if (!config.autoHotSync || !config.isReady) {
      return;
    }
    final minutes = config.autoSyncInterval < 5 ? 5 : config.autoSyncInterval;
    _autoTimer = Timer.periodic(Duration(minutes: minutes), (_) {
      triggerHotSync();
    });
  }

  void _handleResume() {
    if (state.isLoading || !state.config.isReady) {
      return;
    }
    if (_skipNextResume) {
      _skipNextResume = false;
      return;
    }
    if (!state.config.autoHotSync) {
      return;
    }
    triggerHotSync();
  }

  void _setError(String message) {
    state = state.copyWith(
      errorMessage: message,
      errorId: state.errorId + 1,
    );
  }

  SyncConfig _normalizeConfig(SyncConfig config) {
    final interval = config.autoSyncInterval < 5 ? 5 : config.autoSyncInterval;
    if (interval == config.autoSyncInterval) {
      return config;
    }
    return config.copyWith(autoSyncInterval: interval);
  }

  void _triggerStartupSync(SyncConfig config) {
    if (!config.hotSyncOnStartup || !config.isReady) {
      return;
    }
    _skipNextResume = true;
    triggerHotSync();
  }
}

class _SyncLifecycleObserver extends WidgetsBindingObserver {
  _SyncLifecycleObserver(this.onResumed);

  final VoidCallback onResumed;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }
}
