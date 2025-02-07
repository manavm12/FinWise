import 'package:finwise/pages/statistics.dart';
import 'package:finwise/styles/blueText.dart';
import 'package:finwise/widgets/featureButton.dart';
import 'package:finwise/widgets/setMonthlyBudgetDialog.dart';
import 'package:finwise/services/mathServices.dart';
import 'package:flutter/material.dart';
import 'package:finwise/services/expense_service.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String formattedDate;
  double monthlyBudget = 0.0;
  double budgetUsed = 0.0;
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    formattedDate = DateFormat('d MMMM').format(now);
    _loadBudget(); // Fetch budget from backend
  }

  // Fetch budget from API
  void _loadBudget() async {
    final fetchedBudget = await ExpenseService.fetchMonthlyBudget();
    setState(() {
      monthlyBudget = fetchedBudget;
    });
  }

  // Compute Remaining Budget
  double get remainingBudget => MathService.calculateRemainingBudget(monthlyBudget, budgetUsed);

  // Compute Average Daily Budget
  double get avgDailyBudget => MathService.calculateAverageDailyBudget(remainingBudget);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: BlueText(text: "Today: $formattedDate")),
            const SizedBox(height: 20),
            // Top section for Remaining Budget and Average Daily Budget
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Remaining Budget: \$${remainingBudget.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "Avg. Daily Budget: \$${avgDailyBudget.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Graph placeholder
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Text("Graph Placeholder")),
            ),
            const SizedBox(height: 16),
            // Fixed Monthly Budget
            Text(
              'Fixed Monthly Budget: \$${monthlyBudget.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            // Grid of Buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  FeatureButton(Icons.add, "Set Budget", () async {
                    final result = await showDialog(
                      context: context, 
                      builder: (context) {
                        return const SetMonthlyBudget();
                      },
                    );
                    if (result != null && result.isNotEmpty) {
                      setState(() {
                        monthlyBudget = double.tryParse(result) ?? 0.0;
                        ExpenseService.updateMonthlyBudget(monthlyBudget);
                      });
                    }
                  }),
                  FeatureButton(Icons.analytics, "Statistics", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>StatisticsPage(
                      monthlyBudget: monthlyBudget, 
                      remainingBudget: remainingBudget, 
                      avgDailyBudget: avgDailyBudget, 
                      spendingData: [12,13,14,15,16])));
                  }),
                  FeatureButton(Icons.access_time, "History", () {}),
                  FeatureButton(Icons.coffee_outlined, "Add Widgets", () {}),
                  FeatureButton(Icons.money, "Manage Card", () {}),
                  FeatureButton(Icons.pie_chart, "Breakdown", () {}),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          print('Index tapped: $index');
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/expenses');
          }
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
            icon: Icon(Icons.collections),
            label: "Collections",
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
