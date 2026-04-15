import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/database/app_database.dart';
import '../../../domain/providers/add_transaction_providers.dart';
import '../../../domain/providers/dashboard_providers.dart';
import '../../../domain/providers/database_providers.dart';
import '../../animations/success_overlay.dart';
import '../../widgets/add_category_sheet.dart';
import '../../widgets/error_card.dart';

Color _alpha(Color color, double opacity) => color.withValues(alpha: opacity);

class AddTransactionScreen extends ConsumerStatefulWidget {
  final String? id;
  const AddTransactionScreen({super.key, this.id});
  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  static const _currencySymbol = '\u20B9';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final NumberFormat _wholeAmountFormat = NumberFormat('#,##,##0', 'en_IN');
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.id != null;
    _amountFocusNode.addListener(_handleAmountFocusChange);
    if (_isEditMode) _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    final transaction =
        await ref.read(transactionRepositoryProvider).getById(widget.id!);
    if (transaction == null || !mounted) return;
    ref
        .read(addTransactionFormProvider.notifier)
        .loadFromTransaction(transaction);
    _titleController.text = transaction.title;
    _syncAmountField(transaction.amount % 1 == 0
        ? transaction.amount.toInt().toString()
        : transaction.amount.toString());
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _amountFocusNode
      ..removeListener(_handleAmountFocusChange)
      ..dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final state = ref.read(addTransactionFormProvider);
    final notifier = ref.read(addTransactionFormProvider.notifier);
    if (!state.isValid) {
      HapticFeedback.vibrate();
      final message = state.amount == 0
          ? 'Enter an amount first.'
          : state.title.trim().isEmpty
              ? 'Add a short description.'
              : 'Pick a category.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: FyniqColors.warning,
        content: Text(message,
            style: FyniqTextStyles.body.copyWith(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    await notifier.save(ref);
    HapticFeedback.heavyImpact();
    if (!mounted) return;
    final entryLabel = state.type == 'income' ? 'Income' : 'Expense';
    await showSuccessOverlay(
        context, _isEditMode ? '$entryLabel updated.' : '$entryLabel added.');
    if (mounted) context.pop();
  }

  Future<void> _confirmDelete() async {
    HapticFeedback.vibrate();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Delete transaction?', style: FyniqTextStyles.headingM),
        content: Text('This transaction will be removed permanently.',
            style: FyniqTextStyles.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('Cancel',
                style: FyniqTextStyles.body
                    .copyWith(color: FyniqColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Delete',
                style: FyniqTextStyles.body.copyWith(
                    color: FyniqColors.warning, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(transactionRepositoryProvider).deleteTransaction(widget.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Transaction deleted.')));
    context.pop();
  }

  void _handleAmountChanged(String value) {
    final notifier = ref.read(addTransactionFormProvider.notifier);
    if (value.trim().isEmpty) {
      notifier.setAmountString('0');
      return;
    }
    notifier.setAmountString(value);
  }

  void _syncAmountField(String rawValue) {
    final displayValue =
        rawValue == '0' ? '' : _formatAmountForEditing(rawValue);
    if (_amountController.text == displayValue) return;
    _amountController.value = TextEditingValue(
        text: displayValue,
        selection: TextSelection.collapsed(offset: displayValue.length));
  }

  String _formatAmountForEditing(String rawValue) {
    if (rawValue.isEmpty || rawValue == '0') return '';
    final parts = rawValue.split('.');
    final formattedWhole =
        _wholeAmountFormat.format(int.tryParse(parts.first) ?? 0);
    if (parts.length == 1) return formattedWhole;
    final decimals = parts[1];
    return decimals.isEmpty ? '$formattedWhole.' : '$formattedWhole.$decimals';
  }

  void _handleAmountFocusChange() {
    if (_amountFocusNode.hasFocus) {
      final rawValue = ref.read(addTransactionFormProvider).amountString;
      final editableValue = rawValue == '0' ? '' : rawValue;
      if (_amountController.text != editableValue) {
        _amountController.value = TextEditingValue(
          text: editableValue,
          selection: TextSelection.collapsed(offset: editableValue.length),
        );
      }
      return;
    }

    final rawValue = ref.read(addTransactionFormProvider).amountString;
    _syncAmountField(rawValue);
  }

  String _screenTitle(String type) => _isEditMode
      ? (type == 'income' ? 'Edit income' : 'Edit expense')
      : (type == 'income' ? 'Add new income' : 'Add new expense');
  String _screenSubtitle(String type) => type == 'income'
      ? 'Enter the details of your income to keep your cash flow up to date.'
      : 'Enter the details of your expense to help you track your spending.';
  String _ctaLabel(String type) => _isEditMode
      ? (type == 'income' ? 'Update Income' : 'Update Expense')
      : (type == 'income' ? 'Add Income' : 'Add Expense');

  Future<void> _showCategoryPicker(
      List<Category> categories, AddTransactionFormNotifier notifier) async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) {
        final selectedCategoryId =
            ref.read(addTransactionFormProvider).categoryId;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                            color: FyniqColors.divider,
                            borderRadius: BorderRadius.circular(999)))),
                const SizedBox(height: 20),
                Text('Choose a category', style: FyniqTextStyles.headingM),
                const SizedBox(height: 8),
                Text('Pick where this transaction belongs.',
                    style: FyniqTextStyles.body
                        .copyWith(color: FyniqColors.textSecondary)),
                const SizedBox(height: 20),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: FyniqColors.divider),
                    itemBuilder: (_, index) {
                      final category = categories[index];
                      final isSelected = category.id == selectedCategoryId;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          notifier.setCategory(category.id);
                          Navigator.of(sheetContext).pop();
                        },
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                              color: _alpha(_categoryColor(category), 0.12),
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                              child: Text(category.emoji,
                                  style: const TextStyle(fontSize: 20))),
                        ),
                        title: Text(category.name,
                            style: FyniqTextStyles.body
                                .copyWith(fontWeight: FontWeight.w600)),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle,
                                color: FyniqColors.primaryAccent)
                            : const Icon(Icons.chevron_right,
                                color: FyniqColors.textSecondary),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(sheetContext).pop();
                    showAddCategorySheet(context, ref);
                  },
                  icon: const Icon(Iconsax.add),
                  label: const Text('Add category'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: FyniqColors.textPrimary,
                    side: const BorderSide(color: FyniqColors.divider),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate(AddTransactionFormState state,
      AddTransactionFormNotifier notifier) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      HapticFeedback.selectionClick();
      notifier.setDate(picked);
    }
  }

  String _formatFormDate(DateTime date) =>
      '${DateFormat('MMM').format(date)} ${date.day}${_ordinalSuffix(date.day)}, ${date.year}';
  String _ordinalSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  Color _categoryColor(Category category) =>
      Color(int.parse(category.colorHex.replaceAll('#', '0xFF')));
  Category? _selectedCategory(List<Category> categories, String? categoryId) {
    if (categoryId == null) return null;
    for (final category in categories) {
      if (category.id == categoryId) return category;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addTransactionFormProvider);
    final notifier = ref.read(addTransactionFormProvider.notifier);
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final categories = categoriesAsync.valueOrNull ?? const <Category>[];
    final selectedCategory = _selectedCategory(categories, state.categoryId);
    return Scaffold(
      backgroundColor: FyniqColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
              child: Row(children: [
                _IconActionButton(
                    icon: Icons.close, onPressed: () => context.pop()),
                const Spacer(),
                if (_isEditMode)
                  _IconActionButton(
                      icon: Iconsax.trash,
                      iconColor: FyniqColors.warning,
                      onPressed: _confirmDelete),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: _buildTypeToggle(state, notifier),
            ),
            Expanded(
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                children: [
                  Text(_screenTitle(state.type),
                      style: FyniqTextStyles.headingL),
                  const SizedBox(height: 8),
                  Text(_screenSubtitle(state.type),
                      style: FyniqTextStyles.body.copyWith(
                          color: FyniqColors.textSecondary, height: 1.45)),
                  const SizedBox(height: 28),
                  const _FieldLabel(text: 'Enter Amount'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    focusNode: _amountFocusNode,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.next,
                    scrollPadding: const EdgeInsets.only(bottom: 140),
                    inputFormatters: const [_AmountInputFormatter()],
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    style: FyniqTextStyles.body
                        .copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixText: '$_currencySymbol ',
                      prefixStyle: FyniqTextStyles.body.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: FyniqColors.textSecondary),
                      fillColor: FyniqColors.backgroundAlt.withValues(alpha: 0.5),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: FyniqColors.primaryAccent, width: 1.5)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: FyniqColors.divider)),
                    ),
                    onChanged: _handleAmountChanged,
                  ),
                  const SizedBox(height: 20),
                  const _FieldLabel(text: 'Description'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    textInputAction: TextInputAction.done,
                    scrollPadding: const EdgeInsets.only(bottom: 140),
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    onChanged: notifier.setTitle,
                    style: FyniqTextStyles.body
                        .copyWith(fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: state.type == 'income'
                          ? 'Salary, bonus, freelance payment'
                          : 'Coffee, groceries, rent',
                      fillColor: FyniqColors.backgroundAlt.withValues(alpha: 0.5),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: FyniqColors.primaryAccent, width: 1.5)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: FyniqColors.divider)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _FieldLabel(text: 'Category'),
                  const SizedBox(height: 8),
                  categoriesAsync.when(
                    data: (loadedCategories) => _SelectorField(
                      onTap: () =>
                          _showCategoryPicker(loadedCategories, notifier),
                      child: Row(children: [
                        if (selectedCategory != null) ...[
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                                color: _alpha(
                                    _categoryColor(selectedCategory), 0.12),
                                borderRadius: BorderRadius.circular(12)),
                            child: Center(
                                child: Text(selectedCategory.emoji,
                                    style: const TextStyle(fontSize: 18))),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(selectedCategory.name,
                                  style: FyniqTextStyles.body
                                      .copyWith(fontWeight: FontWeight.w600))),
                        ] else ...[
                          Expanded(
                              child: Text('Select category',
                                  style: FyniqTextStyles.body.copyWith(
                                      color: FyniqColors.textSecondary))),
                        ],
                        const Icon(Icons.chevron_right,
                            size: 18, color: FyniqColors.textSecondary),
                      ]),
                    ),
                    loading: () => const _LoadingField(),
                    error: (error, _) => ErrorCard(message: error.toString()),
                  ),
                  const SizedBox(height: 20),
                  const _FieldLabel(text: 'Date'),
                  const SizedBox(height: 8),
                  _SelectorField(
                    onTap: () => _pickDate(state, notifier),
                    child: Row(children: [
                      Expanded(
                          child: Text(_formatFormDate(state.date),
                              style: FyniqTextStyles.body
                                  .copyWith(fontWeight: FontWeight.w500))),
                      const Icon(Iconsax.calendar,
                          size: 18, color: FyniqColors.textPrimary),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  _buildRecurringSection(state, notifier),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              decoration: BoxDecoration(
                  color: FyniqColors.background,
                  border: Border(
                      top:
                          BorderSide(color: FyniqColors.divider.withValues(alpha: 0.5)))),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: state.isSaving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: state.type == 'income' ? FyniqColors.success : FyniqColors.primaryAccent,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: FyniqColors.textSecondary.withValues(alpha: 0.3),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: state.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.black)))
                      : Text(_ctaLabel(state.type),
                          style: FyniqTextStyles.body.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle(
      AddTransactionFormState state, AddTransactionFormNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
          color: FyniqColors.backgroundAlt,
          borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        _TypeToggleButton(
            label: 'Expense',
            isSelected: state.type == 'expense',
            onTap: () {
              HapticFeedback.selectionClick();
              notifier.setType('expense');
            }),
        _TypeToggleButton(
            label: 'Income',
            isSelected: state.type == 'income',
            onTap: () {
              HapticFeedback.selectionClick();
              notifier.setType('income');
            }),
      ]),
    );
  }

  Widget _buildRecurringSection(
      AddTransactionFormState state, AddTransactionFormNotifier notifier) {
    const intervalOptions = <_RecurringChipConfig>[
      _RecurringChipConfig(label: 'Daily', days: 1),
      _RecurringChipConfig(label: 'Weekly', days: 7),
      _RecurringChipConfig(label: 'Fortnightly', days: 14),
      _RecurringChipConfig(label: 'Monthly', days: 30),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: FyniqColors.backgroundAlt.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: FyniqColors.divider.withValues(alpha: 0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Recurring entry',
                  style: FyniqTextStyles.body
                      .copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Save time by logging this on a schedule.',
                  style: FyniqTextStyles.caption
                      .copyWith(color: FyniqColors.textSecondary)),
            ]),
          ),
          Switch(
              value: state.isRecurring,
              onChanged: (_) {
                HapticFeedback.selectionClick();
                notifier.toggleRecurring();
              }),
        ]),
        if (state.isRecurring) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: intervalOptions.map((chip) {
              final isSelected = state.recurringIntervalDays == chip.days;
              return ChoiceChip(
                label: Text(chip.label),
                selected: isSelected,
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  notifier.setInterval(chip.days);
                },
                selectedColor: _alpha(FyniqColors.primaryAccent, 0.14),
                backgroundColor: Colors.white,
                side: BorderSide(
                    color: isSelected
                        ? FyniqColors.primaryAccent
                        : FyniqColors.divider),
                labelStyle: FyniqTextStyles.caption.copyWith(
                    color: isSelected
                        ? FyniqColors.primaryAccent
                        : FyniqColors.textPrimary,
                    fontWeight: FontWeight.w600),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              );
            }).toList(),
          ),
        ],
      ]),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: FyniqTextStyles.caption.copyWith(
            color: FyniqColors.textPrimary, fontWeight: FontWeight.w700));
  }
}

