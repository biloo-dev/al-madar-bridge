class Equipment {
  final String key;
  final String label;

  const Equipment({
    required this.key,
    required this.label,
  });
}

class EquipmentData {
  static const List<Equipment> items = [
    Equipment(key: 'excavator', label: 'حفارة مجنزرة'),
    Equipment(key: 'loader', label: 'جرافة هيدروليكية'),
    Equipment(key: 'truck', label: 'شاحنة قطب ثقيل'),
    Equipment(key: 'crane', label: 'رافعة برجية'),
    Equipment(key: 'generator', label: 'مولد طاقة مستقل'),
  ];
}