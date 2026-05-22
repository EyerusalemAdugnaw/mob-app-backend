import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';
import 'main_layout.dart';

class FirstLoginPasswordScreen extends StatefulWidget {
  final String email;
  final String currentPassword;

  const FirstLoginPasswordScreen({
    Key? key,
    required this.email,
    required this.currentPassword,
  }) : super(key: key);

  @override
  _FirstLoginPasswordScreenState createState() => _FirstLoginPasswordScreenState();
}

class _FirstLoginPasswordScreenState extends State<FirstLoginPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  String _errorMessage = '';

  void _updatePassword() async {
    final newPass = _newPasswordController.text;
    final confPass = _confirmPasswordController.text;

    if (newPass.isEmpty || confPass.isEmpty) {
      setState(() => _errorMessage = 'Please enter and confirm your new password');
      return;
    }

    if (newPass == widget.currentPassword) {
      setState(() => _errorMessage = 'New password must be different from the default password');
      return;
    }

    if (newPass != confPass) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _apiService.put('/users/change-password', {
        'email': widget.email,
        'currentPassword': widget.currentPassword,
        'newPassword': newPass,
      });

      // Update success, we are already logged in so we can just go to the dashboard
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => MainLayout()),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Force them to change or kill app
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppConstants.backgroundColor, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppConstants.defaultPadding * 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.security, size: 80, color: AppConstants.primaryColor),
                SizedBox(height: 24),
                Text(
                  'Action Required',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimary,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'You are logging in with a default password. For your security, please create a new password before accessing your dashboard.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppConstants.textSecondary,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32),
                TextField(
                  controller: _newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  obscureText: true,
                ),
                if (_errorMessage.isNotEmpty) ...[
                  SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    style: TextStyle(color: AppConstants.error),
                    textAlign: TextAlign.center,
                  ),
                ],
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Update & Continue',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Allows them to cancel and log out if they don't want to change it
                    Navigator.of(context).pop(); 
                  },
                  child: Text(
                    'Cancel and Logout',
                    style: TextStyle(color: AppConstants.textSecondary, fontWeight: FontWeight.bold),
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