class _SelectorField extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const _SelectorField({required this.child, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
              color: FyniqColors.backgroundAlt.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: FyniqColors.divider.withValues(alpha: 0.8))),
          child: child,
        ),
      ),
    );
  }
}

class _LoadingField extends StatelessWidget {
  const _LoadingField();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
          color: _alpha(FyniqColors.backgroundAlt, 0.32),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: FyniqColors.divider)),
      child: const Center(
          child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2))),
    );
  }
}

class _TypeToggleButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _TypeToggleButton(
      {required this.label, required this.isSelected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 42,
          decoration: BoxDecoration(
            color: isSelected ? FyniqColors.background : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: _alpha(Colors.black, 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: FyniqTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? FyniqColors.textPrimary
                      : FyniqColors.textSecondary.withValues(alpha: 0.7))),
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onPressed;
  const _IconActionButton(
      {required this.icon, required this.onPressed, this.iconColor});
  @override
  Widget build(BuildContext context) {
    return Material(
      color: FyniqColors.backgroundAlt,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon,
                size: 20, color: iconColor ?? FyniqColors.textPrimary)),
      ),
    );
  }
}

class _AmountInputFormatter extends TextInputFormatter {
  const _AmountInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) {
      return newValue;
    }
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(text)) {
      return oldValue;
    }

    final parts = text.split('.');
    if (parts.length > 2) {
      return oldValue;
    }
    if (parts.first.length > 9) {
      return oldValue;
    }
    if (parts.length == 2 && parts[1].length > 2) {
      return oldValue;
    }
    return newValue;
  }
}

class _RecurringChipConfig {
  final String label;
  final int days;
  const _RecurringChipConfig({required this.label, required this.days});
}
