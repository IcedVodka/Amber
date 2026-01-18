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
    final isCompact = MediaQuery.of(context).size.width < 360;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SyncSettingsHeader(),
          // const SizedBox(height: 12),
          _SyncField(
            label: '服务器地址 (URL)',
            hintText: 'https://dav.example.com/dav/',
            initialValue: config.webDavUrl,
            isCompact: isCompact,
            onChanged: (value) => onConfigChanged(
              config.copyWith(webDavUrl: value),
            ),
          ),
          const SizedBox(height: 8),
          _SyncField(
            label: '账号 (Username)',
            initialValue: config.username,
            isCompact: isCompact,
            onChanged: (value) => onConfigChanged(
              config.copyWith(username: value),
            ),
          ),
          const SizedBox(height: 8),
          _SyncField(
            label: '密码 (Password)',
            initialValue: config.password,
            obscureText: true,
            isCompact: isCompact,
            onChanged: (value) => onConfigChanged(
              config.copyWith(password: value),
            ),
          ),
          const SizedBox(height: 8),
          _SyncField(
            label: '目标文件夹',
            initialValue: config.targetFolder,
            isCompact: isCompact,
            onChanged: (value) => onConfigChanged(
              config.copyWith(targetFolder: value),
            ),
          ),
          const SizedBox(height: 12),
          _SyncActionRow(
            isSyncing: isSyncing,
            isCompact: isCompact,
            onTestConnection: onTestConnection,
            onFullSync: onColdSync,
          ),
          const SizedBox(height: 8),
          _AutoSyncRow(
            enabled: config.autoHotSync,
            startupEnabled: config.hotSyncOnStartup,
            interval: config.autoSyncInterval,
            isCompact: isCompact,
            onToggle: (value) => onConfigChanged(
              config.copyWith(autoHotSync: value),
            ),
            onStartupToggle: (value) => onConfigChanged(
              config.copyWith(hotSyncOnStartup: value),
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
    required this.isCompact,
    this.hintText,
    this.obscureText = false,
  });

  final String label;
  final String? hintText;
  final String initialValue;
  final bool obscureText;
  final bool isCompact;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = isCompact ? textTheme.labelSmall : textTheme.labelMedium;
    final fieldStyle = isCompact ? textTheme.bodySmall : textTheme.bodyMedium;
    return TextFormField(
      initialValue: initialValue,
      obscureText: obscureText,
      enableSuggestions: !obscureText,
      autocorrect: !obscureText,
      style: fieldStyle,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: labelStyle,
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
    required this.isCompact,
  });

  final int value;
  final bool enabled;
  final bool isCompact;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = isCompact ? textTheme.labelSmall : textTheme.labelMedium;
    final fieldStyle = isCompact ? textTheme.bodySmall : textTheme.bodyMedium;
    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('同步间隔(分钟)', style: labelStyle),
          const SizedBox(height: 6),
          TextFormField(
            initialValue: value.toString(),
            enabled: enabled,
            keyboardType: TextInputType.number,
            style: fieldStyle,
            decoration: const InputDecoration(
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
          ),
        ],
      );
    }
    return TextFormField(
      initialValue: value.toString(),
      enabled: enabled,
      keyboardType: TextInputType.number,
      style: fieldStyle,
      decoration: InputDecoration(
        labelText: '同步间隔 (分钟)',
        labelStyle: labelStyle,
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
    required this.isCompact,
  });

  final bool isSyncing;
  final Future<void> Function() onTestConnection;
  final VoidCallback onFullSync;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: isSyncing ? null : () async => onTestConnection(),
            icon: const Icon(Icons.wifi_tethering_outlined),
            label: _AdaptiveButtonLabel(
              text: '测试连接',
              isCompact: isCompact,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: isSyncing ? null : onFullSync,
            icon: const Icon(Icons.sync_outlined),
            label: _AdaptiveButtonLabel(
              text: '全量同步',
              isCompact: isCompact,
            ),
          ),
        ),
      ],
    );
  }
}

class _AutoSyncRow extends StatelessWidget {
  const _AutoSyncRow({
    required this.enabled,
    required this.startupEnabled,
    required this.interval,
    required this.onToggle,
    required this.onStartupToggle,
    required this.onIntervalChanged,
    required this.isCompact,
  });

  final bool enabled;
  final bool startupEnabled;
  final int interval;
  final ValueChanged<bool> onToggle;
  final ValueChanged<bool> onStartupToggle;
  final ValueChanged<int> onIntervalChanged;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _AutoSyncToggleGroup(
            enabled: enabled,
            startupEnabled: startupEnabled,
            isCompact: isCompact,
            onToggle: onToggle,
            onStartupToggle: onStartupToggle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _IntervalField(
            value: interval,
            enabled: enabled,
            onChanged: onIntervalChanged,
            isCompact: isCompact,
          ),
        ),
      ],
    );
  }
}

class _AutoSyncToggleGroup extends StatelessWidget {
  const _AutoSyncToggleGroup({
    required this.enabled,
    required this.startupEnabled,
    required this.isCompact,
    required this.onToggle,
    required this.onStartupToggle,
  });

  final bool enabled;
  final bool startupEnabled;
  final bool isCompact;
  final ValueChanged<bool> onToggle;
  final ValueChanged<bool> onStartupToggle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = isCompact ? textTheme.labelSmall : textTheme.labelMedium;
    final children = [
      FilterChip(
        label: const Text('启动时同步'),
        labelStyle: labelStyle,
        selected: startupEnabled,
        onSelected: onStartupToggle,
      ),
      FilterChip(
        label: const Text('自动同步'),
        labelStyle: labelStyle,
        selected: enabled,
        onSelected: onToggle,
      ),
    ];
    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          children.first,
          const SizedBox(height: 8),
          children.last,
        ],
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: children,
    );
  }
}

class _AdaptiveButtonLabel extends StatelessWidget {
  const _AdaptiveButtonLabel({
    required this.text,
    required this.isCompact,
  });

  final String text;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final style = isCompact ? Theme.of(context).textTheme.labelMedium : null;
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(text, maxLines: 1, style: style),
    );
  }
}
