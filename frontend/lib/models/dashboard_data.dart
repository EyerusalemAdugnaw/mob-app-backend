class CriticalAlert {
  final String id;
  final String type;
  final String product;
  final String batch;
  final String days;
  final String qty;

  CriticalAlert({
    required this.id,
    required this.type,
    required this.product,
    required this.batch,
    required this.days,
    required this.qty,
  });

  factory CriticalAlert.fromJson(Map<String, dynamic> json) {
    return CriticalAlert(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      product: json['product'] ?? '',
      batch: json['batch'] ?? '',
      days: json['days'] ?? '',
      qty: json['qty'] ?? '',
    );
  }
}

class ProductStock {
  final String name;
  final num total;
  final String unit;

  ProductStock({
    required this.name,
    required this.total,
    required this.unit,
  });

  factory ProductStock.fromJson(Map<String, dynamic> json) {
    return ProductStock(
      name: json['name'] ?? '',
      total: json['total'] ?? 0,
      unit: json['unit'] ?? '',
    );
  }
}

class RecentActivity {
  final String type;
  final String desc;
  final String date;

  RecentActivity({required this.type, required this.desc, required this.date});

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      type: json['type'] ?? '',
      desc: json['desc'] ?? '',
      date: json['date'] ?? '',
    );
  }
}

class DashboardData {
  final String branchName;
  final int totalBatches;
  final int totalStockItems;
  final int freshCount;
  final int nearCount;
  final int expiredCount;
  final int todaySalesCount;
  final int activeRedistributionsCount;
  final List<CriticalAlert> criticalAlerts;
  final List<ProductStock> productStocks;
  final List<RecentActivity> recentActivities;

  DashboardData({
    required this.branchName,
    required this.totalBatches,
    required this.totalStockItems,
    required this.freshCount,
    required this.nearCount,
    required this.expiredCount,
    required this.todaySalesCount,
    required this.activeRedistributionsCount,
    required this.criticalAlerts,
    required this.productStocks,
    required this.recentActivities,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      branchName: json['branchName'] ?? 'Unknown',
      totalBatches: json['totalBatches'] ?? 0,
      totalStockItems: json['totalStockItems'] ?? 0,
      freshCount: json['freshCount'] ?? 0,
      nearCount: json['nearCount'] ?? 0,
      expiredCount: json['expiredCount'] ?? 0,
      todaySalesCount: json['todaySalesCount'] ?? 0,
      activeRedistributionsCount: json['activeRedistributionsCount'] ?? 0,
      criticalAlerts: (json['criticalAlerts'] as List?)
              ?.map((item) => CriticalAlert.fromJson(item))
              .toList() ??
          [],
      productStocks: (json['productStocks'] as List?)
              ?.map((item) => ProductStock.fromJson(item))
              .toList() ??
          [],
      recentActivities: (json['recentActivities'] as List?)
              ?.map((item) => RecentActivity.fromJson(item))
              .toList() ??
          [],
    );
  }
}
