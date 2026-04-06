import 'package:drift/drift.dart';
import '../../data/repositories/transaction_repository.dart';

class RecurringService {
  final TransactionRepository _txRepo;
  RecurringService(this._txRepo);
  
  Future<int> checkAndAutoLog() async {
    final recurring = await _txRepo.getRecurringTransactions();
    int count = 0;
    
    for (final t in recurring) {
      if (t.recurringIntervalDays == null) continue;
      
      final lastDate = t.lastRecurringDate != null
          ? DateTime.fromMillisecondsSinceEpoch(t.lastRecurringDate!)
          : DateTime.fromMillisecondsSinceEpoch(t.date);
      
      final nextDue = lastDate.add(Duration(days: t.recurringIntervalDays!));
      
      if (DateTime.now().isAfter(nextDue)) {
        // Auto-log a copy of this transaction
        await _txRepo.addTransaction(
          title: '${t.title} (Auto 🔁)',
          amount: t.amount,
          type: t.type,
          categoryId: t.categoryId,
          note: t.note,
          date: DateTime.now(),
          isRecurring: false, // copy is not recurring itself
        );
        
        // Update lastRecurringDate on the original
        // Note: we need to find the correct entity to update.
        // The recurring list gave us DataClass objects. We need to update them.
        final updated = t.copyWith(
          lastRecurringDate: Value(DateTime.now().millisecondsSinceEpoch),
        );
        await _txRepo.updateTransaction(updated);
        count++;
      }
    }
    return count;
  }
}
