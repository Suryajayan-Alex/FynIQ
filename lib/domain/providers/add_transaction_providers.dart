import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../domain/providers/database_providers.dart';

class AddTransactionFormState {
  final String? id; // For edit mode
  final String amountString;
  final String type;
  final String title;
  final String? categoryId;
  final DateTime date;
  final String? note;
  final bool isRecurring;
  final int? recurringIntervalDays;
  final bool isSaving;

  double get amount => double.tryParse(amountString) ?? 0.0;
  bool get isValid =>
      amount > 0 && title.trim().isNotEmpty && categoryId != null;

  AddTransactionFormState({
    this.id,
    this.amountString = '0',
    this.type = 'expense',
    this.title = '',
    this.categoryId,
    DateTime? date,
    this.note,
    this.isRecurring = false,
    this.recurringIntervalDays = 30,
    this.isSaving = false,
  }) : date = date ?? DateTime.now();

  AddTransactionFormState copyWith({
    String? id,
    String? amountString,
    String? type,
    String? title,
    String? categoryId,
    DateTime? date,
    String? note,
    bool? isRecurring,
    int? recurringIntervalDays,
    bool? isSaving,
  }) {
    return AddTransactionFormState(
      id: id ?? this.id,
      amountString: amountString ?? this.amountString,
      type: type ?? this.type,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringIntervalDays:
          recurringIntervalDays ?? this.recurringIntervalDays,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class AddTransactionFormNotifier
    extends StateNotifier<AddTransactionFormState> {
  AddTransactionFormNotifier() : super(AddTransactionFormState());

  void setAmountString(String value) {
    state = state.copyWith(amountString: _sanitizeAmount(value));
  }

  void appendDigit(String digit) {
    if (digit == '.' && state.amountString.contains('.')) {
      return;
    }
    if (state.amountString.contains('.') &&
        state.amountString.split('.')[1].length >= 2) {
      return;
    }

    // Max value check
    if (state.amountString.length >= 7 && !state.amountString.contains('.')) {
      return;
    }

    if (state.amountString == '0' && digit != '.') {
      state = state.copyWith(amountString: digit);
    } else {
      state = state.copyWith(amountString: state.amountString + digit);
    }
  }

  void backspace() {
    if (state.amountString.length <= 1) {
      state = state.copyWith(amountString: '0');
    } else {
      state = state.copyWith(
          amountString:
              state.amountString.substring(0, state.amountString.length - 1));
    }
  }

  void setType(String type) => state = state.copyWith(type: type);
  void setTitle(String title) => state = state.copyWith(title: title);
  void setCategory(String categoryId) =>
      state = state.copyWith(categoryId: categoryId);
  void setDate(DateTime date) => state = state.copyWith(date: date);
  void setNote(String note) => state = state.copyWith(note: note);
  void toggleRecurring() =>
      state = state.copyWith(isRecurring: !state.isRecurring);
  void setInterval(int days) =>
      state = state.copyWith(recurringIntervalDays: days);

  Future<void> save(WidgetRef ref) async {
    if (!state.isValid) {
      return;
    }
    state = state.copyWith(isSaving: true);
    final repo = ref.read(transactionRepositoryProvider);

    if (state.id != null) {
      final updated = Transaction(
        id: state.id!,
        title: state.title.trim(),
        amount: state.amount,
        type: state.type,
        categoryId: state.categoryId!,
        note: state.note,
        date: state.date.millisecondsSinceEpoch,
        isRecurring: state.isRecurring,
        recurringIntervalDays:
            state.isRecurring ? state.recurringIntervalDays : null,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await repo.updateTransaction(updated);
    } else {
      await repo.addTransaction(
        title: state.title.trim(),
        amount: state.amount,
        type: state.type,
        categoryId: state.categoryId!,
        note: state.note,
        date: state.date,
        isRecurring: state.isRecurring,
        recurringIntervalDays:
            state.isRecurring ? state.recurringIntervalDays : null,
      );
    }

    state = state.copyWith(isSaving: false);
  }

  void loadFromTransaction(Transaction t) {
    state = state.copyWith(
      id: t.id,
      amountString:
          t.amount % 1 == 0 ? t.amount.toInt().toString() : t.amount.toString(),
      type: t.type,
      title: t.title,
      categoryId: t.categoryId,
      date: DateTime.fromMillisecondsSinceEpoch(t.date),
      note: t.note,
      isRecurring: t.isRecurring,
      recurringIntervalDays: t.recurringIntervalDays,
    );
  }

  String _sanitizeAmount(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) {
      return '0';
    }

    final hasDecimal = cleaned.contains('.');
    final parts = cleaned.split('.');
    var whole = parts.first.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    if (whole.isEmpty) {
      whole = '0';
    }
    if (whole.length > 9) {
      whole = whole.substring(0, 9);
    }

    if (!hasDecimal) {
      return whole;
    }

    final decimalPart = parts.skip(1).join();
    final decimals = decimalPart.substring(
        0, decimalPart.length > 2 ? 2 : decimalPart.length);
    if (cleaned.endsWith('.') && decimals.isEmpty) {
      return '$whole.';
    }
    return '$whole.$decimals';
  }
}

final addTransactionFormProvider = StateNotifierProvider.autoDispose<
    AddTransactionFormNotifier, AddTransactionFormState>(
  (ref) => AddTransactionFormNotifier(),
);
