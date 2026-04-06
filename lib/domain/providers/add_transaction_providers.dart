import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/app_database.dart';
import '../../domain/providers/database_providers.dart';

class AddTransactionFormState {
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
  bool get isValid => amount > 0 && title.trim().isNotEmpty && categoryId != null;

  AddTransactionFormState({
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
      amountString: amountString ?? this.amountString,
      type: type ?? this.type,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringIntervalDays: recurringIntervalDays ?? this.recurringIntervalDays,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class AddTransactionFormNotifier extends StateNotifier<AddTransactionFormState> {
  AddTransactionFormNotifier() : super(AddTransactionFormState());

  void appendDigit(String digit) {
    if (digit == '.' && state.amountString.contains('.')) return;
    if (state.amountString.contains('.') && state.amountString.split('.')[1].length >= 2) return;
    
    // Max value check
    if (state.amountString.length >= 7 && !state.amountString.contains('.')) return;

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
      state = state.copyWith(amountString: state.amountString.substring(0, state.amountString.length - 1));
    }
  }

  void setType(String type) => state = state.copyWith(type: type);
  void setTitle(String title) => state = state.copyWith(title: title);
  void setCategory(String categoryId) => state = state.copyWith(categoryId: categoryId);
  void setDate(DateTime date) => state = state.copyWith(date: date);
  void setNote(String note) => state = state.copyWith(note: note);
  void toggleRecurring() => state = state.copyWith(isRecurring: !state.isRecurring);
  void setInterval(int days) => state = state.copyWith(recurringIntervalDays: days);

  Future<void> save(WidgetRef ref) async {
    if (!state.isValid) return;
    state = state.copyWith(isSaving: true);
    final repo = ref.read(transactionRepositoryProvider);
    
    await repo.addTransaction(
      title: state.title.trim(),
      amount: state.amount,
      type: state.type,
      categoryId: state.categoryId!,
      note: state.note,
      date: state.date,
      isRecurring: state.isRecurring,
      recurringIntervalDays: state.isRecurring ? state.recurringIntervalDays : null,
    );
    
    state = state.copyWith(isSaving: false);
  }

  void loadFromTransaction(Transaction t) {
    state = state.copyWith(
      amountString: t.amount.toString(),
      type: t.type,
      title: t.title,
      categoryId: t.categoryId,
      date: DateTime.fromMillisecondsSinceEpoch(t.date),
      note: t.note,
      isRecurring: t.isRecurring,
      recurringIntervalDays: t.recurringIntervalDays,
    );
  }
}

final addTransactionFormProvider = StateNotifierProvider.autoDispose<AddTransactionFormNotifier, AddTransactionFormState>(
  (ref) => AddTransactionFormNotifier(),
);
