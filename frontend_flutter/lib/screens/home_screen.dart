import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  Map<String, double> _interestRates = {};

  // Define a variable for the width of the radio buttons
  final double radioButtonWidth = 170.0;

  @override
  void initState() {
    super.initState();
    _fetchInterestRates();
  }

  Future<void> _fetchInterestRates() async {
    try {
      final response = await http.get(Uri.parse(
          'https://gxdjvk1avb.execute-api.us-east-1.amazonaws.com/devInterst'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, dynamic> interestRates = json.decode(data['body']);
        print('API Response: $interestRates'); // Debugging line
        setState(() {
          _interestRates = interestRates.map((key, value) => MapEntry(
              key,
              (value is num)
                  ? value.toDouble()
                  : double.tryParse(value.toString()) ?? 0.0));
          _rateController.text =
              _interestRates[_loanType]?.toStringAsFixed(1) ?? '';
        });
        print('Fetched interest rates: $_interestRates'); // Debugging line
      } else {
        // Handle error
        print('Failed to load interest rates: ${response.statusCode}');
      }
    } catch (e) {
      // Handle error
      print('Error fetching interest rates: $e');
    }
  }

  void _calculateInterest() {
    if (_formKey.currentState!.validate()) {
      final principal = double.parse(_principalController.text);
      final rate = _interestRates[_loanType] ?? 0.0;
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
                      title: Text(
                          'Personal (${_interestRates['Personal']?.toStringAsFixed(1) ?? '...'}%)'),
                      value: 'Personal',
                      groupValue: _loanType,
                      onChanged: (String? value) {
                        setState(() {
                          _loanType = value!;
                          _rateController.text =
                              _interestRates[_loanType]?.toStringAsFixed(1) ??
                                  '';
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: radioButtonWidth,
                    child: RadioListTile<String>(
                      title: Text(
                          'Auto (${_interestRates['Auto']?.toStringAsFixed(1) ?? '...'}%)'),
                      value: 'Auto',
                      groupValue: _loanType,
                      onChanged: (String? value) {
                        setState(() {
                          _loanType = value!;
                          _rateController.text =
                              _interestRates[_loanType]?.toStringAsFixed(1) ??
                                  '';
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: radioButtonWidth,
                    child: RadioListTile<String>(
                      title: Text(
                          'Mortgage (${_interestRates['Mortgage']?.toStringAsFixed(1) ?? '...'}%)'),
                      value: 'Mortgage',
                      groupValue: _loanType,
                      onChanged: (String? value) {
                        setState(() {
                          _loanType = value!;
                          _rateController.text =
                              _interestRates[_loanType]?.toStringAsFixed(1) ??
                                  '';
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: radioButtonWidth,
                    child: RadioListTile<String>(
                      title: Text(
                          'Student (${_interestRates['Student']?.toStringAsFixed(1) ?? '...'}%)'),
                      value: 'Student',
                      groupValue: _loanType,
                      onChanged: (String? value) {
                        setState(() {
                          _loanType = value!;
                          _rateController.text =
                              _interestRates[_loanType]?.toStringAsFixed(1) ??
                                  '';
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: radioButtonWidth,
                    child: RadioListTile<String>(
                      title: Text(
                          'Business (${_interestRates['Business']?.toStringAsFixed(1) ?? '...'}%)'),
                      value: 'Business',
                      groupValue: _loanType,
                      onChanged: (String? value) {
                        setState(() {
                          _loanType = value!;
                          _rateController.text =
                              _interestRates[_loanType]?.toStringAsFixed(1) ??
                                  '';
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
                readOnly: true, // Disable direct input
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
              //const SizedBox(height: 20),
              Text(
                _result,
                style: const TextStyle(fontSize: 16),
              ),
              const Text('Current outstanding balance:'),
              Text('\$${_currentOutstandingBalance.toStringAsFixed(2)}'),
              const SizedBox(height: 20),
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
                          showTitles: false,
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
                          showTitles: false,
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
