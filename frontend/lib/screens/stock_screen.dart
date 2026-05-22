import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/stock_item.dart';
import '../utils/constants.dart';

class StockScreen extends StatefulWidget {
  @override
  _StockScreenState createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final ApiService _apiService = ApiService();
  List<StockItem> _stock = [];
  bool _isLoading = true;
  String _error = '';

  // Form State
  String? _selectedProductId;
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _batchController = TextEditingController();
  bool _isSubmitting = false;

  List<dynamic> _products = [];

  @override
  void initState() {
    super.initState();
    _fetchStock();
  }

  Future<void> _fetchStock() async {
    try {
      final response = await _apiService.get('/branch-manager/stock');
      final productResponse = await _apiService.get('/products');
      setState(() {
        _stock = (response['stock'] as List).map((i) => StockItem.fromJson(i)).toList();
        
        final rawProducts = productResponse['products'] as List;
        
        // Deduplicate products by ID to prevent Dropdown crash
        final uniqueProducts = <String, dynamic>{};
        for (var p in rawProducts) {
          uniqueProducts[p['id'].toString()] = p;
        }
        _products = uniqueProducts.values.toList();

        // Prevent Dropdown crash if selected value no longer exists
        if (_selectedProductId != null && !_products.any((p) => p['id'].toString() == _selectedProductId)) {
          _selectedProductId = null;
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    if (status == 'Expired') return AppConstants.error;
    if (status == 'Near Expiry') return AppConstants.warning;
    return AppConstants.success;
  }

  void _saveStock() async {
    if (_selectedProductId == null || _qtyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all required fields', style: TextStyle(color: Colors.white)), backgroundColor: AppConstants.error));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _apiService.post('/branch-manager/stock', {
        'product_id': _selectedProductId, 
        'quantity': int.tryParse(_qtyController.text) ?? 0,
        'batch_number': _batchController.text.isEmpty ? null : _batchController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stock added successfully!'), backgroundColor: AppConstants.success));
      
      setState(() {
        _selectedProductId = null;
        _qtyController.clear();
        _batchController.clear();
      });

      _fetchStock();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppConstants.error));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }



  Widget _buildForm() {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: Offset(0, 2))],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('New Stock Entry', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textPrimary)),
          SizedBox(height: 16),
          
          Text('Product Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConstants.textPrimary)),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Select product...',
              prefixIcon: Icon(Icons.category_outlined, color: AppConstants.textSecondary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: Colors.white,
            ),
            value: _selectedProductId,
            items: _products.map((p) => DropdownMenuItem<String>(value: p['id'].toString(), child: Text(p['name'].toString()))).toList(),
            onChanged: (val) => setState(() => _selectedProductId = val),
          ),
          SizedBox(height: 16),
          
          Text('Quantity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConstants.textPrimary)),
          SizedBox(height: 8),
          TextField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: _selectedProductId == null ? 'Select product first' : 'Enter quantity...',
              prefixIcon: Icon(Icons.production_quantity_limits, color: AppConstants.textSecondary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 16),

          Text('Product Batch Number', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConstants.textPrimary)),
          SizedBox(height: 8),
          TextField(
            controller: _batchController,
            decoration: InputDecoration(
              hintText: 'e.g. M-1092-A',
              prefixIcon: Icon(Icons.qr_code, color: AppConstants.textSecondary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 16),

          Text('Expiry Date (Auto-Calculated)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConstants.textPrimary)),
          SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.event_available, color: AppConstants.textSecondary, size: 24),
                SizedBox(width: 12),
                Text(
                  _selectedProductId == null 
                      ? 'Select a product first' 
                      : DateFormat('MMM dd, yyyy').format(DateTime.now().add(Duration(days: _products.firstWhere((p) => p['id'] == _selectedProductId)['shelf_life_days'] ?? 14))),
                  style: TextStyle(
                    fontSize: 16, 
                    color: _selectedProductId == null ? Colors.grey.shade500 : AppConstants.success,
                    fontWeight: _selectedProductId == null ? FontWeight.normal : FontWeight.bold,
                  )
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _saveStock,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isSubmitting 
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Save Stock Record', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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


              Text('Record Stock', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppConstants.textPrimary)),
              SizedBox(height: 4),
              Text('Log incoming stock for your branch', style: TextStyle(fontSize: 14, color: AppConstants.textSecondary)),
              SizedBox(height: 24),

              _buildForm(),

              Text('Stock History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.textPrimary)),
              SizedBox(height: 4),
              Text('Recently recorded stock batches for your branch', style: TextStyle(fontSize: 14, color: AppConstants.textSecondary)),
              SizedBox(height: 16),

              if (_isLoading)
                Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppConstants.primaryColor)))
              else if (_error.isNotEmpty)
                Center(child: Padding(padding: EdgeInsets.all(32), child: Text(_error, style: TextStyle(color: AppConstants.error))))
              else if (_stock.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Text('No stock transactions located.', style: TextStyle(color: AppConstants.textSecondary, fontSize: 16)),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.grey.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4)],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: MaterialStateProperty.resolveWith((states) => Colors.grey.shade50),
                        columns: const [
                          DataColumn(label: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Batch Number', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Quantity', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Expiry Date', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _stock.map((item) {
                          final statusColor = _getStatusColor(item.status);
                          return DataRow(
                            cells: [
                              DataCell(Text(item.product, style: TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(Text(item.batch)),
                              DataCell(Text(item.formattedQty)),
                              DataCell(Text(item.rawExpiry.split('T').first)),
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
                            ],
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
