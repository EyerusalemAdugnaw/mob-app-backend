import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'main_layout.dart';
import 'forgot_password_screen.dart';
import 'first_login_password_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await _authService.login(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['error'] == null) {
      if (result['mustChangePassword'] == true) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => FirstLoginPasswordScreen(
            email: _usernameController.text.trim(),
            currentPassword: _passwordController.text,
          )),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => MainLayout()),
        );
      }
    } else {
      setState(() {
        _errorMessage = result['error'];
      });
    }
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
        child: Center(
          child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConstants.defaultPadding * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.inventory_2_rounded, size: 80, color: AppConstants.primaryColor),
              SizedBox(height: 24),
              Text(
                'Dairy Stock Management',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Sign in to your account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppConstants.textSecondary,
                ),
              ),
              SizedBox(height: 32),
              TextField(
                controller: _usernameController, // Kept variable name the same to minimize changes, but handles email now
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
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
              SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(color: AppConstants.primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Sign In',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
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
