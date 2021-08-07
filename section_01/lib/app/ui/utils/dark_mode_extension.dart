

import 'package:flutter/material.dart';

extension DarkModeExtension on BuildContext {
  bool get isDarkMode {
    return Theme.of(this).brightness == Brightness.dark;
  }
}
