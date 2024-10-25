import 'dart:math';

class InterestCalculator {
  double calculateSimpleInterest(double principal, double rate, int time) {
    return (principal * rate * time) / 100;
  }

  double calculateCompoundInterest(
      double principal, double rate, int time, int n) {
    return principal * pow((1 + rate / (n * 100)), n * time) - principal;
  }

  List<double> calculateBalanceByMonth(
      double principal, double rate, int time, int n) {
    List<double> balances = [];
    double monthlyRate = rate / (n * 12 * 100);
    int totalMonths = time * 12;

    for (int month = 1; month <= totalMonths; month++) {
      double balance = principal * pow((1 + monthlyRate), month);
      balances.add(balance);
    }

    return balances;
  }
}
