class Craft {
  final String key;
  final String label;

  const Craft({
    required this.key,
    required this.label,
  });
}

class CraftData {
  static const List<Craft> crafts = [
    Craft(key: 'carpenter', label: 'نجار'),
    Craft(key: 'blacksmith', label: 'حداد'),
    Craft(key: 'electrician', label: 'كهربائي'),
    Craft(key: 'plumber', label: 'سباك'),
    Craft(key: 'painter', label: 'دهان'),
  ];
}