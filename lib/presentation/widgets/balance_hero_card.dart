import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/shimmer_box.dart';
import '../../core/utils/formatter.dart';
import '../../domain/providers/dashboard_providers.dart';

class BalanceHeroCard extends ConsumerWidget {
  const BalanceHeroCard({super.key});

  String _getGreetingPeriod(DateTime date) {
    final month = DateFormat('MMMM yyyy').format(date);
    return month;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(spendingSummaryProvider);
    final userNameAsync = ref.watch(userNameProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            FyniqColors.primaryAccent,
            FyniqColors.secondaryAccent,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            children: [
              // ── Top Bar: Avatar + Month + Notification ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Profile Avatar
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      context.go('/home/settings');
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: Center(
                        child: userNameAsync.when(
                          data: (name) => Text(
                            (name != null && name.isNotEmpty) ? name[0].toUpperCase() : 'U',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          loading: () => const Icon(Icons.person, color: Colors.white, size: 20),
                          error: (_, __) => const Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),

                  // Month selector chip
                  GestureDetector(
                    onTap: () => _showMonthPicker(context, ref),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getGreetingPeriod(ref.watch(selectedDateProvider)),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18),
                        ],
                      ),
                    ),
                  ),

                  // Notification dot
                  GestureDetector(
                    onTap: () => context.push('/notifications'),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.15),
                      ),
                      child: const Center(
                        child: Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Current Balance Label ──
              Text(
                "Current Balance",
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),

              const SizedBox(height: 8),

              // ── Large Balance Amount ──
              summaryAsync.when(
                data: (s) {
                  final isNegative = s.netBalance < 0;
                  return Text(
                    "${isNegative ? '-' : ''}₹${FyniqFormatter.formatAmount(s.netBalance.abs())}",
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      color: isNegative ? FyniqColors.warning : Colors.white,
                      letterSpacing: -1,
                    ),
                  ).animate().fadeIn(duration: 500.ms).scale(
                    begin: const Offset(0.9, 0.9),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  );
                },
                loading: () => const ShimmerBox(width: 200, height: 48),
                error: (_, __) => Text(
                  "₹0.00",
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // ── Subtitle: Transaction count or change ──
              summaryAsync.when(
                data: (s) {
                  final count = s.transactionCount;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      count > 0
                          ? "$count transactions this period"
                          : "No transactions yet",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMonthPicker(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final selectedDate = ref.watch(selectedDateProvider);
            final months = [
              'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
              'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
            ];

            return AlertDialog(
              backgroundColor: FyniqColors.cardSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                    onPressed: () {
                      final newDate = DateTime(selectedDate.year - 1, selectedDate.month);
                      ref.read(selectedDateProvider.notifier).state = newDate;
                      setDialogState(() {});
                    },
                  ),
                  Text(
                    selectedDate.year.toString(),
                    style: FyniqTextStyles.headingM.copyWith(color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                    onPressed: () {
                      final newDate = DateTime(selectedDate.year + 1, selectedDate.month);
                      ref.read(selectedDateProvider.notifier).state = newDate;
                      setDialogState(() {});
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final isSelected = selectedDate.month == (index + 1);
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ref.read(selectedDateProvider.notifier).state = 
                          DateTime(selectedDate.year, index + 1);
                        ref.read(selectedPeriodProvider.notifier).state = 'month';
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected 
                              ? FyniqColors.primaryAccent 
                              : Colors.white.withOpacity(0.05),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          months[index],
                          style: FyniqTextStyles.body.copyWith(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
