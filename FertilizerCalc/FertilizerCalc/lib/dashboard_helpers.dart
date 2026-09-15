import 'package:flutter/material.dart';

class DashboardHelpers {
  static int getStatusN(int n) {
    if (n < 30) return 0;
    if (n <= 60) return 2;
    return 1;
  }

  static int getStatusP(int p) {
    if (p < 18) return 0;
    if (p <= 40) return 2;
    return 1;
  }

  static int getStatusK(int k) {
    if (k < 40) return 0;
    if (k <= 75) return 2;
    return 1;
  }

  static int getStatusPh(double ph) {
    if (ph < 5.5) return 0;
    if (ph <= 7.0) return 2;
    return 1;
  }

  static String getStatusName(int code, String type) {
    if (type == 'ph') {
      switch (code) {
        case 0: return 'Acidic';
        case 1: return 'Alkaline';
        case 2: return 'Neutral';
        default: return 'Unknown';
      }
    } else {
      switch (code) {
        case 0: return 'Deficient';
        case 1: return 'Excess';
        case 2: return 'Optimal';
        default: return 'Unknown';
      }
    }
  }

  static Color getStatusColor(int code, String type) {
    switch (code) {
      case 0: return Colors.orange;
      case 1: return Colors.red;
      case 2: return Colors.green;
      default: return Colors.grey;
    }
  }
}
