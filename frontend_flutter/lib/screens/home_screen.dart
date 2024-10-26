import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../services/interest_calculator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Calculator'),
      ),
      body: const LoanForm(),
    );
  }
}

class LoanForm extends StatefulWidget {
  const LoanForm({super.key});

  @override
  _LoanFormState createState() => _LoanFormState();
}

class _LoanFormState extends State<LoanForm> {
  final _formKey = GlobalKey<FormState>();
  final _principalController = TextEditingController();
  final _rateController = TextEditingController();
  final _durationController = TextEditingController();
  String _loanType = 'Personal';
  String _result = '';
  double _currentOutstandingBalance = 0.0;
  List<double> _balanceByMonth = [];

  // Define a variable for the width of the radio buttons
  final double radioButtonWidth = 170.0;

  void _calculateInterest() {
    if (_formKey.currentState!.validate()) {
      final principal = double.parse(_principalController.text);
      final rate = double.parse(_rateController.text);
      final duration = int.parse(_durationController.text);

      final calculator =
          Provider.of<InterestCalculator>(context, listen: false);
      final simpleInterest =
          calculator.calculateSimpleInterest(principal, rate, duration);
      final compoundInterest = calculator.calculateCompoundInterest(
          principal, rate, duration, 1); // yearly compounding

      setState(() {
        _result = 'Simple Interest: \$${simpleInterest.toStringAsFixed(2)}\n'
            'Compound Interest: \$${compoundInterest.toStringAsFixed(2)}';
        _currentOutstandingBalance =
            principal + compoundInterest; // Example calculation
        _balanceByMonth = calculator.calculateBalanceByMonth(
            principal, rate, duration, 1); // Calculate balance by month
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Loan Type:', style: TextStyle(fontSize: 16)),
              Wrap(
                spacing: 8.0, // Space between items
                runSpacing: 4.0, // Space between lines
                children: [
                  SizedBox(
                    width: radioButtonWidth,
                    child: RadioListTile<String>(
                      title: const Text('Personal'),
                      value: 'Personal',
                      groupValue: _loanType,
                      onChanged: (String? value) {
                        setState(() {
                          _loanType = value!;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: radioButtonWidth,
                    child: RadioListTile<String>(
                      title: const Text('Auto'),
                      value: 'Auto',
                      groupValue: _loanType,
                      onChanged: (String? value) {
                        setState(() {
                          _loanType = value!;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: radioButtonWidth,
                    child: RadioListTile<String>(
                      title: const Text('Mortgage'),
                      value: 'Mortgage',
                      groupValue: _loanType,
                      onChanged: (String? value) {
                        setState(() {
                          _loanType = value!;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: radioButtonWidth,
                    child: RadioListTile<String>(
                      title: const Text('Student'),
                      value: 'Student',
                      groupValue: _loanType,
                      onChanged: (String? value) {
                        setState(() {
                          _loanType = value!;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: radioButtonWidth,
                    child: RadioListTile<String>(
                      title: const Text('Business'),
                      value: 'Business',
                      groupValue: _loanType,
                      onChanged: (String? value) {
                        setState(() {
                          _loanType = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _principalController,
                decoration: const InputDecoration(
                  labelText: 'Principal',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the principal amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rateController,
                decoration: const InputDecoration(
                  labelText: 'Interest Rate (%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the interest rate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (years)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the duration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _calculateInterest,
                  child: const Text('Calculate'),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _result,
                style: const TextStyle(fontSize: 16),
              ),
              const Text('Current outstanding balance:'),
              Text('\$${_currentOutstandingBalance.toStringAsFixed(2)}'),
              Container(
                height: 200,
                child: BarChart(
                  BarChartData(
                    barGroups: _balanceByMonth
                        .asMap()
                        .entries
                        .map((entry) => BarChartGroupData(
                              x: entry.key,
                              barRods: [
                                BarChartRodData(
                                  toY: entry.value,
                                  color: Colors.blue,
                                ),
                              ],
                            ))
                        .toList(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const style = TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            );
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 4,
                              child: Text(value.toString(), style: style),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const style = TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            );
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 4,
                              child: Text(value.toString(), style: style),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
