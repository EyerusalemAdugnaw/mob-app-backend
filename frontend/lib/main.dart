import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/main_layout.dart';
import 'services/auth_service.dart';
import 'utils/constants.dart';

void main() {
  runApp(const BranchManagerApp());
}

class BranchManagerApp extends StatelessWidget {
  const BranchManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dairy Stock Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppConstants.primaryColor,
        scaffoldBackgroundColor: AppConstants.backgroundColor,
        textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
        colorScheme: ColorScheme.light(
          primary: AppConstants.primaryColor,
          secondary: AppConstants.secondaryColor,
        ),
      ),
      home: AuthChecker(),
    );
  }
}

class AuthChecker extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          if (snapshot.data == true) {
            return MainLayout();
          } else {
            return HomeScreen();
          }
        }
      },
    );
  }
}
