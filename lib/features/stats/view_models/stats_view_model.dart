import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/file_service.dart';
import '../../../core/utils/date_utils.dart';
import '../../activity/models/timeline_item.dart';
import '../../activity/repositories/timeline_repository.dart';
import '../../categories/models/category.dart';
import '../../categories/view_models/categories_list_provider.dart';
import '../models/stats_models.dart';
import '../repositories/stats_repository.dart';

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepository(TimelineRepository(FileService()));
});

final statsViewModelProvider =
    NotifierProvider<StatsViewModel, StatsViewState>(
  StatsViewModel.new,
);

class StatsViewState {
  const StatsViewState({
    required this.isLoading,
    required this.dimension,
    required this.viewMode,
    required this.selectedDate,
    required this.customRange,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.summary,
    required this.trend,
    required this.categoryBreakdown,
    required this.report,
    required this.categoryMap,
  });

  final bool isLoading;
  final StatsDimension dimension;
  final StatsViewMode viewMode;
  final DateTime selectedDate;
  final StatsDateRange customRange;
  final String headerTitle;
  final String headerSubtitle;
  final StatsSummary summary;
  final StatsTrendData trend;
  final List<CategoryBreakdown> categoryBreakdown;
  final StatsReport report;
  final Map<String, Category> categoryMap;

  StatsViewState copyWith({
    bool? isLoading,
    StatsDimension? dimension,
    StatsViewMode? viewMode,
    DateTime? selectedDate,
    StatsDateRange? customRange,
    String? headerTitle,
    String? headerSubtitle,
    StatsSummary? summary,
    StatsTrendData? trend,
    List<CategoryBreakdown>? categoryBreakdown,
    StatsReport? report,
    Map<String, Category>? categoryMap,
  }) {
    return StatsViewState(
      isLoading: isLoading ?? this.isLoading,
      dimension: dimension ?? this.dimension,
      viewMode: viewMode ?? this.viewMode,
      selectedDate: selectedDate ?? this.selectedDate,
      customRange: customRange ?? this.customRange,
      headerTitle: headerTitle ?? this.headerTitle,
      headerSubtitle: headerSubtitle ?? this.headerSubtitle,
      summary: summary ?? this.summary,
      trend: trend ?? this.trend,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      report: report ?? this.report,
      categoryMap: categoryMap ?? this.categoryMap,
    );
  }
}

class StatsViewModel extends Notifier<StatsViewState> {
  static const StatsSummary _emptySummary = StatsSummary(
    netSec: 0,
    grossSec: 0,
    efficiency: 0,
    delta: StatsDelta(ratio: 0, isAvailable: false),
  );
  static const StatsTrendData _emptyTrend = StatsTrendData(
    points: [],
    targetSec: 0,
    showTargetLine: false,
  );
  static const StatsReport _emptyReport = StatsReport(
    title: '',
    id: '',
    periodLabel: '',
    netSec: 0,
    grossSec: 0,
    efficiency: 0,
    keywords: [],
    sections: [],
    footerNote: null,
  );

  @override
  StatsViewState build() {
    final now = DateTime.now();
    final customRange = _defaultCustomRange(now);
    final initial = StatsViewState(
      isLoading: true,
      dimension: StatsDimension.day,
      viewMode: StatsViewMode.dashboard,
      selectedDate: now,
      customRange: customRange,
      headerTitle: formatFullDate(now),
      headerSubtitle: formatWeekday(now),
      summary: _emptySummary,
      trend: _emptyTrend,
      categoryBreakdown: const [],
      report: _emptyReport,
      categoryMap: const {},
    );
    Future.microtask(() => _load(date: now, dimension: StatsDimension.day));
    return initial;
  }

  Future<void> updateDimension(StatsDimension dimension) async {
    final range = dimension == StatsDimension.custom
        ? state.customRange
        : null;
    final date = dimension == StatsDimension.custom
        ? state.customRange.end
        : state.selectedDate;
    await _load(date: date, dimension: dimension, customRange: range);
  }

  void updateViewMode(StatsViewMode mode) {
    state = state.copyWith(viewMode: mode);
  }

  Future<void> shiftDate(int step) async {
    if (state.dimension == StatsDimension.custom) {
      final nextRange = _shiftCustomRange(state.customRange, step);
      await _load(
        date: nextRange.end,
        dimension: state.dimension,
        customRange: nextRange,
      );
      return;
    }
    final next = _shiftDate(state.selectedDate, state.dimension, step);
    await _load(date: next, dimension: state.dimension);
  }

  Future<void> pickDate(DateTime date) async {
    await _load(date: date, dimension: state.dimension);
  }

