class Loan {
  final String type;
  final double principal;
  final double interestRate;
  final int duration; // in years

  Loan({
    required this.type,
    required this.principal,
    required this.interestRate,
    required this.duration,
  });
}
