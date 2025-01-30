import 'package:flutter/material.dart';
import 'package:finwise/classes/expenseItem.dart';
import 'package:finwise/classes/repeatedExpenseItem.dart';
import 'package:finwise/services/mathServices.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  List<ExpenseItem> expenseList = [
    ExpenseItem(description: "Lunch - Bismillah", amount: "5.00", category: "Food"),
    ExpenseItem(description: "Dinner - Subway", amount: "7.00", category: "Food"),
    ExpenseItem(description: "Ice Cream", amount: "3.00", category: "Food"),
  ];

  List<Map<String, dynamic>> repeatedExpenseData = [];

  @override
  void initState() {
    super.initState();
    repeatedExpenseData = [
      {"description": "Subscription", "amount": "3.00", "category": "Entertainment", "isActive": false},
      {"description": "Milk", "amount": "6.45", "category": "Groceries", "isActive": false},
      {"description": "Gym Membership", "amount": "30.00", "category": "Health", "isActive": false},
    ];
  }

  // Function to add repeated expenses to Today's Spending
  void addExpenseFromRepeated(int index, bool isActive) {
    setState(() {
      repeatedExpenseData[index]["isActive"] = isActive;

      if (isActive) { 
        // Only add if checked
        var expense = repeatedExpenseData[index];
        expenseList.add(
          ExpenseItem(
            description: expense["description"],
            amount: expense["amount"],
            category: expense["category"],
          ),
        );
      }
    });
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              flex: 3,
              child: ListView.builder(
                itemCount: expenseList.length,
                itemBuilder: (context, index) {
                  return expenseList[index];
                },
              ),
            ),
            const Divider(
              thickness: 2,
              color: Colors.blue,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "\$${MathService.calculateTotal(expenseList)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Repeated Expenses",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
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
                      amount: repeatedExpenseData[index]["amount"],
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
        onPressed: () {
          // Add Expense logic placeholder
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
