import 'dart:ui';

import '../../activity/models/timeline_item.dart';

enum StatsDimension { day, week, custom }

enum StatsViewMode { dashboard, report }

class StatsDelta {
  const StatsDelta({
    required this.ratio,
    required this.isAvailable,
  });

  final double ratio;
  final bool isAvailable;
}

class StatsSummary {
  const StatsSummary({
    required this.netSec,
    required this.grossSec,
    required this.efficiency,
    required this.delta,
  });

  final int netSec;
  final int grossSec;
  final double efficiency;
  final StatsDelta delta;
}

class TrendPoint {
  const TrendPoint({
    required this.label,
    required this.value,
    this.showLabel = false,
  });

  final String label;
  final double value;
  final bool showLabel;
}

class StatsTrendData {
  const StatsTrendData({
    required this.points,
    required this.targetSec,
    required this.showTargetLine,
  });

  final List<TrendPoint> points;
  final int targetSec;
  final bool showTargetLine;
}

class CategoryBreakdown {
  const CategoryBreakdown({
    required this.categoryId,
    required this.label,
    required this.color,
    required this.netSec,
    required this.ratio,
  });

  final String categoryId;
  final String label;
  final Color color;
  final int netSec;
  final double ratio;
}

class ReportSection {
  const ReportSection({
    required this.date,
    required this.items,
    required this.netSec,
    required this.grossSec,
  });

  final DateTime date;
  final List<TimelineItem> items;
  final int netSec;
  final int grossSec;
}

class StatsReport {
  const StatsReport({
    required this.title,
    required this.id,
    required this.periodLabel,
    required this.netSec,
    required this.grossSec,
    required this.efficiency,
    required this.keywords,
    required this.sections,
    required this.footerNote,
  });

  final String title;
  final String id;
  final String periodLabel;
  final int netSec;
  final int grossSec;
  final double efficiency;
  final List<String> keywords;
  final List<ReportSection> sections;
  final String? footerNote;
}

class StatsDateRange {
  const StatsDateRange({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;
}
