import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/fyniq_scaffold.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../domain/providers/dashboard_providers.dart';
import '../../../domain/providers/database_providers.dart';
import '../../widgets/add_category_sheet.dart';

class ManageCategoriesScreen extends ConsumerWidget {
  const ManageCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return FyniqScaffold(
      body: categoriesAsync.when(
        data: (cats) => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: FyniqColors.background.withOpacity(0.8),
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text("Categories 🏷️", style: FyniqTextStyles.headingM),
              leading: IconButton(
                icon: const Icon(Iconsax.arrow_left_1, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Iconsax.add, color: FyniqColors.primaryAccent),
                  onPressed: () => showAddCategorySheet(context, ref),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final cat = cats[i];
                    final catColor = Color(int.parse(cat.colorHex.replaceAll('#', '0xFF')));

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: catColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(child: Text(cat.emoji, style: const TextStyle(fontSize: 22))),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                cat.name,
                                style: FyniqTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (!cat.isDefault)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Iconsax.edit_2, color: FyniqColors.textSecondary, size: 20),
                                    onPressed: () {
                                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Editing cat coming soon")));
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Iconsax.trash, color: FyniqColors.highlightCTA, size: 20),
                                    onPressed: () => _confirmDelete(context, ref, cat),
                                  ),
                                ],
                              )
                            else
                              Text("Default", style: FyniqTextStyles.caption.copyWith(color: Colors.grey)),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: cats.length,
                ),
              ),
            ),
          ],
        ),
        loading: () => const _ShimmerList(),
        error: (_, __) => const Center(child: Text("Error categories")),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, dynamic cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: FyniqColors.cardSurface,
        title: const Text("Delete Category?"),
        content: Text("Deleting '${cat.name}' will move its transactions to 'Other'."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              ref.read(categoryRepositoryProvider).deleteCategory(cat.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Deleted. 🗑️")));
            },
            child: const Text("Delete", style: TextStyle(color: FyniqColors.highlightCTA)),
          ),
        ],
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 8,
      itemBuilder: (_, __) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: ShimmerBox(width: double.infinity, height: 68, borderRadius: 20),
      ),
    );
  }
}