  Future<void> pickRange(StatsDateRange range) async {
    await _load(
      date: range.end,
      dimension: StatsDimension.custom,
      customRange: range,
    );
  }

  Future<void> _load({
    required DateTime date,
    required StatsDimension dimension,
    StatsDateRange? customRange,
  }) async {
    final normalized = DateTime(date.year, date.month, date.day);
    final resolvedRange = _resolveRange(
      normalized,
      dimension,
      customRange: customRange ?? state.customRange,
    );
    final anchorDate =
        dimension == StatsDimension.custom ? resolvedRange.end : normalized;
    state = state.copyWith(
      isLoading: true,
      selectedDate: anchorDate,
      dimension: dimension,
      customRange: dimension == StatsDimension.custom
          ? resolvedRange
          : state.customRange,
    );

    final categories = await ref.read(categoryRepositoryProvider).load();
    final categoryMap = {
      for (final item in categories) item.id: item,
    };

    final range = resolvedRange;
    final itemsByDate = await ref.read(statsRepositoryProvider).loadRange(
          range.start,
          range.end,
        );

    final totals = _computeTotals(itemsByDate.values.expand((items) => items));
    final delta = await _computeDelta(range, dimension, totals.netSec);
    final summary = StatsSummary(
      netSec: totals.netSec,
      grossSec: totals.grossSec,
      efficiency: totals.efficiency,
      delta: delta,
    );

    final trend = _buildTrend(itemsByDate, range, dimension);
    final categoryBreakdown = _buildCategoryBreakdown(itemsByDate, categoryMap);
    final report = _buildReport(
      anchorDate,
      dimension,
      range,
      itemsByDate,
      summary,
      categoryBreakdown,
    );

    state = state.copyWith(
      isLoading: false,
      selectedDate: anchorDate,
      dimension: dimension,
      headerTitle: _buildHeaderTitle(anchorDate, range, dimension),
      headerSubtitle: _buildHeaderSubtitle(anchorDate, range, dimension),
      summary: summary,
      trend: trend,
      categoryBreakdown: categoryBreakdown,
      report: report,
      categoryMap: categoryMap,
    );
  }

  StatsDateRange _resolveRange(
    DateTime date,
    StatsDimension dimension, {
    required StatsDateRange customRange,
  }) {
    final normalized = DateTime(date.year, date.month, date.day);
    switch (dimension) {
      case StatsDimension.day:
        return StatsDateRange(start: normalized, end: normalized);
      case StatsDimension.week:
        final diff = normalized.weekday - DateTime.monday;
        final start = normalized.subtract(Duration(days: diff));
        final end = start.add(const Duration(days: 6));
        return StatsDateRange(start: start, end: end);
      case StatsDimension.custom:
        return customRange;
    }
  }

  StatsDateRange _defaultCustomRange(DateTime date) {
    final end = DateTime(date.year, date.month, date.day);
    final start = end.subtract(const Duration(days: 6));
    return StatsDateRange(start: start, end: end);
  }

  StatsDateRange _shiftCustomRange(StatsDateRange current, int step) {
    final days = _rangeDays(current);
    final offset = Duration(days: days * step);
    return StatsDateRange(
      start: current.start.add(offset),
      end: current.end.add(offset),
    );
  }

  int _rangeDays(StatsDateRange range) {
    return range.end.difference(range.start).inDays + 1;
  }

  DateTime _shiftDate(DateTime date, StatsDimension dimension, int step) {
    switch (dimension) {
      case StatsDimension.day:
        return date.add(Duration(days: step));
      case StatsDimension.week:
        return date.add(Duration(days: step * 7));
      case StatsDimension.custom:
        return date;
    }
  }

  Future<StatsDelta> _computeDelta(
    StatsDateRange range,
    StatsDimension dimension,
    int currentNet,
  ) async {
    final previousRange = _previousRange(range, dimension);
    final previousItems = await ref.read(statsRepositoryProvider).loadRange(
          previousRange.start,
          previousRange.end,
        );
    final previousTotals = _computeTotals(
      previousItems.values.expand((items) => items),
    );
    if (previousTotals.netSec == 0) {
      return const StatsDelta(ratio: 0, isAvailable: false);
    }
    final ratio = (currentNet - previousTotals.netSec) / previousTotals.netSec;
    return StatsDelta(ratio: ratio, isAvailable: true);
  }

