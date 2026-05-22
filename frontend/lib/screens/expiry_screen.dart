import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/stock_item.dart';
import '../utils/constants.dart';

class ExpiryScreen extends StatefulWidget {
  @override
  _ExpiryScreenState createState() => _ExpiryScreenState();
}

class _ExpiryScreenState extends State<ExpiryScreen> {
  final ApiService _apiService = ApiService();
  List<StockItem> _allStock = [];
  List<StockItem> _filteredStock = [];
  bool _isLoading = true;
  String _error = '';
  
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All Product';
  List<String> _categories = ['All Product'];

  @override
  void initState() {
    super.initState();
    _fetchStock();
  }

  Future<void> _fetchStock() async {
    try {
      final response = await _apiService.get('/branch-manager/stock');
      setState(() {
        _allStock = (response['stock'] as List)
            .map((i) => StockItem.fromJson(i))
            .toList();
        
        _allStock.sort((a, b) => a.rawExpiry.compareTo(b.rawExpiry));
        
        final Set<String> productNames = _allStock.map((s) => s.product).toSet();
        _categories = ['All Product', ...productNames.toList()..sort()];

        if (!_categories.contains(_selectedCategory)) {
          _selectedCategory = 'All Product';
        }
        
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredStock = _allStock.where((item) {
        final matchesSearch = item.product.toLowerCase().contains(_searchQuery.toLowerCase()) || 
                              item.batch.toLowerCase().contains(_searchQuery.toLowerCase());
        
        bool matchesCategory = true;
        if (_selectedCategory != 'All Product') {
          matchesCategory = item.product.toLowerCase().contains(_selectedCategory.toLowerCase());
        }
        
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Widget _buildStatCard(String title, String subtitle, int count, int total, Color color) {
    final percent = total > 0 ? ((count / total) * 100).toStringAsFixed(0) : '0';
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: AppConstants.textSecondary, fontSize: 10), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          SizedBox(height: 8),
          Text('$percent%', style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          Text('$count/$total', style: TextStyle(color: AppConstants.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'Fresh') return AppConstants.success;
    if (status == 'Near Expiry') return AppConstants.warning;
    return AppConstants.error;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
    if (_error.isNotEmpty) return Center(child: Text(_error, style: TextStyle(color: AppConstants.error)));

    final totalBatches = _allStock.length;
    final freshBatches = _allStock.where((item) => item.status == 'Fresh').length;
    final nearBatches = _allStock.where((item) => item.status == 'Near Expiry').length;
    final expiredBatches = _allStock.where((item) => item.status == 'Expired').length;

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
          onRefresh: _fetchStock,
          color: AppConstants.primaryColor,
          child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Expiry Alerts', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppConstants.textPrimary)),
              SizedBox(height: 4),
              Text('Review freshness and prioritize distribution', style: TextStyle(fontSize: 14, color: AppConstants.textSecondary)),
              SizedBox(height: 20),

              // Side by side Summary Cards
              Row(
                children: [
                  Expanded(child: _buildStatCard('Fresh', '> 7 days left', freshBatches, totalBatches, AppConstants.success)),
                  SizedBox(width: 8),
                  Expanded(child: _buildStatCard('Near Expiry', '< 7 days left', nearBatches, totalBatches, AppConstants.warning)),
                  SizedBox(width: 8),
                  Expanded(child: _buildStatCard('Expired', 'Immediate removal', expiredBatches, totalBatches, AppConstants.error)),
                ],
              ),
              SizedBox(height: 24),

              // Search Input and Dropdown side by side
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search batches...',
                        prefixIcon: Icon(Icons.search, color: AppConstants.textSecondary),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _applyFilters();
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.grey.shade50],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedCategory,
                          items: _categories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category, overflow: TextOverflow.ellipsis),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedCategory = newValue;
                                _applyFilters();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Products Table
              Text(_selectedCategory == 'All Product' ? 'All Products' : _selectedCategory, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textPrimary)),
              SizedBox(height: 4),
              Text('${_filteredStock.length} local batches', style: TextStyle(fontSize: 14, color: AppConstants.textSecondary)),
              SizedBox(height: 12),
              
              if (_filteredStock.isEmpty)
                Center(child: Padding(padding: EdgeInsets.all(24), child: Text('No products found', style: TextStyle(color: AppConstants.textSecondary)))),
                
              if (_filteredStock.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.resolveWith((states) => Colors.grey.shade50),
                        columnSpacing: 20,
                        columns: const [
                          DataColumn(label: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Batch', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Expiry Date', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Days Left', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _filteredStock.map((item) {
                          final statusColor = _getStatusColor(item.status);
                          return DataRow(
                            cells: [
                              DataCell(Text(item.product, style: TextStyle(fontWeight: FontWeight.w500))),
                              DataCell(Text(item.batch)),
                              DataCell(Text(item.formattedQty)),
                              DataCell(Text(item.rawExpiry.split('T').first)),
                              DataCell(Text(item.daysLeft, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold))),
                              DataCell(
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(item.status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ]
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
