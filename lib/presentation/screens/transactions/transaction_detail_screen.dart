import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/fyniq_scaffold.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/utils/formatter.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/providers/database_providers.dart';
import '../../../domain/providers/dashboard_providers.dart';
import '../../widgets/error_card.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final String id;
  const TransactionDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionAsync = ref.watch(transactionByIdProvider(id));
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return FyniqScaffold(
      appBar: AppBar(
        title: Text("Transaction Detail 💸", style: FyniqTextStyles.headingM),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit, color: FyniqColors.primaryAccent),
            onPressed: () {
              HapticFeedback.lightImpact();
              context.push('/edit-transaction/$id');
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.trash, color: FyniqColors.highlightCTA),
            onPressed: () => _delete(context, ref),
          ),
        ],
      ),
      body: transactionAsync.when(
        data: (tx) {
          if (tx == null) return const Center(child: ErrorCard(message: "Transaction not found."));

          return categoriesAsync.when(
            data: (cats) {
              final cat = cats.firstWhere((c) => c.id == tx.categoryId, orElse: () => cats.last);
              final date = DateTime.fromMillisecondsSinceEpoch(tx.date);
              final catColor = Color(int.parse(cat.colorHex.replaceAll('#', '0xFF')));

              return Padding(
                padding: const EdgeInsets.all(24),
                child: GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: catColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Center(child: Text(cat.emoji, style: const TextStyle(fontSize: 40))),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        FyniqFormatter.formatCurrency(tx.amount),
                        style: FyniqTextStyles.headingXL.copyWith(
                          color: tx.type == 'expense' ? FyniqColors.highlightCTA : FyniqColors.success,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        cat.name,
                        style: FyniqTextStyles.caption.copyWith(color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 32),
                      _DetailRow(label: "Title 📝", value: tx.title),
                      _DetailRow(label: "Date 📅", value: DateFormat('dd MMM yyyy, hh:mm a').format(date)),
                      if (tx.note != null && tx.note!.isNotEmpty)
                        _DetailRow(label: "Note 💬", value: tx.note!),
                      if (tx.isRecurring)
                        _DetailRow(label: "Recurring 🔁", value: tx.recurringIntervalDays != null ? "Every ${tx.recurringIntervalDays} days" : "Yes"),
                      const SizedBox(height: 24),
                      Text(
                        "Added ${DateFormat('jm').format(DateTime.fromMillisecondsSinceEpoch(tx.createdAt))}",
                        style: FyniqTextStyles.caption.copyWith(color: Colors.grey.withOpacity(0.5)),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, __) => ErrorCard(message: e.toString()),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => ErrorCard(message: e.toString()),
      ),
    );
  }

  void _delete(BuildContext context, WidgetRef ref) {
    HapticFeedback.vibrate();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FyniqColors.cardSurface,
        title: const Text("Delete Transaction?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              HapticFeedback.heavyImpact();
              await ref.read(transactionRepositoryProvider).deleteTransaction(id);
              if (context.mounted) {
                Navigator.pop(ctx);
                FyniqSnackbar.show(context, "Deleted. 🗑️", isError: true);
                context.pop();
              }
            },
            child: const Text("Delete", style: TextStyle(color: FyniqColors.highlightCTA)),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 110, child: Text(label, style: FyniqTextStyles.caption.copyWith(color: Colors.grey))),
          Expanded(child: Text(value, style: FyniqTextStyles.body.copyWith(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

final transactionByIdProvider = FutureProvider.family<Transaction?, String>((ref, id) {
  return ref.watch(transactionRepositoryProvider).getById(id);
});
