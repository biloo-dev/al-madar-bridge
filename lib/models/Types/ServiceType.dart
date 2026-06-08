class ServiceType {
  final String key;
  final String label;

  const ServiceType({
    required this.key,
    required this.label,
  });
}

class ServiceData {
  static const List<ServiceType> items = [
    ServiceType(key: 'daily_rent', label: 'عرض كراء بالأيام'),
    ServiceType(key: 'sell', label: 'صيغة البيع الحر'),
    ServiceType(key: 'rent_or_sell', label: 'كراء وبيع معاً'),
  ];
}