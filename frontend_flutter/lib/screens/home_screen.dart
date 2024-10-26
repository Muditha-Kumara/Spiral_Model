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
  List<double> _simpleInterestByMonth = [];
  List<double> _compoundInterestByMonth = [];
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
        _simpleInterestByMonth = calculator.calculateBalanceByMonth(principal,
            rate, duration, 1); // Calculate simple interest balance by month
        _compoundInterestByMonth = calculator.calculateBalanceByMonth(
            principal, rate, duration, 1,
            compound: true); // Calculate compound interest balance by month
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
              _buildLoanTypeRadioButtons(),
              const SizedBox(height: 16),
              _buildTextField(_principalController, 'Principal',
                  'Please enter the principal amount'),
              const SizedBox(height: 16),
              _buildTextField(_rateController, 'Interest Rate (%)',
                  'Please enter the interest rate',
                  readOnly: true),
              const SizedBox(height: 16),
              _buildTextField(_durationController, 'Duration (years)',
                  'Please enter the duration'),
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
              // const Text('Current outstanding balance:'),
              //Text('\$${_currentOutstandingBalance.toStringAsFixed(2)}'),
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
          });
        },
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String validationMessage,
      {bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      readOnly: readOnly,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly
      ], // Limit input to numbers only
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
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
            ),
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            // tooltipBgColor: Colors.blueGrey,
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
