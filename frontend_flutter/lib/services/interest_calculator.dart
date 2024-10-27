import 'dart:math';
import 'package:flutter/foundation.dart';


class InterestCalculator extends ChangeNotifier {
  // Method to calculate simple interest
  double calculateSimpleInterest(double principal, double rate, int duration) {
    return double.parse((principal * rate * duration / 100).toStringAsFixed(2));
  }

  // Method to calculate compound interest
  double calculateCompoundInterest(
      double principal, double rate, int duration, int compoundingFrequency) {
    return double.parse((principal *
                pow((1 + rate / (100 * compoundingFrequency)),
                    compoundingFrequency * duration) -
            principal)
        .toStringAsFixed(2));
  }

  // Method to calculate balance by month
  List<double> calculateBalanceByMonth(
      double principal, double rate, int duration, int compoundingFrequency,
      {bool compound = false}) {
    List<double> balanceByMonth = [];
    double monthlyRate = rate / 100 / 12;
    int totalMonths = duration * 12;

    for (int month = 1; month <= totalMonths; month++) {
      double balance;
      if (compound) {
        balance = principal * pow((1 + monthlyRate), month);
      } else {
        balance = principal + (principal * monthlyRate * month);
      }
      balanceByMonth.add(double.parse(balance.toStringAsFixed(2)));
    }

    return balanceByMonth;
  }
}
