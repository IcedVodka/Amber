import 'package:flutter/material.dart';

import '../../models/category.dart';
import 'category_options.dart';

class CategoryFormValue {
  const CategoryFormValue({
    required this.name,
    required this.iconCode,
    required this.colorHex,
    required this.enabled,
  });

  final String name;
  final String iconCode;
  final String colorHex;
  final bool enabled;
}

class CategoryEditorSheet extends StatefulWidget {
  const CategoryEditorSheet({
    super.key,
    this.initial,
    required this.onSubmit,
    this.onDelete,
  });

  final Category? initial;
  final Future<void> Function(CategoryFormValue value) onSubmit;
  final Future<void> Function()? onDelete;

  @override
  State<CategoryEditorSheet> createState() => _CategoryEditorSheetState();
}

class _CategoryEditorSheetState extends State<CategoryEditorSheet> {
  late final TextEditingController _nameController;
  late CategoryIcon _iconOption;
  late CategoryColorOption _colorOption;
  late CategoryColorSeed _colorSeed;
  late CategoryIconGroup _group;
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.name ?? '');
    _iconOption = CategoryIcon.fromCode(initial?.iconCode);
    _colorOption = resolveCategoryColorOption(initial?.colorHex);
    _colorSeed = resolveCategoryColorSeed(_colorOption.hex);
    _group = _iconOption.group;
    _enabled = initial?.enabled ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;
    final isEditing = widget.initial != null;
    final groupIcons = _group.icons;
    final variants = variantsForSeed(_colorSeed);

    return SafeArea(
      child: _EditorBody(
        bottomInset: viewInsets.bottom,
        children: [
          _EditorHeader(
            title: isEditing ? '编辑分类' : '新增分类',
            onClose: () => Navigator.pop(context),
          ),
          const SizedBox(height: 12),
          _NameRow(
            controller: _nameController,
            icon: _iconOption,
            color: _colorOption,
          ),
          const SizedBox(height: 16),
          const _SectionTitle(title: '主题颜色'),
          const SizedBox(height: 12),
          _SeedPalette(
            seeds: categoryColorSeeds,
            selected: _colorSeed,
            onChanged: _handleSeedChanged,
          ),
          const SizedBox(height: 12),
          _VariantPalette(
            options: variants,
            selected: _colorOption,
            onChanged: (value) => setState(() => _colorOption = value),
          ),
          const SizedBox(height: 20),
          const _SectionTitle(title: '图标库'),
          const SizedBox(height: 12),
          _IconGroupSelector(
            groups: CategoryIconGroup.values,
            selected: _group,
            onChanged: (value) => setState(() => _group = value),
          ),
          const SizedBox(height: 12),
          _IconGrid(
            options: groupIcons,
            selectedCode: _iconOption.code,
            onChanged: (value) => setState(() => _iconOption = value),
          ),
          const SizedBox(height: 12),
          _EnabledTile(
            value: _enabled,
            onChanged: (value) => setState(() => _enabled = value),
          ),
          const SizedBox(height: 20),
          _EditorActions(
            confirmLabel: isEditing ? '保存' : '添加',
            onSubmit: _handleSubmit,
            onDelete: widget.onDelete == null ? null : _handleDelete,
          ),
        ],
      ),
    );
  }

  void _handleSeedChanged(CategoryColorSeed seed) {
    final variants = variantsForSeed(seed);
    final selected = variants.firstWhere(
      (option) => option.hex == _colorOption.hex,
      orElse: () => variants[1],
    );
    setState(() {
      _colorSeed = seed;
      _colorOption = selected;
    });
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      return;
    }
    await widget.onSubmit(
      CategoryFormValue(
        name: name,
        iconCode: _iconOption.code,
        colorHex: _colorOption.hex,
        enabled: _enabled,
      ),
    );
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _handleDelete() async {
    final onDelete = widget.onDelete;
    if (onDelete == null) {
      return;
    }
    await onDelete();
    if (mounted) {
      Navigator.pop(context);
    }
  }
}

class _EditorHeader extends StatelessWidget {
  const _EditorHeader({
    required this.title,
    required this.onClose,
  });

