import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/gradient_button.dart';
import '../../domain/providers/database_providers.dart';

class AddCategorySheet extends StatefulWidget {
  final WidgetRef ref;
  const AddCategorySheet({super.key, required this.ref});

  @override
  State<AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<AddCategorySheet> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedEmoji = '🏷️';
  Color _selectedColor = FyniqColors.primaryAccent;

  final List<Color> _presetColors = [
    FyniqColors.primaryAccent,
    FyniqColors.highlightCTA,
    FyniqColors.success,
    FyniqColors.warning,
    const Color(0xFF3B82F6), // Blue
    const Color(0xFFFACC15), // Yellow
    const Color(0xFF06B6D4), // Cyan
    const Color(0xFF8B5CF6), // Violet
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: GlassCard(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        borderRadius: 32,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: FyniqColors.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text("New Category", style: FyniqTextStyles.headingM),
            const SizedBox(height: 16),
            const Text("Pick an emoji", style: TextStyle(color: FyniqColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _showEmojiPicker,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: FyniqColors.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: FyniqColors.divider),
                ),
                child: Center(child: Text(_selectedEmoji, style: const TextStyle(fontSize: 32))),
              ),
            ),
            const SizedBox(height: 16),
            const Text("Category name", style: TextStyle(color: FyniqColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              autofocus: true,
              style: FyniqTextStyles.body,
              decoration: const InputDecoration(hintText: "e.g. Shopping"),
            ),
            const SizedBox(height: 16),
            const Text("Pick a color", style: TextStyle(color: FyniqColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _presetColors.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected ? Border.all(color: FyniqColors.textPrimary, width: 2) : null,
                    ),
                    child: isSelected ? const Icon(Icons.check, color: FyniqColors.textPrimary, size: 16) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: "Add Category",
              onPressed: () async {
                final name = _nameController.text.trim();
                if (name.isEmpty) return;
                
                final colorHex = '#${_selectedColor.value.toRadixString(16).substring(2).toUpperCase()}';
                
                await widget.ref.read(categoryRepositoryProvider).addCategory(
                  name: name,
                  emoji: _selectedEmoji,
                  colorHex: colorHex,
                );
                
                if (mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => EmojiPicker(
        onEmojiSelected: (category, emoji) {
          setState(() => _selectedEmoji = emoji.emoji);
          Navigator.pop(context);
        },
        config: const Config(
          height: 256,
          emojiViewConfig: EmojiViewConfig(
              backgroundColor: FyniqColors.backgroundAlt,
              columns: 7,
          ),
        ),
      ),
    );
  }
}

Future<void> showAddCategorySheet(BuildContext context, WidgetRef ref) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddCategorySheet(ref: ref),
  );
}
