import 'package:flutter/material.dart';

import '../../../../core/utils/date_formatters.dart';

class TimerHeader extends StatelessWidget {
  const TimerHeader({super.key, required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '今天',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatDateTitle(now),
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        IconButton.filledTonal(
          onPressed: () {},
          icon: const Icon(Icons.calendar_month),
        ),
      ],
    );
  }
}
