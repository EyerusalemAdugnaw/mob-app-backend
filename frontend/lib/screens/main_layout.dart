import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'stock_screen.dart';
import 'sales_screen.dart';
import 'transfers_screen.dart';
import 'expiry_screen.dart';

class MainLayout extends StatefulWidget {
  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserEmail();
  }

  Future<void> _loadUserEmail() async {
    final email = await _authService.getEmail();
    if (email != null && mounted) {
      setState(() {
        _userEmail = email;
      });
    }
  }

  final List<Widget> _screens = [
    DashboardScreen(),
    StockScreen(),
    SalesScreen(),
    ExpiryScreen(),
    TransfersScreen(),
  ];

  final List<String> _titles = [
    'Dashboard',
    'Stock',
    'Sales',
    'Expiry',
    'Transfers',
  ];

  void _logout() async {
    await _authService.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.water_drop, color: Colors.white), // Dairy/Fresh logo placeholder
            SizedBox(width: 8),
            Text('Branch Manager', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: AppConstants.primaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.water_drop, color: Colors.white, size: 48),
                  SizedBox(height: 8),
                  Text(
                    _userEmail.isNotEmpty ? _userEmail : 'Branch Manager',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Branch Operation',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard, color: _currentIndex == 0 ? AppConstants.primaryColor : null),
              title: Text('Dashboard', style: TextStyle(color: _currentIndex == 0 ? AppConstants.primaryColor : null)),
              selected: _currentIndex == 0,
              onTap: () {
                setState(() => _currentIndex = 0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.inventory, color: _currentIndex == 1 ? AppConstants.primaryColor : null),
              title: Text('Stock', style: TextStyle(color: _currentIndex == 1 ? AppConstants.primaryColor : null)),
              selected: _currentIndex == 1,
              onTap: () {
                setState(() => _currentIndex = 1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.point_of_sale, color: _currentIndex == 2 ? AppConstants.primaryColor : null),
              title: Text('Sales', style: TextStyle(color: _currentIndex == 2 ? AppConstants.primaryColor : null)),
              selected: _currentIndex == 2,
              onTap: () {
                setState(() => _currentIndex = 2);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.warning_amber_rounded, color: _currentIndex == 3 ? AppConstants.primaryColor : null),
              title: Text('Expiry', style: TextStyle(color: _currentIndex == 3 ? AppConstants.primaryColor : null)),
              selected: _currentIndex == 3,
              onTap: () {
                setState(() => _currentIndex = 3);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.local_shipping, color: _currentIndex == 4 ? AppConstants.primaryColor : null),
              title: Text('Transfers', style: TextStyle(color: _currentIndex == 4 ? AppConstants.primaryColor : null)),
              selected: _currentIndex == 4,
              onTap: () {
                setState(() => _currentIndex = 4);
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppConstants.primaryColor,
          unselectedItemColor: AppConstants.textSecondary,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Stock'),
            BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Sales'),
            BottomNavigationBarItem(icon: Icon(Icons.warning_amber_rounded), label: 'Expiry'),
            BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Transfers'),
          ],
        ),
      ),
    );
  }
}
