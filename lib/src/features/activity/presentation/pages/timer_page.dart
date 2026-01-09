import 'package:flutter/material.dart';

import '../widgets/recent_activity_list.dart';
import '../widgets/timer_header.dart';
import '../widgets/timer_hero_card.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final recentItems = <RecentItem>[
      RecentItem(
        color: const Color(0xFF5A6CFF),
        title: 'Flutter UI 开发',
        subtitle: 'Side Project',
        duration: '1h 20m',
      ),
      RecentItem(
        color: const Color(0xFF9B6CFF),
        title: '阅读技术文档',
        subtitle: 'Learning',
        duration: '45m',
      ),
      RecentItem(
        color: const Color(0xFFFF8C5C),
        title: '产品头脑风暴',
        subtitle: 'Planning',
        duration: '30m',
      ),
    ];

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            sliver: SliverToBoxAdapter(
              child: TimerHeader(now: now),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(
              child: TimerHeroCard(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: RecentActivityHeader(
                onViewAll: () {},
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            sliver: RecentActivityList(
              items: recentItems,
            ),
          ),
        ],
      ),
    );
  }
}
