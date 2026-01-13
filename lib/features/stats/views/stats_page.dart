import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/stats_models.dart';
import '../view_models/stats_view_model.dart';
import 'widgets/stats_page_content.dart';

class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(statsViewModelProvider);
    final notifier = ref.read(statsViewModelProvider.notifier);

    if (state.isLoading) {
      return const SafeArea(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SafeArea(
      child: StatsPageContent(
        state: state,
        onDimensionChanged: notifier.updateDimension,
        onViewModeChanged: notifier.updateViewMode,
        onPrev: () => notifier.shiftDate(-1),
        onNext: () => notifier.shiftDate(1),
        onPickDate: () => _pickDate(context, notifier, state),
      ),
    );
  }

  Future<void> _pickDate(
    BuildContext context,
    StatsViewModel notifier,
    StatsViewState state,
  ) async {
    if (state.dimension == StatsDimension.custom) {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        initialDateRange: DateTimeRange(
          start: state.customRange.start,
          end: state.customRange.end,
        ),
      );
      if (range == null) {
        return;
      }
      await notifier.pickRange(
        StatsDateRange(start: range.start, end: range.end),
      );
      return;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: state.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) {
      return;
    }
    await notifier.pickDate(picked);
  }
}
