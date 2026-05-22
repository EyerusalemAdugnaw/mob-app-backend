class SaleItem {
  final String id;
  final String date;
  final String time;
  final String product;
  final String batch;
  final num sold;
  final String formattedSold;

  SaleItem({
    required this.id,
    required this.date,
    required this.time,
    required this.product,
    required this.batch,
    required this.sold,
    required this.formattedSold,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      id: json['id'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      product: json['product'] ?? '',
      batch: json['batch'] ?? '',
      sold: json['sold'] ?? 0,
      formattedSold: json['formattedSold'] ?? '',
    );
  }
}
