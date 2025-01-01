import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class InvestmentLoanScreen extends StatefulWidget {
  @override
  _InvestmentLoanScreenState createState() => _InvestmentLoanScreenState();
}

class _InvestmentLoanScreenState extends State<InvestmentLoanScreen> {
  double _balance = 0;
  double _originalBalance = 0;  // Store the original balance
  int _clickCounter = 0; // Counter to track the number of button presses

  @override
  void initState() {
    super.initState();
    _fetchUserBalance();
  }

  // Fetch the user's balance
  Future<void> _fetchUserBalance() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      setState(() {
        _balance = doc['balance'];
        _originalBalance = _balance;  // Set the original balance
      });
    }
  }

  double _investmentAmount = 0;
  double _investmentRate = 0;

  double _loanAmount = 0;
  double _loanRate = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Black background
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.add_chart_sharp, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Investment & Loans',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black, // Dark AppBar
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              width: double.infinity, // This will make the container take up full width
              height: 150, // You can adjust the height as needed
              color: Colors.grey[300], // Background color for the container (optional)
              child: Center(
                child: Text(
                  "Area for Ad placements",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(
                    "Current Balance: \$${_balance.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // Displaying the counter next to the updated balance
                  Text(
                    "Effect of Rate in $_clickCounter years",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align buttons in a row
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            double investmentEffect = _investmentAmount * (_investmentRate / 100);
                            double loanEffect = _loanAmount * (_loanRate / 100);
                            _balance += investmentEffect - loanEffect;
                            _clickCounter++;  // Increment the counter
                          });
                        },
                        child: const Text("Show Effect"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            _balance = _originalBalance;  // Reset to the original balance
                            _clickCounter = 0;  // Reset the counter
                          });
                        },
                        child: const Text("Reset to Original Balance"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Investment Section
            _buildInputSection(
              title: "Investments",
              amount: _investmentAmount,
              rate: _investmentRate,
              onAmountChanged: (value) {
                setState(() {
                  _investmentAmount = double.tryParse(value) ?? 0;
                });
              },
              onRateChanged: (value) {
                setState(() {
                  _investmentRate = double.tryParse(value) ?? 0;
                });
              },
              chart: _buildChart(_investmentAmount, _investmentRate, isInvestment: true),
            ),

            const Divider(height: 20, thickness: 2, color: Colors.purple),

            // Loan Section
            _buildInputSection(
              title: "Loans",
              amount: _loanAmount,
              rate: _loanRate,
              onAmountChanged: (value) {
                setState(() {
                  _loanAmount = double.tryParse(value) ?? 0;
                });
              },
              onRateChanged: (value) {
                setState(() {
                  _loanRate = double.tryParse(value) ?? 0;
                });
              },
              chart: _buildChart(_loanAmount, _loanRate, isInvestment: false),
            ),

            const Divider(height: 20, thickness: 2, color: Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection({
    required String title,
    required double amount,
    required double rate,
    required Function(String) onAmountChanged,
    required Function(String) onRateChanged,
    required Widget chart,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Amount (\$)",
                    labelStyle: TextStyle(color: Colors.purpleAccent),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purpleAccent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  onChanged: onAmountChanged,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Rate (%)",
                    labelStyle: TextStyle(color: Colors.purpleAccent),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purpleAccent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple),
                    ),
                  ),
                  style: TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  onChanged: onRateChanged,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: 150,
              width: 250,
              child: Column(
                children: [
                  Text(
                    "Effect of Rate Over a Year",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.purpleAccent,
                    ),
                  ),
                  Expanded(child: chart),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(double amount, double rate, {required bool isInvestment}) {
    List<FlSpot> spots = [];
    for (int month = 0; month <= 12; month++) {
      double monthlyEffect = amount * (1 + (rate / 100) * (month / 12));
      spots.add(FlSpot(month.toDouble(), monthlyEffect));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                if (value % 2 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Text(
                      '${value.toInt()}',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  );
                }
                return Container();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${value.toInt()}',
                  style: TextStyle(fontSize: 10, color: Colors.white),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.white, width: 1),
        ),
        minX: 0,
        maxX: 12, // 12 months
        minY: amount,
        maxY: amount * (1 + (rate / 100)),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: isInvestment ? Colors.greenAccent : Colors.redAccent,
            spots: spots,
            barWidth: 4,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
