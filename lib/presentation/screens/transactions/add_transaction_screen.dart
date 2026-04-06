import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/fyniq_scaffold.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../core/utils/formatter.dart';
import '../../../domain/providers/add_transaction_providers.dart';
import '../../../domain/providers/dashboard_providers.dart';
import '../../../domain/providers/database_providers.dart';
import '../../widgets/custom_numpad.dart';
import '../../widgets/add_category_sheet.dart';
import '../../widgets/error_card.dart';
import '../../animations/success_overlay.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final String? id;
  const AddTransactionScreen({super.key, this.id});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  bool isEditMode = false;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isEditMode = widget.id != null;
    if (isEditMode) {
      _loadTransaction();
    }
  }

  Future<void> _loadTransaction() async {
    final t = await ref.read(transactionRepositoryProvider).getById(widget.id!);
    if (t != null) {
      ref.read(addTransactionFormProvider.notifier).loadFromTransaction(t);
      _titleController.text = t.title;
      _noteController.text = t.note ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() async {
    final state = ref.read(addTransactionFormProvider);
    final notifier = ref.read(addTransactionFormProvider.notifier);
    
    if (!state.isValid) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: FyniqColors.warning,
        content: Text(
          state.amount == 0 ? "Enter an amount first 💸"
          : state.title.isEmpty ? "What was it for? 📝"
          : "Pick a category 🏷️",
          style: FyniqTextStyles.body.copyWith(color: Colors.white),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    
    await notifier.save(ref);
    HapticFeedback.heavyImpact();
    
    if (mounted) {
      await showSuccessOverlay(
        context,
        isEditMode ? "Transaction Updated ✓" : "Logged. You're in control ✓",
      );
      context.pop();
    }
  }

  void _confirmDelete() {
    HapticFeedback.vibrate();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FyniqColors.cardSurface,
        title: const Text("Delete Transaction?"),
        content: const Text("This cannot be undone. You sure?"),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              ref.read(transactionRepositoryProvider).deleteTransaction(widget.id!);
              context.pop(); // dialog
              context.pop(); // screen
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted. 🗑️")));
            },
            child: const Text("Delete", style: TextStyle(color: FyniqColors.highlightCTA)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addTransactionFormProvider);
    final notifier = ref.read(addTransactionFormProvider.notifier);

    return FyniqScaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(isEditMode ? "Edit Spend" : "New Spend", style: FyniqTextStyles.headingM),
        actions: [
          if (isEditMode)
            IconButton(
              icon: const Icon(Iconsax.trash, color: FyniqColors.highlightCTA),
              tooltip: 'Delete transaction',
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Column(
        children: [
          _buildTypeToggle(state, notifier),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                   _buildAmountDisplay(state),
                   const SizedBox(height: 16),
                   CustomNumpad(
                     onDigitPressed: notifier.appendDigit,
                     onBackspacePressed: notifier.backspace,
                   ),
                   const SizedBox(height: 24),
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 24),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         _buildTitleField(notifier),
                         const SizedBox(height: 16),
                         _buildCategorySelector(state, notifier),
                         const SizedBox(height: 16),
                         _buildDateSelector(state, notifier),
                         const SizedBox(height: 16),
                         _buildNoteField(notifier),
                         const SizedBox(height: 16),
                         _buildRecurringSection(state, notifier),
                         const SizedBox(height: 32),
                         GradientButton(
                           text: isEditMode ? "Update Transaction ✓" : "Log It ✓",
                           onPressed: _save,
                           isLoading: state.isSaving,
                           width: double.infinity,
                         ),
                         const SizedBox(height: 48),
                       ],
                     ),
                   ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle(AddTransactionFormState state, AddTransactionFormNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Row(
        children: ['expense', 'income'].map((type) {
          final isSelected = state.type == type;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: type == 'expense' ? 4 : 0,
                left: type == 'income' ? 4 : 0,
              ),
              child: Semantics(
                button: true,
                selected: isSelected,
                label: 'Set as $type',
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    notifier.setType(type);
                  },
                  child: AnimatedContainer(
                    height: 48,
                    duration: 200.ms,
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              colors: type == 'expense'
                                  ? [FyniqColors.highlightCTA, FyniqColors.primaryAccent]
                                  : [FyniqColors.success, FyniqColors.primaryAccent],
                            )
                          : null,
                      color: !isSelected ? FyniqColors.cardSurface : null,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        type == 'expense' ? "💸 Expense" : "💰 Income",
                        style: FyniqTextStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : FyniqColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAmountDisplay(AddTransactionFormState state) {
    return Column(
      children: [
        Text("₹", style: GoogleFonts.spaceGrotesk(fontSize: 20, color: FyniqColors.textSecondary)),
        Semantics(
          label: 'Current amount ${state.amountString}',
          child: AnimatedSwitcher(
            duration: 150.ms,
            child: Text(
              state.amountString,
              key: ValueKey(state.amountString),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 56,
                fontWeight: FontWeight.w800,
                color: state.amount > 0 ? FyniqColors.textPrimary : FyniqColors.textSecondary,
              ),
            ),
          ),
        ),
        if (state.amount == 0)
          Text("Tap numbers below", style: FyniqTextStyles.caption.copyWith(color: FyniqColors.textSecondary)),
      ],
    );
  }

  Widget _buildTitleField(AddTransactionFormNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("What was this for? 📝", style: FyniqTextStyles.caption),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          onChanged: notifier.setTitle,
          style: FyniqTextStyles.body,
          decoration: const InputDecoration(hintText: "e.g. Starbucks, Movie, Salary"),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(AddTransactionFormState state, AddTransactionFormNotifier notifier) {
    final catsAsync = ref.watch(allCategoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Category 🏷️", style: FyniqTextStyles.caption),
        const SizedBox(height: 8),
        catsAsync.when(
          data: (cats) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...cats.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Semantics(
                        label: 'Select category ${c.name}',
                        button: true,
                        selected: state.categoryId == c.id,
                        child: CategoryChip(
                          emoji: c.emoji,
                          label: c.name,
                          isSelected: state.categoryId == c.id,
                          color: Color(int.parse(c.colorHex.replaceAll('#', '0xFF'))),
                          onTap: () {
                            HapticFeedback.lightImpact();
                            notifier.setCategory(c.id);
                          },
                        ),
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Semantics(
                    button: true,
                    label: 'Add new category',
                    child: CategoryChip(
                      emoji: '➕',
                      label: 'New',
                      isSelected: false,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        showAddCategorySheet(context, ref);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          loading: () => const ShimmerBox(width: double.infinity, height: 48),
          error: (e, __) => ErrorCard(message: e.toString()),
        ),
      ],
    );
  }

  Widget _buildDateSelector(AddTransactionFormState state, AddTransactionFormNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Date 📅", style: FyniqTextStyles.caption),
        const SizedBox(height: 8),
        Semantics(
          button: true,
          label: 'Pick transaction date. Current: ${FyniqFormatter.formatDate(state.date)}',
          child: GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();
              final picked = await showDatePicker(
                context: context,
                initialDate: state.date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                builder: (ctx, child) => Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: FyniqColors.primaryAccent,
                      onPrimary: Colors.white,
                      surface: FyniqColors.cardSurface,
                      onSurface: Colors.white,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) notifier.setDate(picked);
            },
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Iconsax.calendar, color: FyniqColors.textSecondary, size: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Selected Date", style: FyniqTextStyles.caption.copyWith(color: Colors.grey)),
                      Text(FyniqFormatter.formatDate(state.date),
                          style: FyniqTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField(AddTransactionFormNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Add a note 🗒️", style: FyniqTextStyles.caption),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          onChanged: notifier.setNote,
          maxLines: 2,
          style: FyniqTextStyles.body,
          decoration: const InputDecoration(hintText: "Optional details..."),
        ),
      ],
    );
  }

  Widget _buildRecurringSection(AddTransactionFormState state, AddTransactionFormNotifier notifier) {
    return Column(
      children: [
        Semantics(
          label: 'Toggle recurring transaction',
          toggled: state.isRecurring,
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Recurring 🔁", style: FyniqTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                    Text("Auto-log on schedule", style: FyniqTextStyles.caption),
                  ],
                ),
                const Spacer(),
                Switch(
                  value: state.isRecurring,
                  activeThumbColor: FyniqColors.primaryAccent,
                  onChanged: (_) {
                    HapticFeedback.selectionClick();
                    notifier.toggleRecurring();
                  },
                ),
              ],
            ),
          ),
        ),
        if (state.isRecurring)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Repeat every:", style: FyniqTextStyles.caption),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ('Daily', 1),
                      ('Weekly', 7),
                      ('Fortnightly', 14),
                      ('Monthly', 30)
                    ].map((entry) {
                      final label = entry.$1;
                      final days = entry.$2;
                      final isSelected = state.recurringIntervalDays == days;
                      return Expanded(
                        child: Semantics(
                          button: true,
                          selected: isSelected,
                          label: 'Repeat $label',
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              notifier.setInterval(days);
                            },
                            child: AnimatedContainer(
                              duration: 150.ms,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? FyniqColors.primaryAccent : FyniqColors.cardSurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  label,
                                  style: FyniqTextStyles.caption.copyWith(
                                    color: isSelected ? Colors.white : Colors.grey,
                                    fontWeight: isSelected ? FontWeight.w600 : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn().slideY(begin: 0.2),
      ],
    );
  }
}
