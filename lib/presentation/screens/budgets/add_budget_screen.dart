import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/fyniq_scaffold.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/category_chip.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../domain/providers/database_providers.dart';
import '../../../domain/providers/dashboard_providers.dart';
import '../../../domain/providers/budget_providers.dart';
import '../../widgets/custom_numpad.dart';

class AddBudgetScreen extends ConsumerStatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  String? _selectedCategoryId;
  String _amountString = '0';
  String _selectedPeriod = 'monthly';
  final TextEditingController _nameController = TextEditingController();

  double get _amount => double.tryParse(_amountString) ?? 0.0;

  void _save() async {
    if (_selectedCategoryId == null || _amount <= 0 || _nameController.text.trim().isEmpty) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Complete all fields first 🎯")));
      return;
    }

    final repo = ref.read(budgetRepositoryProvider);
    await repo.addBudget(
      name: _nameController.text.trim(),
      categoryId: _selectedCategoryId!,
      limitAmount: _amount,
      period: _selectedPeriod,
    );

    HapticFeedback.heavyImpact();
    ref.invalidate(budgetProgressAllProvider);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Budget set! 🎯")));
      context.pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return FyniqScaffold(
      appBar: AppBar(title: Text("New Budget 🎯", style: FyniqTextStyles.headingM)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Category 🏷️", style: FyniqTextStyles.caption.copyWith(color: FyniqColors.textSecondary)),
              const SizedBox(height: 12),
              categoriesAsync.when(
                data: (cats) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: cats.map((c) {
                      final isSelected = _selectedCategoryId == c.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Semantics(
                          label: 'Select category ${c.name}',
                          selected: isSelected,
                          button: true,
                          child: CategoryChip(
                            emoji: c.emoji,
                            label: c.name,
                            isSelected: isSelected,
                            color: Color(int.parse(c.colorHex.replaceAll('#', '0xFF'))),
                            onTap: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _selectedCategoryId = c.id;
                                if (_nameController.text.isEmpty || _nameController.text.contains("Budget")) {
                                  _nameController.text = "${c.name} Budget";
                                }
                              });
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                loading: () => const ShimmerBox(width: double.infinity, height: 48),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 24),

              Text("Budget Name 📝", style: FyniqTextStyles.caption.copyWith(color: FyniqColors.textSecondary)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                style: FyniqTextStyles.body,
                decoration: const InputDecoration(hintText: "e.g. Food Budget"),
              ),
              const SizedBox(height: 24),

              Text("Spending Limit 💸", style: FyniqTextStyles.caption.copyWith(color: FyniqColors.textSecondary)),
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    Text("₹", style: GoogleFonts.spaceGrotesk(fontSize: 20, color: FyniqColors.textSecondary)),
                    Semantics(
                      label: 'Current amount $_amountString',
                      child: Text(
                        _amountString,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 56,
                          fontWeight: FontWeight.w800,
                          color: _amount > 0 ? FyniqColors.textPrimary : FyniqColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              CustomNumpad(
                onDigitPressed: (digit) {
                  setState(() {
                    if (digit == '.' && _amountString.contains('.')) return;
                    if (_amountString == '0' && digit != '.') {
                      _amountString = digit;
                    } else {
                      _amountString += digit;
                    }
                  });
                },
                onBackspacePressed: () {
                  setState(() {
                    if (_amountString.length <= 1) {
                      _amountString = '0';
                    } else {
                      _amountString = _amountString.substring(0, _amountString.length - 1);
                    }
                  });
                },
              ),
              const SizedBox(height: 24),

              Text("Resets Every 🔄", style: FyniqTextStyles.caption.copyWith(color: FyniqColors.textSecondary)),
              const SizedBox(height: 12),
              Row(
                children: ['weekly', 'monthly'].map((period) {
                  final isSelected = _selectedPeriod == period;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Semantics(
                        label: 'Reset $period',
                        selected: isSelected,
                        button: true,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedPeriod = period);
                          },
                          child: AnimatedContainer(
                            height: 48,
                            duration: 200.ms,
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(colors: [FyniqColors.primaryAccent, FyniqColors.highlightCTA])
                                  : null,
                              color: !isSelected ? FyniqColors.cardSurface : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                period == 'weekly' ? "Weekly" : "Monthly",
                                style: FyniqTextStyles.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? FyniqColors.textPrimary : FyniqColors.textSecondary,
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
              const SizedBox(height: 32),

              if (_selectedCategoryId != null && _amount > 0)
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "This budget will track spending in category and alert you when you reach ₹${_amount.toStringAsFixed(0)} per $_selectedPeriod.",
                    style: FyniqTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                ),

              const SizedBox(height: 32),
              GradientButton(
                text: "Set Budget 🎯",
                onPressed: _save,
                width: double.infinity,
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
