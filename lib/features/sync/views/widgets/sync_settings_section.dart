import 'package:flutter/material.dart';

import '../../models/sync_config.dart';

class SyncSettingsSection extends StatelessWidget {
  const SyncSettingsSection({
    super.key,
    required this.config,
    required this.isLoading,
    required this.isSyncing,
    required this.onConfigChanged,
    required this.onTestConnection,
    required this.onColdSync,
  });

  final SyncConfig config;
  final bool isLoading;
  final bool isSyncing;
  final ValueChanged<SyncConfig> onConfigChanged;
  final Future<void> Function() onTestConnection;
  final VoidCallback onColdSync;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const _SyncSettingsLoadingCard();
    }

    return Card(
      child: Form(
        child: _SyncSettingsBody(
          config: config,
          isSyncing: isSyncing,
          onConfigChanged: onConfigChanged,
          onTestConnection: onTestConnection,
          onColdSync: onColdSync,
        ),
      ),
    );
  }
}

class _SyncSettingsBody extends StatelessWidget {
  const _SyncSettingsBody({
    required this.config,
    required this.isSyncing,
    required this.onConfigChanged,
    required this.onTestConnection,
    required this.onColdSync,
  });

  final SyncConfig config;
  final bool isSyncing;
  final ValueChanged<SyncConfig> onConfigChanged;
  final Future<void> Function() onTestConnection;
  final VoidCallback onColdSync;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SyncSettingsHeader(),
          const SizedBox(height: 12),
          _SyncField(
            label: '服务器地址 (URL)',
            hintText: 'https://dav.example.com/dav/',
            initialValue: config.webDavUrl,
            onChanged: (value) => onConfigChanged(
              config.copyWith(webDavUrl: value),
            ),
          ),
          const SizedBox(height: 8),
          _SyncField(
            label: '账号 (Username)',
            initialValue: config.username,
            onChanged: (value) => onConfigChanged(
              config.copyWith(username: value),
            ),
          ),
          const SizedBox(height: 8),
          _SyncField(
            label: '密码 (Password)',
            initialValue: config.password,
            obscureText: true,
            onChanged: (value) => onConfigChanged(
              config.copyWith(password: value),
            ),
          ),
          const SizedBox(height: 8),
          _SyncField(
            label: '目标文件夹',
            initialValue: config.targetFolder,
            onChanged: (value) => onConfigChanged(
              config.copyWith(targetFolder: value),
            ),
          ),
          const SizedBox(height: 12),
          _SyncActionRow(
            isSyncing: isSyncing,
            onTestConnection: onTestConnection,
            onFullSync: onColdSync,
          ),
          const SizedBox(height: 8),
          _AutoSyncRow(
            enabled: config.autoHotSync,
            interval: config.autoSyncInterval,
            onToggle: (value) => onConfigChanged(
              config.copyWith(autoHotSync: value),
            ),
            onIntervalChanged: (value) => onConfigChanged(
              config.copyWith(autoSyncInterval: value),
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncSettingsHeader extends StatelessWidget {
  const _SyncSettingsHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(child: Icon(Icons.cloud_sync_outlined)),
      title: Text(
        '同步设置',
        style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SyncSettingsLoadingCard extends StatelessWidget {
  const _SyncSettingsLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        leading: CircularProgressIndicator(),
        title: Text('加载同步配置...'),
      ),
    );
  }
}

class _SyncField extends StatelessWidget {
  const _SyncField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.hintText,
    this.obscureText = false,
  });

  final String label;
  final String? hintText;
  final String initialValue;
  final bool obscureText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      obscureText: obscureText,
      enableSuggestions: !obscureText,
      autocorrect: !obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }
}

class _IntervalField extends StatelessWidget {
  const _IntervalField({
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value.toString(),
      enabled: enabled,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: '同步间隔 (分钟)',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: (value) {
        final parsed = int.tryParse(value);
        if (parsed == null) {
          return;
        }
        onChanged(parsed);
      },
    );
  }
}

class _SyncActionRow extends StatelessWidget {
  const _SyncActionRow({
    required this.isSyncing,
    required this.onTestConnection,
    required this.onFullSync,
  });

  final bool isSyncing;
  final Future<void> Function() onTestConnection;
  final VoidCallback onFullSync;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: isSyncing ? null : () async => onTestConnection(),
            icon: const Icon(Icons.wifi_tethering_outlined),
            label: const Text('测试连接'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: isSyncing ? null : onFullSync,
            icon: const Icon(Icons.sync_outlined),
            label: const Text('全量同步'),
          ),
        ),
      ],
    );
  }
}

class _AutoSyncRow extends StatelessWidget {
  const _AutoSyncRow({
    required this.enabled,
    required this.interval,
    required this.onToggle,
    required this.onIntervalChanged,
  });

  final bool enabled;
  final int interval;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onIntervalChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilterChip(
          label: const Text('自动热同步'),
          selected: enabled,
          onSelected: onToggle,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _IntervalField(
            value: interval,
            enabled: enabled,
            onChanged: onIntervalChanged,
          ),
        ),
      ],
    );
  }
}
