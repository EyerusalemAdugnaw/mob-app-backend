import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/transfer_item.dart';
import '../utils/constants.dart';

class TransfersScreen extends StatefulWidget {
  @override
  _TransfersScreenState createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> {
  final ApiService _apiService = ApiService();
  List<TransferItem> _transfers = [];
  bool _isLoading = true;
  String _error = '';

  // Form State
  String _transferType = 'send';
  String? _selectedProduct;
  final TextEditingController _qtyController = TextEditingController();
  String? _selectedDestination;
  bool _isSubmitting = false;
  bool _isFetchingRecommendations = false;
  List<Map<String, dynamic>> _recommendedBranches = [];

  List<dynamic> _productsList = [];
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchTransfers();
  }

  Future<void> _fetchProducts() async {
    try {
      final response = await _apiService.get('/branch-manager/transfer-options');
      setState(() {
        _productsList = response['products'] ?? [];
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
      });
      print('Error fetching products: $e');
    }
  }

  Future<void> _fetchTransfers() async {
    try {
      final response = await _apiService.get('/branch-manager/transfers');
      setState(() {
        _transfers = (response['transfers'] as List).map((i) => TransferItem.fromJson(i)).toList();
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
    if (status == 'Completed' || status == 'Accepted') return AppConstants.success;
    if (status == 'Rejected') return AppConstants.error;
    return AppConstants.warning;
  }

  Future<void> _fetchRecommendations() async {
    if (_selectedProduct == null || _qtyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select product and quantity first'), backgroundColor: AppConstants.error));
      return;
    }
    setState(() => _isFetchingRecommendations = true);
    try {
      final response = await _apiService.post('/branch-manager/transfer-recommendations', {
        'product_id': _selectedProduct,
        'quantity': int.tryParse(_qtyController.text) ?? 0,
        'type': _transferType,
      });
      setState(() {
        _recommendedBranches = List<Map<String, dynamic>>.from(response['recommendations'] ?? []);
        _selectedDestination = null;
        _isFetchingRecommendations = false;
      });
      if (_recommendedBranches.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No suitable branches found'), backgroundColor: AppConstants.warning));
      }
    } catch (e) {
      setState(() => _isFetchingRecommendations = false);
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg), backgroundColor: AppConstants.error));
    }
  }

