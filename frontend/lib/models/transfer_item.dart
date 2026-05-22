class TransferItem {
  final String id;
  final String direction;
  final String type; // 'send' or 'request'
  final String from;
  final String to;
  final String product;
  final String batch;
  final num qty;
  final String formattedQty;
  final String status;

  TransferItem({
    required this.id,
    required this.direction,
    required this.type,
    required this.from,
    required this.to,
    required this.product,
    required this.batch,
    required this.qty,
    required this.formattedQty,
    required this.status,
  });

  factory TransferItem.fromJson(Map<String, dynamic> json) {
    return TransferItem(
      id: json['id'] ?? '',
      direction: json['direction'] ?? 'Unknown',
      type: json['type'] ?? 'send',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      product: json['product'] ?? '',
      batch: json['batch'] ?? '',
      qty: json['qty'] ?? 0,
      formattedQty: json['formattedQty'] ?? '',
      status: json['status'] ?? 'Pending',
    );
  }
}