  StatsDateRange _previousRange(
    StatsDateRange current,
    StatsDimension dimension,
  ) {
    switch (dimension) {
      case StatsDimension.day:
        final prev = current.start.subtract(const Duration(days: 1));
        return StatsDateRange(start: prev, end: prev);
      case StatsDimension.week:
        final start = current.start.subtract(const Duration(days: 7));
        return StatsDateRange(
          start: start,
          end: start.add(const Duration(days: 6)),
        );
      case StatsDimension.custom:
        return _shiftCustomRange(current, -1);
    }
  }

  _Totals _computeTotals(Iterable<TimelineItem> items) {
    double net = 0;
    var gross = 0;
    for (final item in items) {
      if (item is TimeRecord) {
        net += item.effectiveSec;
        gross += item.durationSec;
      }
    }
    final efficiency = gross == 0 ? 0.0 : net / gross;
    return _Totals(net.round(), gross, efficiency);
  }

  StatsTrendData _buildTrend(
    Map<DateTime, List<TimelineItem>> itemsByDate,
    StatsDateRange range,
    StatsDimension dimension,
  ) {
    switch (dimension) {
      case StatsDimension.day:
        return _buildHourlyTrend(
          itemsByDate[range.start] ?? const <TimelineItem>[],
        );
      case StatsDimension.week:
        return _buildDailyTrend(
          range,
          itemsByDate,
          days: 7,
          showAllLabels: true,
          useWeekdayLabel: true,
        );
      case StatsDimension.custom:
        final days = _rangeDays(range);
        final showAllLabels = days <= 10;
        return _buildDailyTrend(
          range,
          itemsByDate,
          days: days,
          showAllLabels: showAllLabels,
          useWeekdayLabel: false,
        );
    }
  }

  StatsTrendData _buildHourlyTrend(List<TimelineItem> items) {
    final buckets = List<double>.filled(24, 0);
    final records = items.whereType<TimeRecord>();
    for (final record in records) {
      for (var hour = 0; hour < 24; hour += 1) {
        final start = DateTime(
          record.startAt.year,
          record.startAt.month,
          record.startAt.day,
          hour,
        );
        final end = start.add(const Duration(hours: 1));
        final overlapStart =
            record.startAt.isAfter(start) ? record.startAt : start;
        final overlapEnd = record.endAt.isBefore(end) ? record.endAt : end;
        if (overlapEnd.isAfter(overlapStart)) {
          final seconds = overlapEnd.difference(overlapStart).inSeconds;
          buckets[hour] += seconds * record.weight;
        }
      }
    }

    final points = <TrendPoint>[];
    for (var hour = 0; hour < 24; hour += 1) {
      points.add(TrendPoint(
        label: hour.toString(),
        value: buckets[hour],
        showLabel: hour % 3 == 0,
      ));
    }
    return StatsTrendData(
      points: points,
      targetSec: 0,
      showTargetLine: false,
    );
  }

  StatsTrendData _buildDailyTrend(
    StatsDateRange range,
    Map<DateTime, List<TimelineItem>> itemsByDate, {
    required int days,
    required bool showAllLabels,
    required bool useWeekdayLabel,
  }) {
    final points = <TrendPoint>[];
    for (var i = 0; i < days; i += 1) {
      final date = range.start.add(Duration(days: i));
      final items = itemsByDate[date] ?? const <TimelineItem>[];
      final totals = _computeTotals(items);
      final showLabel = showAllLabels ||
          date.day == 1 ||
          date.day % 5 == 0 ||
          i == days - 1;
      points.add(TrendPoint(
        label: useWeekdayLabel ? _weekdayShort(date) : '${date.day}',
        value: totals.netSec.toDouble(),
        showLabel: showLabel,
      ));
    }
    return StatsTrendData(
      points: points,
      targetSec: 5 * 3600,
      showTargetLine: true,
    );
  }

