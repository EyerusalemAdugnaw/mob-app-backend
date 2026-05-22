import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/sale_item.dart';
import '../models/stock_item.dart';
import '../utils/constants.dart';

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final ApiService _apiService = ApiService();
  List<SaleItem> _sales = [];
  bool _isLoading = true;
  String _error = '';

  List<StockItem> _availableBatches = [];

  // Form State
  String? _selectedProductBatch;
  final TextEditingController _qtyController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchSales();
  }

  Future<void> _fetchSales() async {
    try {
      final salesResponse = await _apiService.get('/branch-manager/sales');
      final stockResponse = await _apiService.get('/branch-manager/stock');
      setState(() {
        _sales = (salesResponse['sales'] as List).map((i) => SaleItem.fromJson(i)).toList();
        
        final batches = (stockResponse['stock'] as List)
            .map((i) => StockItem.fromJson(i))
            .where((item) => item.qty > 0)
            .toList();
            
        // Deduplicate batches by ID to prevent Dropdown crash
        final uniqueBatches = <String, StockItem>{};
        for (var b in batches) {
          uniqueBatches[b.id] = b;
        }
        _availableBatches = uniqueBatches.values.toList();

        // Prevent Dropdown crash if selected value no longer exists
        if (_selectedProductBatch != null && !_availableBatches.any((b) => b.id == _selectedProductBatch)) {
          _selectedProductBatch = null;
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

  void _recordSale() async {
    if (_selectedProductBatch == null || _qtyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppConstants.error)
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _apiService.post('/branch-manager/sales', {
        'batch_id': _selectedProductBatch,
        'quantity': int.tryParse(_qtyController.text) ?? 0,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sale recorded successfully!'), backgroundColor: AppConstants.success)
      );
      
      setState(() {
        _selectedProductBatch = null;
        _qtyController.clear();
      });

      _fetchSales();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppConstants.error)
      );
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
          Text('Record Sale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textPrimary)),
          SizedBox(height: 16),
          
          Text('Select Product Batch', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConstants.textPrimary)),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'Choose product batch...',
              prefixIcon: Icon(Icons.qr_code, color: AppConstants.textSecondary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: Colors.white,
            ),
            value: _selectedProductBatch,
            items: _availableBatches.map((s) => DropdownMenuItem(value: s.id, child: Text('${s.product} - ${s.batch} (${s.formattedQty} left)'))).toList(),
            onChanged: (val) => setState(() => _selectedProductBatch = val),
          ),
          SizedBox(height: 16),
          
          Text('Quantity Sold', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppConstants.textPrimary)),
          SizedBox(height: 8),
          TextField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter quantity sold...',
              prefixIcon: Icon(Icons.shopping_cart_outlined, color: AppConstants.textSecondary),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _recordSale,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _isSubmitting 
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Update Sales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
          onRefresh: _fetchSales,
          color: AppConstants.primaryColor,
          child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Update Sales', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppConstants.textPrimary)),
              SizedBox(height: 4),
              Text('Record sold quantities — stock updates automatically', style: TextStyle(fontSize: 14, color: AppConstants.textSecondary)),
              SizedBox(height: 24),

              _buildForm(),

              Text('Sales History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.textPrimary)),
              SizedBox(height: 4),
              Text('Recently recorded sales for your branch', style: TextStyle(fontSize: 14, color: AppConstants.textSecondary)),
              SizedBox(height: 16),

              if (_isLoading)
                Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppConstants.primaryColor)))
              else if (_error.isNotEmpty)
                Center(child: Padding(padding: EdgeInsets.all(32), child: Text(_error, style: TextStyle(color: AppConstants.error))))
              else if (_sales.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Text('No sales transactions located.', style: TextStyle(color: AppConstants.textSecondary, fontSize: 16)),
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
                          DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Product', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Batch No.', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Qty Sold', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: _sales.map((sale) {
                          return DataRow(
                            cells: [
                              DataCell(Text('${sale.date}', style: TextStyle(color: AppConstants.textSecondary))),
                              DataCell(Text(sale.product, style: TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(Text(sale.batch)),
                              DataCell(Text(sale.formattedSold, style: TextStyle(color: AppConstants.success, fontWeight: FontWeight.bold))),
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
