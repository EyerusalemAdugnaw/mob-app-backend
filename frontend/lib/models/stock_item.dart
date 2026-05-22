class StockItem {
  final String id;
  final String product;
  final String productId;
  final String batch;
  final num qty;
  final String unit;
  final String formattedQty;
  final String rawExpiry;
  final String daysLeft;
  final String status;

  StockItem({
    required this.id,
    required this.product,
    required this.productId,
    required this.batch,
    required this.qty,
    required this.unit,
    required this.formattedQty,
    required this.rawExpiry,
    required this.daysLeft,
    required this.status,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      id: json['id'] ?? '',
      product: json['product'] ?? '',
      productId: json['product_id'] ?? '',
      batch: json['batch'] ?? '',
      qty: json['qty'] ?? 0,
      unit: json['unit'] ?? '',
      formattedQty: json['formattedQty'] ?? '',
      rawExpiry: json['rawExpiry'] ?? '',
      daysLeft: json['daysLeft'] ?? '',
      status: json['status'] ?? 'Fresh',
    );
  }
}