  void _submitRequest() async {
    if (_selectedProduct == null || _qtyController.text.isEmpty || _selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please fill all required fields'), backgroundColor: AppConstants.error));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _apiService.post('/branch-manager/transfers', {
        'product_id': _selectedProduct,
        'quantity': int.tryParse(_qtyController.text) ?? 0,
        'transfer_type': _transferType,
        'to_branch_id': _transferType == 'send' ? _selectedDestination : null,
        'from_branch_id': _transferType == 'request' ? _selectedDestination : null,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request sent successfully!'), backgroundColor: AppConstants.success));
      
      setState(() {
        _selectedProduct = null;
        _qtyController.clear();
        _selectedDestination = null;
        _recommendedBranches.clear();
      });

      _fetchTransfers();
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg), backgroundColor: AppConstants.error));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _updateTransferStatus(String id, String status) async {
    try {
      await _apiService.put('/branch-manager/transfers/$id', {
        'status': status,
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request $status'), backgroundColor: AppConstants.success));
      _fetchTransfers();
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg), backgroundColor: AppConstants.error));
    }
  }

  Widget _buildForm() {
    return Container(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Redistribution', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.textPrimary)),
          Text('Start or accept redistribution', style: TextStyle(fontSize: 14, color: AppConstants.textSecondary)),
          SizedBox(height: 16),
          Text('New Redistribution Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.textPrimary)),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text('Send Stock'),
                  value: 'send',
                  groupValue: _transferType,
                  onChanged: (val) => setState(() { _transferType = val!; _recommendedBranches.clear(); _selectedDestination = null; }),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: Text('Request Stock'),
                  value: 'request',
                  groupValue: _transferType,
                  onChanged: (val) => setState(() { _transferType = val!; _recommendedBranches.clear(); _selectedDestination = null; }),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Product Type',
                    prefixIcon: Icon(Icons.category_outlined, color: AppConstants.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  value: _selectedProduct,
                  items: _productsList.map((p) => DropdownMenuItem<String>(value: p['id'].toString(), child: Text(p['name'].toString()))).toList(),
                  onChanged: (val) => setState(() => _selectedProduct = val),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                flex: 1,
                child: TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Qty',
                    prefixIcon: Icon(Icons.production_quantity_limits, color: AppConstants.textSecondary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isFetchingRecommendations ? null : _fetchRecommendations,
              icon: _isFetchingRecommendations 
                  ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.search),
              label: Text(_transferType == 'send' ? 'Find Branches to Send To' : 'Find Branches with Stock'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          SizedBox(height: 12),

          if (_recommendedBranches.isNotEmpty) ...[
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: _transferType == 'send' ? 'Destination Branch' : 'Source Branch',
                prefixIcon: Icon(Icons.store_outlined, color: AppConstants.textSecondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              value: _selectedDestination,
              items: _recommendedBranches.map((b) => DropdownMenuItem<String>(
                value: b['branch_id'], 
                child: Text('${b['branch_name']} (${b['available_stock']} in stock)')
              )).toList(),
              onChanged: (val) => setState(() => _selectedDestination = val),
            ),
            SizedBox(height: 16),
          ],
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting 
                ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('Send Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
        child: Column(
        children: [
          _buildForm(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Text('Incoming Requests & Transfers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppConstants.textPrimary)),
                ),
                Expanded(
                  child: _isLoading 
                    ? Center(child: CircularProgressIndicator(color: AppConstants.primaryColor))
                    : _error.isNotEmpty 
                      ? Center(child: Text(_error, style: TextStyle(color: AppConstants.error)))
                      : RefreshIndicator(
                          onRefresh: _fetchTransfers,
                          color: AppConstants.primaryColor,
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
                            itemCount: _transfers.length,
                            itemBuilder: (context, index) {
                              final transfer = _transfers[index];
                              final statusColor = _getStatusColor(transfer.status);
                              final isIncomingPending = transfer.direction == 'Inbound' && transfer.status == 'Pending';
                              
                              return Card(
                                margin: EdgeInsets.only(bottom: 12),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: Colors.black.withOpacity(0.05)),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              transfer.direction == 'Inbound' ? 'From ${transfer.from}' : 'To ${transfer.to}',
                                              style: TextStyle(color: AppConstants.textSecondary, fontSize: 13),
                                            ),
                                          ),
                                          if (transfer.type == 'request' && transfer.direction == 'Outbound')
                                            Container(
                                              margin: EdgeInsets.only(right: 8),
                                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(4)),
                                              child: Text('Requested by them', style: TextStyle(color: Colors.blue.shade800, fontSize: 10)),
                                            ),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                            child: Text(transfer.status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                          )
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(transfer.product, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          Text(transfer.formattedQty, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        ],
                                      ),
                                      if (isIncomingPending || (transfer.direction == 'Outbound' && transfer.status == 'Pending' && transfer.type == 'request')) ...[
                                        SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () => _updateTransferStatus(transfer.id, 'Rejected'),
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: AppConstants.error,
                                                  side: BorderSide(color: AppConstants.error),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                ),
                                                child: Text('Reject'),
                                              ),
                                            ),
                                            SizedBox(width: 12),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () => _updateTransferStatus(transfer.id, 'In-transit'),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppConstants.success,
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                                ),
                                                child: Text('Accept', style: TextStyle(color: Colors.white)),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                      if (transfer.status == 'In-transit' && ((transfer.type == 'send' && transfer.direction == 'Inbound') || (transfer.type == 'request' && transfer.direction == 'Inbound'))) ...[
                                        SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () => _updateTransferStatus(transfer.id, 'Completed'),
                                            icon: Icon(Icons.check_circle_outline, color: Colors.white),
                                            label: Text('Accept Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppConstants.primaryColor,
                                              padding: EdgeInsets.symmetric(vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                          ),
                                        )
                                      ]
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          )
        ],
      ),
      ),
    );
  }
}
