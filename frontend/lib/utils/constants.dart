import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class AppConstants {
  // Automatically select the right localhost URL based on platform
  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:9000/api';
    } else if (Platform.isAndroid) {
      // Physical device needs the PC's actual local IP address
      return 'http://10.161.104.19:9000/api';
    } else {
      return 'http://localhost:9000/api'; // Windows, macOS, iOS simulator
    }
  }
  
  // Premium Design Theme Colors
  static const Color primaryColor = Color(0xFF2E7D32); // Green accent
  static const Color secondaryColor = Color(0xFF4CAF50); // Lighter green
  static const Color backgroundColor = Color(0xFFFFF8E7); // Light cream
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  
  // Status Colors
  static const Color success = Color(0xFF2E7D32); // Emerald 500 / Green
  static const Color warning = Color(0xFFFF9800); // Warm orange
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color fresh = Color(0xFF3B82F6); // Blue 500

  // Paddings
  static const double defaultPadding = 16.0;
}
