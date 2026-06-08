class InvestmentType {
  final String key;
  final String label;

  const InvestmentType({
    required this.key,
    required this.label,
  });
}
class InvestmentData {
  static const List<InvestmentType> types = [
    InvestmentType(key: 'partnership', label: 'شراكة وتضامن'),
    InvestmentType(key: 'small_projects', label: 'تمويل مشاريع صغرى'),
    InvestmentType(key: 'real_estate', label: 'استثمار عقاري مهني'),
    InvestmentType(key: 'industrial', label: 'استثمار البنى الصناعية'),
  ];
}