  final String title;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .titleMedium
        ?.copyWith(fontWeight: FontWeight.w700);
    return Row(
      children: [
        Expanded(child: Text(title, style: style)),
        IconButton(
          onPressed: onClose,
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}

class _EditorBody extends StatelessWidget {
  const _EditorBody({
    required this.bottomInset,
    required this.children,
  });

  final double bottomInset;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

class _NameRow extends StatelessWidget {
  const _NameRow({
    required this.controller,
    required this.icon,
    required this.color,
  });

  final TextEditingController controller;
  final CategoryIcon icon;
  final CategoryColorOption color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: color.color,
          radius: 26,
          child: Icon(icon.icon, color: colorScheme.onPrimary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: '活动名称',
              border: UnderlineInputBorder(),
            ),
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            textInputAction: TextInputAction.done,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SeedPalette extends StatelessWidget {
  const _SeedPalette({
    required this.seeds,
    required this.selected,
    required this.onChanged,
  });

  final List<CategoryColorSeed> seeds;
  final CategoryColorSeed selected;
  final ValueChanged<CategoryColorSeed> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PaletteLabel(text: '主色'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: seeds
              .map(
                (seed) => _ColorDot(
                  color: seed.color,
                  label: seed.label,
                  selected: seed == selected,
                  onTap: () => onChanged(seed),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _VariantPalette extends StatelessWidget {
  const _VariantPalette({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<CategoryColorOption> options;
  final CategoryColorOption selected;
  final ValueChanged<CategoryColorOption> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _PaletteLabel(text: '分色'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: options
              .map(
                (option) => _ColorDot(
                  color: option.color,
                  label: option.label,
                  selected: option.hex == selected.hex,
                  onTap: () => onChanged(option),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _PaletteLabel extends StatelessWidget {
  const _PaletteLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Text(
      text,
      style: textTheme.bodySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = selected ? colorScheme.primary : colorScheme.outline;
    final iconColor = colorScheme.onPrimary;

    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: _ColorDotBody(
          color: color,
          borderColor: borderColor,
          iconColor: iconColor,
          selected: selected,
        ),
      ),
    );
  }
}

class _ColorDotBody extends StatelessWidget {
  const _ColorDotBody({
    required this.color,
    required this.borderColor,
    required this.iconColor,
    required this.selected,
  });

  final Color color;
  final Color borderColor;
  final Color iconColor;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: selected ? 2 : 1),
      ),
      child: selected
          ? Icon(Icons.check_rounded, size: 20, color: iconColor)
          : null,
    );
  }
}

class _IconGroupSelector extends StatelessWidget {
  const _IconGroupSelector({
    required this.groups,
    required this.selected,
    required this.onChanged,
  });

  final List<CategoryIconGroup> groups;
  final CategoryIconGroup selected;
  final ValueChanged<CategoryIconGroup> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: groups
          .map(
            (group) => ChoiceChip(
              label: Text(group.label),
              selected: group == selected,
              onSelected: (_) => onChanged(group),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _IconGrid extends StatelessWidget {
  const _IconGrid({
    required this.options,
    required this.selectedCode,
    required this.onChanged,
  });

  final List<CategoryIcon> options;
  final String selectedCode;
  final ValueChanged<CategoryIcon> onChanged;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 64,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final option = options[index];
        return _IconGridTile(
          option: option,
          selected: option.code == selectedCode,
          onTap: () => onChanged(option),
        );
      },
    );
  }
}

class _IconGridTile extends StatelessWidget {
  const _IconGridTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final CategoryIcon option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background =
        selected ? colorScheme.primaryContainer : colorScheme.surfaceVariant;
    final border = selected ? colorScheme.primary : colorScheme.outlineVariant;
    final iconColor =
        selected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return Card(
      color: background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: _IconTileContent(
          label: option.label,
          icon: option.icon,
          color: iconColor,
        ),
      ),
    );
  }
}

class _IconTileContent extends StatelessWidget {
  const _IconTileContent({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Tooltip(
        message: label,
        child: Icon(icon, color: color),
      ),
    );
  }
}

class _EnabledTile extends StatelessWidget {
  const _EnabledTile({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('启用分类'),
      value: value,
      contentPadding: EdgeInsets.zero,
      onChanged: onChanged,
    );
  }
}

class _EditorActions extends StatelessWidget {
  const _EditorActions({
    required this.confirmLabel,
    required this.onSubmit,
    this.onDelete,
  });

  final String confirmLabel;
  final Future<void> Function() onSubmit;
  final Future<void> Function()? onDelete;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      Expanded(
        child: FilledButton(
          onPressed: () => onSubmit(),
          child: Text(confirmLabel),
        ),
      ),
    ];

    if (onDelete != null) {
      children.insert(
        0,
        Expanded(
          child: OutlinedButton(
            onPressed: () => onDelete?.call(),
            child: const Text('删除'),
          ),
        ),
      );
    }

    return Row(
      children: [
        children.first,
        if (children.length > 1) const SizedBox(width: 12),
        if (children.length > 1) children.last,
      ],
    );
  }
}
