import 'package:finwise/services/mathServices.dart';
import 'package:finwise/widgets/statisticsRow.dart';
import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  final double monthlyBudget;
  final double totalSpendingThisMonth;
  final double remainingBudget;
  final double avgDailyBudget;
  final double lowestSpending;
  final double highestSpending;


  const StatisticsPage({
    required this.monthlyBudget,
    required this.totalSpendingThisMonth,
    required this.remainingBudget,
    required this.avgDailyBudget,
    required this.lowestSpending,
    required this.highestSpending,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistics"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "This Month",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            buildStatisticRow("Monthly Budget", "\$${monthlyBudget.toStringAsFixed(2)}"),
            buildStatisticRow("Total Spending", "\$${totalSpendingThisMonth.toStringAsFixed(2)}"),
            buildStatisticRow("Remaining Budget", "\$${remainingBudget.toStringAsFixed(2)}"),
            buildStatisticRow("Mean Spend", "\$${MathService().calculateMeanSpend(totalSpendingThisMonth).toStringAsFixed(2)}"),
            buildStatisticRow("Lowest Spend", "\$${lowestSpending.toStringAsFixed(2)}"),
            buildStatisticRow("Highest Spend", "\$${highestSpending.toStringAsFixed(2)}"),
            buildStatisticRow("Daily Budget", "\$${avgDailyBudget.toStringAsFixed(2)}"),
            const SizedBox(height: 16),
            const Text(
              "Monthly Chart",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    "Chart Placeholder",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/home');
          if (index == 1) Navigator.pushReplacementNamed(context, '/expenses');
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: "Expense",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Statistics",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
