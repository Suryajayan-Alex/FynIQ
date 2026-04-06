import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/providers/database_providers.dart';

class CsvExporter {
  static Future<void> export(WidgetRef ref) async {
    final txRepo = ref.read(transactionRepositoryProvider);
    final catRepo = ref.read(categoryRepositoryProvider);
    
    // Get all transactions
    final transactions = await txRepo.watchByDateRange(
      DateTime(2000), 
      DateTime.now().add(const Duration(days: 1))
    ).first;
    
    final categories = await catRepo.getAllCategories();
    final catMap = {for (final c in categories) c.id: c};
    
    final buffer = StringBuffer();
    buffer.writeln('Date,Title,Category,Type,Amount,Note');
    
    for (final t in transactions) {
      final cat = catMap[t.categoryId];
      final date = DateFormat('dd/MM/yyyy').format(DateTime.fromMillisecondsSinceEpoch(t.date));
      final title = t.title.replaceAll(',', ';');
      final note = (t.note ?? '').replaceAll(',', ';').replaceAll('\n', ' ');
      
      buffer.writeln('$date,$title,${cat?.name ?? 'Unknown'},${t.type},${t.amount},$note');
    }
    
    Directory? dir;
    if (Platform.isAndroid) {
       dir = Directory('/storage/emulated/0/Download');
       if (!await dir.exists()) {
         dir = await getExternalStorageDirectory();
       }
    } else {
      dir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
    }
    
    final file = File('${dir!.path}/fyniq_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(buffer.toString());
  }
}
