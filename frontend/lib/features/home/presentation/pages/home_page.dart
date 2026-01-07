import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_daily_recommendations.dart';
import '../widgets/home_quick_actions.dart';
import '../widgets/home_stats_section.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: const CustomScrollView(
        slivers: [
          // Modern App Bar
          HomeAppBar(),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24),

                // Quick Actions (Search, EQ Test)
                HomeQuickActions(),

                SizedBox(height: 32),

                // Stats Section (Likes, Boosts, etc.)
                HomeStatsSection(),

                SizedBox(height: 32),

                // Recommended Matches Section
                HomeDailyRecommendations(),

                SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
