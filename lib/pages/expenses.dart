import 'package:flutter/material.dart';
import 'package:finwise/services/expense_service.dart';
import 'package:finwise/widgets/addExpenseDialog.dart';
import 'package:finwise/classes/expenseItem.dart';
import 'package:finwise/classes/repeatedExpenseItem.dart';
import 'package:finwise/services/mathServices.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  List<ExpenseItem> expenseList = [];
  List<Map<String, dynamic>> repeatedExpenseData = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses(); // Fetch normal expenses
    _loadRepeatedExpenses(); // Fetch repeated expenses
  }

  // Fetch expenses from the backend
  void _loadExpenses() async {
    final fetchedExpenses = await ExpenseService.fetchExpenses();
    setState(() {
      expenseList = fetchedExpenses.map((expense) {
        return ExpenseItem(
          description: expense["description"],
          amount: expense["amount"].toStringAsFixed(2),
          category: expense["category"],
        );
      }).toList();
    });
  }

  // Fetch repeated expenses from the backend
  void _loadRepeatedExpenses() async {
    final fetchedRepeatedExpenses = await ExpenseService.fetchRepeatedExpenses();
    setState(() {
      repeatedExpenseData = fetchedRepeatedExpenses;
    });
  }

  // Toggle a repeated expense's active state
  void addExpenseFromRepeated(int index, bool isActive) async {
    setState(() {
      repeatedExpenseData[index]["isActive"] = isActive;
    });

    // Update the backend
    await ExpenseService.toggleRepeatedExpense(index);

    if (isActive) {
      // Add the repeated expense to today's spending list
      setState(() {
        expenseList.add(
          ExpenseItem(
            description: repeatedExpenseData[index]["description"],
            amount: repeatedExpenseData[index]["amount"].toString(),
            category: repeatedExpenseData[index]["category"],
          ),
        );
      });
    } else {
      // Remove from today's spending if unchecked
      setState(() {
        expenseList.removeWhere(
          (expense) => expense.description == repeatedExpenseData[index]["description"]
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Expenses"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Spending",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 3,
              child: ListView.builder(
                itemCount: expenseList.length,
                itemBuilder: (context, index) {
                  return ExpenseItem(
                    description: expenseList[index].description,
                    amount: double.parse(expenseList[index].amount).toStringAsFixed(2), // ✅ 2dp fix
                    category: expenseList[index].category,
                  );
                },
              ),
            ),
            const Divider(thickness: 2, color: Colors.blue),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Text(
                  "\$${MathService.calculateTotal(expenseList)}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Repeated Expenses",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80.0),
                child: ListView.builder(
                  itemCount: repeatedExpenseData.length,
                  itemBuilder: (context, index) {
                    return RepeatedExpenseItem(
                      description: repeatedExpenseData[index]["description"],
                      amount: double.parse(repeatedExpenseData[index]["amount"].toString()).toStringAsFixed(2),
                      category: repeatedExpenseData[index]["category"],
                      isActive: repeatedExpenseData[index]["isActive"],
                      onToggleActive: (bool isActive) => addExpenseFromRepeated(index, isActive),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (context) => AddExpense(),
          );

          if (result != null) {
            final String roundedAmount = double.parse(result["amount"]).toStringAsFixed(2);

            // Send expense to backend
            final newExpense = await ExpenseService.addExpense(
              result["description"],
              result["category"],
              double.parse(result["amount"]),
            );

            if (newExpense != null) {
              setState(() {
                expenseList.add(
                  ExpenseItem(
                    description: result["description"],
                    amount: roundedAmount,
                    category: result["category"],
                  ),
                );
              });

              if (result["isRepeatedExpense"]) {
                // Save repeated expense to MongoDB
                await ExpenseService.addRepeatedExpense(
                  result["description"],
                  result["category"],
                  double.parse(result["amount"]),
                );
                
                _loadRepeatedExpenses(); // Refresh UI
              }
            }
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Expense"),
          BottomNavigationBarItem(icon: Icon(Icons.collections), label: "Collections"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
