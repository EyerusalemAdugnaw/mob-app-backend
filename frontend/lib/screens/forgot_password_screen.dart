import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _apiService = ApiService();

  int _step = 1;
  bool _isLoading = false;

  void _sendOTP() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Please enter your email address');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _apiService.post('/users/forgot-password', {'email': email});
      setState(() {
        _isLoading = false;
        _step = 2;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString().contains('does not exist') ? 'This email address does not exist' : e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _verifyOTP() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      _showError('Please enter the code');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _apiService.post('/users/verify-otp', {
        'email': _emailController.text.trim(),
        'code': code
      });
      setState(() {
        _isLoading = false;
        _step = 3;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('You have entered incorrect code !');
    }
  }

  void _resetPassword() async {
    final newPass = _newPasswordController.text;
    final confPass = _confirmPasswordController.text;

    if (newPass.isEmpty || confPass.isEmpty) {
      _showError('Please enter passwords');
      return;
    }

    if (newPass != confPass) {
      _showError('confirm password not matched');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _apiService.post('/users/reset-password', {
        'email': _emailController.text.trim(),
        'code': _codeController.text.trim(),
        'newPassword': newPass
      });
      setState(() {
        _isLoading = false;
        _step = 4; // success screen
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: AppConstants.error));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppConstants.textPrimary,
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
            child: _buildCurrentStep(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    if (_step == 1) return _buildStep1();
    if (_step == 2) return _buildStep2();
    if (_step == 3) return _buildStep3();
    return _buildSuccessStep();
  }

  Widget _buildStep1() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.mark_email_read_outlined, size: 80, color: AppConstants.primaryColor),
        SizedBox(height: 24),
        Text('Enter your address', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppConstants.textPrimary)),
        SizedBox(height: 32),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: 'Email Address',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: Colors.white,
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 32),
        _buildButton('Continue', _sendOTP),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.password, size: 80, color: AppConstants.primaryColor),
        SizedBox(height: 24),
        Text('Code Verification', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppConstants.textPrimary)),
        SizedBox(height: 12),
        Text('We have sent a password reset otp to your email-${_emailController.text}', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppConstants.textSecondary)),
        SizedBox(height: 32),
        TextField(
          controller: _codeController,
          decoration: InputDecoration(
            labelText: 'Enter Code',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: Colors.white,
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 32),
        _buildButton('Submit', _verifyOTP),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.lock_reset, size: 80, color: AppConstants.primaryColor),
        SizedBox(height: 24),
        Text('New Password', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppConstants.textPrimary)),
        SizedBox(height: 12),
        Text("Please create a new password that you don't use on any other site", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: AppConstants.textSecondary)),
        SizedBox(height: 32),
        TextField(
          controller: _newPasswordController,
          decoration: InputDecoration(
            labelText: 'Create new password',
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
            labelText: 'Confirm your password',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: Colors.white,
          ),
          obscureText: true,
        ),
        SizedBox(height: 32),
        _buildButton('Change', _resetPassword),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.check_circle_outline, size: 80, color: AppConstants.success),
        SizedBox(height: 24),
        Text('Your password changed. now you can login with your new password.', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppConstants.textPrimary)),
        SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppConstants.primaryColor,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Text('Login Now', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: _isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: _isLoading
          ? SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }
}
