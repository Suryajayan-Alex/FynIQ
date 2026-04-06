class AppConstants {
  static const List<Map<String, dynamic>> defaultCategories = [
    {
      'id': 'food',
      'name': 'Food & Drinks',
      'emoji': '🍔',
      'colorHex': '#FF5252',
      'isDefault': true,
    },
    {
      'id': 'shopping',
      'name': 'Shopping',
      'emoji': '🛍️',
      'colorHex': '#7C4DFF',
      'isDefault': true,
    },
    {
      'id': 'transport',
      'name': 'Transport',
      'emoji': '🚗',
      'colorHex': '#448AFF',
      'isDefault': true,
    },
    {
      'id': 'entertainment',
      'name': 'Fun',
      'emoji': '🎮',
      'colorHex': '#E040FB',
      'isDefault': true,
    },
    {
      'id': 'salary',
      'name': 'Salary',
      'emoji': '💰',
      'colorHex': '#4CAF50',
      'isDefault': true,
    },
    {
      'id': 'gift',
      'name': 'Gifts',
      'emoji': '🎁',
      'colorHex': '#FFD740',
      'isDefault': true,
    },
    {
      'id': 'other',
      'name': 'Other',
      'emoji': '✨',
      'colorHex': '#9E9E9E',
      'isDefault': true,
    },
  ];

  static const List<String> recurringIntervals = [
    'daily',
    'weekly',
    'monthly',
    'yearly',
  ];
}
