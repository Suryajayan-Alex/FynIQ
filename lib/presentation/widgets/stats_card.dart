import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../core/utils/formatter.dart';
import '../../domain/providers/analytics_providers.dart';

class StatsCardsRow extends ConsumerWidget {
  const StatsCardsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(analyticsStatsProvider);

    return statsAsync.when(
      data: (stats) => Row(
        children: [
          Expanded(
            child: _StatCard(
              label: "Biggest Spend 💸",
              value: stats.biggestTransaction != null
                  ? FyniqFormatter.formatCurrency(stats.biggestTransaction!.amount)
                  : "None yet",
              subtitle: stats.biggestTransaction?.title ?? "No data",
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: "Most Active 📅",
              value: stats.mostActiveDay ?? "—",
              subtitle: "${stats.mostActiveDayCount} transactions",
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatCard(
              label: "Avg/Day 📆",
              value: FyniqFormatter.formatCurrency(stats.avgDailySpend),
              subtitle: "per day",
            ),
          ),
        ],
      ),
      loading: () => Row(
        children: List.generate(
          3,
          (i) => const Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.0),
              child: ShimmerBox(width: 100, height: 90, borderRadius: 16),
            ),
          ),
        ),
      ),
      error: (_, __) => const SizedBox(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.label,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: FyniqTextStyles.caption.copyWith(color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: FyniqTextStyles.caption.copyWith(fontSize: 10, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
