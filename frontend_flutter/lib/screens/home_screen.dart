import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart'; // Import the services package
import '../services/interest_calculator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Calculator'),
        backgroundColor: Colors.lightBlue, // AppBar color
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
  String? _loanType; // Set initial value to null
  String _result = '';
  double _currentOutstandingBalance = 0.0;
  List<double> _simpleInterestByMonth = [];
  List<double> _compoundInterestByMonth = [];
  Map<String, double> _interestRates = {};
  String _lastValidPrincipal = ''; // Store the last valid principal value
  String _lastValidDuration = ''; // Store the last valid duration value

  // Define a variable for the width of the radio buttons
  final double radioButtonWidth = 170.0;

  @override
  void initState() {
    super.initState();
    _fetchInterestRates();
    _principalController.addListener(_calculateInterest);
    _rateController.addListener(_calculateInterest);
    _durationController.addListener(_calculateInterest);
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
    if (_formKey.currentState!.validate() && _loanType != null) {
      final principal = double.tryParse(_principalController.text) ?? 0.0;
      final rate = _interestRates[_loanType!] ?? 0.0;
      final duration = int.tryParse(_durationController.text) ?? 0;

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
        _simpleInterestByMonth = calculator.calculateBalanceByMonth(principal,
            rate, duration, 1); // Calculate simple interest balance by month
        _compoundInterestByMonth = calculator.calculateBalanceByMonth(
            principal, rate, duration, 1,
            compound: true); // Calculate compound interest balance by month
      });
    }
  }

  void _resetFields() {
    setState(() {
      _principalController.clear();
      _rateController.clear();
      _durationController.clear();
      _loanType = null;
      _result = '';
      _currentOutstandingBalance = 0.0;
      _simpleInterestByMonth = [];
      _compoundInterestByMonth = [];
      _lastValidPrincipal = '';
      _lastValidDuration = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode:
              AutovalidateMode.disabled, // Disable real-time validation
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Loan Type:',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.lightBlue)),
              _buildLoanTypeRadioButtons(),
              const SizedBox(height: 16),
              _buildTextFieldWithInstruction(
                  _principalController,
                  'Principal',
                  'Please enter the principal amount',
                  'Enter a value between 1 and 10000',
                  min: 1,
                  max: 10000,
                  lastValidValue: _lastValidPrincipal),
              const SizedBox(height: 16),
              _buildTextFieldWithInstruction(
                  _rateController,
                  'Interest Rate (%)',
                  'Please enter the interest rate',
                  'This field is read-only. Select a loan type to change the rate',
                  readOnly: true,
                  lastValidValue: ''), // No validation needed
              const SizedBox(height: 16),
              _buildTextFieldWithInstruction(
                  _durationController,
                  'Duration (years)',
                  'Please enter the duration',
                  'Enter a years between 1 and 5',
                  min: 1,
                  max: 5,
                  lastValidValue: _lastValidDuration),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _resetFields,
                  child: const Text('Reset'),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    backgroundColor:
                        MaterialStateProperty.all(Colors.lightBlue),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    textStyle: MaterialStateProperty.all(
                      const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _result,
                style: const TextStyle(fontSize: 16, color: Colors.lightBlue),
              ),
              // const Text('Current outstanding balance:'),
              // Text('\$${_currentOutstandingBalance.toStringAsFixed(2)}'),
              const SizedBox(height: 20),
              Container(
                height: 200,
                child: _buildBarChart(),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Month',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoanTypeRadioButtons() {
    return Wrap(
      spacing: 8.0, // Space between items
      runSpacing: 4.0, // Space between lines
      children: [
        _buildRadioButton('Personal'),
        _buildRadioButton('Auto'),
        _buildRadioButton('Mortgage'),
        _buildRadioButton('Student'),
        _buildRadioButton('Business'),
      ],
    );
  }

  Widget _buildRadioButton(String loanType) {
    return SizedBox(
      width: radioButtonWidth,
      child: RadioListTile<String>(
        title: Text(
            '$loanType (${_interestRates[loanType]?.toStringAsFixed(1) ?? '...'}%)'),
        value: loanType,
        groupValue: _loanType,
        onChanged: (String? value) {
          setState(() {
            _loanType = value!;
            _rateController.text =
                _interestRates[_loanType]?.toStringAsFixed(1) ?? '';
            _calculateInterest(); // Trigger calculation when loan type changes
          });
        },
      ),
    );
  }

  Widget _buildTextFieldWithInstruction(TextEditingController controller,
      String label, String validationMessage, String instruction,
      {bool readOnly = false,
      double? min,
      double? max,
      required String lastValidValue}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            labelStyle: const TextStyle(color: Colors.lightBlue),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.lightBlue),
            ),
          ),
          keyboardType: TextInputType.number,
          readOnly: readOnly,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly
          ], // Limit input to numbers only
          onChanged: (value) {
            final doubleValue = double.tryParse(value);
            if (doubleValue != null) {
              if ((min != null && doubleValue < min) ||
                  (max != null && doubleValue > max)) {
                setState(() {
                  controller.text =
                      lastValidValue; // Revert to the last valid value
                  controller.selection = TextSelection.fromPosition(
                      TextPosition(
                          offset: controller
                              .text.length)); // Move cursor to the end
                });
              } else {
                if (controller == _principalController) {
                  _lastValidPrincipal = value;
                } else if (controller == _durationController) {
                  _lastValidDuration = value;
                }
              }
            }
          },
        ),
        const SizedBox(height: 4),
        Text(
          instruction,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        barGroups: List.generate(_simpleInterestByMonth.length, (index) {
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: _simpleInterestByMonth[index],
                color: Colors.blue,
                width: 8,
              ),
              BarChartRodData(
                toY: _compoundInterestByMonth[index],
                color: Colors.red,
                width: 8,
              ),
            ],
            barsSpace: 4,
          );
        }),
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
                  child: Text(value.toStringAsFixed(1), style: style),
                );
              },
              reservedSize: 60, // Increase reserved size to prevent wrapping
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
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
                  child: Text(value.toInt().toString(),
                      style: style), // Remove decimal values
                );
              },
              reservedSize: 40,
              interval: 1, // Show every label
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            // tooltipBackgroundColor: Colors.blueGrey,
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              String interestType = rodIndex == 0 ? 'Simple' : 'Compound';
              return BarTooltipItem(
                '$interestType Interest\n${rod.toY.toStringAsFixed(2)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
