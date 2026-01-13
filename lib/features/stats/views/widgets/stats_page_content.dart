import 'package:flutter/material.dart';

import '../../models/stats_models.dart';
import '../../view_models/stats_view_model.dart';
import 'stats_category_breakdown.dart';
import 'stats_header.dart';
import 'stats_metric_cards.dart';
import 'stats_report_empty.dart';
import 'stats_report_footer.dart';
import 'stats_report_header.dart';
import 'stats_report_section.dart';
import 'stats_trend_card.dart';

class StatsPageContent extends StatelessWidget {
  const StatsPageContent({
    super.key,
    required this.state,
    required this.onDimensionChanged,
    required this.onViewModeChanged,
    required this.onPrev,
    required this.onNext,
    required this.onPickDate,
  });

  final StatsViewState state;
  final ValueChanged<StatsDimension> onDimensionChanged;
  final ValueChanged<StatsViewMode> onViewModeChanged;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPickDate;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: StatsHeader(
            dimension: state.dimension,
            viewMode: state.viewMode,
            title: state.headerTitle,
            subtitle: state.headerSubtitle,
            onDimensionChanged: onDimensionChanged,
            onViewModeChanged: onViewModeChanged,
            onPrev: onPrev,
            onNext: onNext,
            onPickDate: onPickDate,
          ),
        ),
        if (state.viewMode == StatsViewMode.dashboard)
          ..._buildDashboardSlivers()
        else
          ..._buildReportSlivers(),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  List<Widget> _buildDashboardSlivers() {
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
        sliver: SliverToBoxAdapter(
          child: StatsMetricCards(summary: state.summary),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
        sliver: SliverToBoxAdapter(
          child: StatsTrendCard(
            data: state.trend,
            dimension: state.dimension,
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
        sliver: SliverToBoxAdapter(
          child: StatsCategoryBreakdownCard(items: state.categoryBreakdown),
        ),
      ),
    ];
  }

  List<Widget> _buildReportSlivers() {
    final slivers = <Widget>[
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
        sliver: SliverToBoxAdapter(
          child: StatsReportHeaderCard(report: state.report),
        ),
      ),
    ];

    if (state.report.sections.isEmpty) {
      slivers.add(
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 6, 20, 12),
          sliver: SliverToBoxAdapter(child: StatsReportEmptyState()),
        ),
      );
    } else {
      for (final section in state.report.sections) {
        slivers.add(
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
            sliver: SliverToBoxAdapter(
              child: StatsReportSection(
                section: section,
                categoryMap: state.categoryMap,
                showHeader: state.dimension != StatsDimension.day,
              ),
            ),
          ),
        );
      }
    }

    slivers.add(
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
        sliver: SliverToBoxAdapter(
          child: StatsReportFooter(
            report: state.report,
            dimension: state.dimension,
          ),
        ),
      ),
    );

    return slivers;
  }
}
