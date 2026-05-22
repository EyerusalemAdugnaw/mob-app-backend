import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/dashboard_data.dart';
import '../utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  DashboardData? _data;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  Future<void> _fetchDashboard() async {
    try {
      final response = await _apiService.get('/branch-manager/dashboard');
      setState(() {
        _data = DashboardData.fromJson(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Widget _buildTopCard(String title, String count, String subtitle, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: Offset(0, 2))],
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: AppConstants.textSecondary, fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(count, style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Icon(icon, color: color.withOpacity(0.8), size: 32),
            ],
          ),
          SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: AppConstants.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
              SizedBox(width: 8),
              Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ],
          ),
          Text('$count batches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
    if (_error.isNotEmpty) return Center(child: Text(_error, style: TextStyle(color: AppConstants.error)));
    if (_data == null) return Center(child: Text('No data available'));

    final String todayDate = DateFormat('EEEE, MMMM d').format(DateTime.now());

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppConstants.backgroundColor, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _fetchDashboard,
          color: AppConstants.primaryColor,
          child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('Welcome !', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppConstants.textPrimary)),
              SizedBox(height: 4),
              Text('Your branch overview', style: TextStyle(fontSize: 16, color: AppConstants.textSecondary)),
              SizedBox(height: 24),
              


              // Overview Cards
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTopCard(
                          'Total Stock', 
                          '${_data!.totalStockItems}', 
                          '${_data!.totalBatches} batches', 
                          AppConstants.primaryColor,
                          Icons.inventory_2_outlined
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildTopCard(
                          'Today Sales', 
                          '${_data!.todaySalesCount}', 
                          'units sold', 
                          AppConstants.success,
                          Icons.point_of_sale
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTopCard(
                          'Redistributions', 
                          '${_data!.activeRedistributionsCount}', 
                          'active requests', 
                          AppConstants.fresh,
                          Icons.local_shipping_outlined
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildTopCard(
                          'Near Expiry', 
                          '${_data!.expiredCount + _data!.nearCount}', 
                          '${_data!.expiredCount} exp, ${_data!.nearCount} near', 
                          AppConstants.warning,
                          Icons.warning_amber_rounded
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 24),
              Text('Recent Activities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textPrimary)),
              SizedBox(height: 12),
              if (_data!.recentActivities.isEmpty)
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(child: Text('No recent activities.', style: TextStyle(color: AppConstants.textSecondary))),
                )
              else
                ..._data!.recentActivities.map((activity) {
                  final isSale = activity.type == 'sale';
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4)],
                    ),
                    child: ListTile(
                       leading: CircleAvatar(
                         backgroundColor: isSale ? AppConstants.success.withOpacity(0.1) : AppConstants.fresh.withOpacity(0.1),
                         child: Icon(isSale ? Icons.point_of_sale : Icons.local_shipping, color: isSale ? AppConstants.success : AppConstants.fresh),
                       ),
                       title: Text(activity.desc, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                       subtitle: Text(DateFormat('MMM dd, hh:mm a').format(DateTime.parse(activity.date)), style: TextStyle(fontSize: 12)),
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