  List<CategoryBreakdown> _buildCategoryBreakdown(
    Map<DateTime, List<TimelineItem>> itemsByDate,
    Map<String, Category> categoryMap,
  ) {
    final totals = <String, double>{};
    for (final items in itemsByDate.values) {
      for (final item in items) {
        if (item is TimeRecord) {
          totals.update(
            item.categoryId,
            (value) => value + item.effectiveSec,
            ifAbsent: () => item.effectiveSec,
          );
        }
      }
    }
    final totalNet = totals.values.fold<double>(0, (sum, value) => sum + value);
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).map((entry) {
      final category = categoryMap[entry.key];
      return CategoryBreakdown(
        categoryId: entry.key,
        label: category?.name ?? entry.key,
        color: category?.color ?? const Color(0xFF94A3B8),
        netSec: entry.value.round(),
        ratio: totalNet == 0 ? 0 : entry.value / totalNet,
      );
    }).toList();
  }

  StatsReport _buildReport(
    DateTime date,
    StatsDimension dimension,
    StatsDateRange range,
    Map<DateTime, List<TimelineItem>> itemsByDate,
    StatsSummary summary,
    List<CategoryBreakdown> categoryBreakdown,
  ) {
    final sections = _buildSections(itemsByDate, dimension);
    final keywords = categoryBreakdown
        .take(3)
        .map((item) => '#${item.label}')
        .toList(growable: false);
    final footerNote = _latestNote(itemsByDate.values.expand((items) => items));
    return StatsReport(
      title: _reportTitle(dimension),
      id: _reportId(range, dimension),
      periodLabel: _reportPeriodLabel(date, range, dimension),
      netSec: summary.netSec,
      grossSec: summary.grossSec,
      efficiency: summary.efficiency,
      keywords: keywords,
      sections: sections,
      footerNote: footerNote,
    );
  }

  List<ReportSection> _buildSections(
    Map<DateTime, List<TimelineItem>> itemsByDate,
    StatsDimension dimension,
  ) {
    final dates = itemsByDate.keys.toList()
      ..sort((a, b) => a.compareTo(b));
    final sections = <ReportSection>[];
    for (final date in dates) {
      final items = itemsByDate[date] ?? const <TimelineItem>[];
      if (items.isEmpty && dimension != StatsDimension.day) {
        continue;
      }
      final totals = _computeTotals(items);
      sections.add(ReportSection(
        date: date,
        items: items,
        netSec: totals.netSec,
        grossSec: totals.grossSec,
      ));
    }
    return sections;
  }

  String? _latestNote(Iterable<TimelineItem> items) {
    Note? latest;
    for (final item in items) {
      if (item is Note) {
        if (latest == null || item.createdAt.isAfter(latest.createdAt)) {
          latest = item;
        }
      }
    }
    return latest?.content;
  }

  String _buildHeaderTitle(
    DateTime date,
    StatsDateRange range,
    StatsDimension dimension,
  ) {
    switch (dimension) {
      case StatsDimension.day:
        return formatFullDate(date);
      case StatsDimension.week:
        return _formatRange(range.start, range.end);
      case StatsDimension.custom:
        return _formatRange(range.start, range.end);
    }
  }

  String _buildHeaderSubtitle(
    DateTime date,
    StatsDateRange range,
    StatsDimension dimension,
  ) {
    switch (dimension) {
      case StatsDimension.day:
        final weekday = formatWeekday(date);
        if (_isSameDay(date, DateTime.now())) {
          return '今天 · $weekday';
        }
        return weekday;
      case StatsDimension.week:
        return '共7天';
      case StatsDimension.custom:
        return '自定义范围 · 共${_rangeDays(range)}天';
    }
  }

  String _formatRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      return '${start.year}年${start.month}月${start.day}日 - ${end.day}日';
    }
    if (start.year == end.year) {
      return '${start.year}年${start.month}月${start.day}日'
          ' - ${end.month}月${end.day}日';
    }
    return '${formatFullDate(start)} - ${formatFullDate(end)}';
  }

  String _reportTitle(StatsDimension dimension) {
    switch (dimension) {
      case StatsDimension.day:
        return 'DAILY REPORT';
      case StatsDimension.week:
        return 'WEEKLY REPORT';
      case StatsDimension.custom:
        return 'CUSTOM REPORT';
    }
  }

  String _reportId(StatsDateRange range, StatsDimension dimension) {
    final year = range.start.year.toString();
    final month = _two(range.start.month);
    final day = _two(range.start.day);
    switch (dimension) {
      case StatsDimension.day:
        return '$year$month$day-A1';
      case StatsDimension.week:
        return '$year$month$day-W1';
      case StatsDimension.custom:
        return '';
    }
  }

  String _reportPeriodLabel(
    DateTime date,
    StatsDateRange range,
    StatsDimension dimension,
  ) {
    switch (dimension) {
      case StatsDimension.day:
        return formatFullDate(date);
      case StatsDimension.week:
        return _formatRange(range.start, range.end);
      case StatsDimension.custom:
        return _formatRange(range.start, range.end);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _weekdayShort(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return '一';
      case DateTime.tuesday:
        return '二';
      case DateTime.wednesday:
        return '三';
      case DateTime.thursday:
        return '四';
      case DateTime.friday:
        return '五';
      case DateTime.saturday:
        return '六';
      case DateTime.sunday:
        return '日';
      default:
        return '';
    }
  }

  String _two(int value) => value.toString().padLeft(2, '0');
}

class _Totals {
  const _Totals(this.netSec, this.grossSec, this.efficiency);

  final int netSec;
  final int grossSec;
  final double efficiency;
}
