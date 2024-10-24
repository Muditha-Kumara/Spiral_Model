import 'dart:math';

class InterestCalculator {
  double calculateSimpleInterest(double principal, double rate, int time) {
    return (principal * rate * time) / 100;
  }

  double calculateCompoundInterest(
      double principal, double rate, int time, int n) {
    return principal * pow((1 + rate / (n * 100)), n * time) - principal;
  }
}
