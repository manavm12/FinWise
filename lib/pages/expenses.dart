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
          id: expense["_id"], 
          description: expense["description"],
          amount: double.parse(expense["amount"].toString()).toStringAsFixed(2),
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

    await ExpenseService.toggleRepeatedExpense(index);

    if (isActive) {
      // Add the repeated expense to today's spending
      final expense = repeatedExpenseData[index];
      final newExpense = ExpenseItem(
        id: "", 
        description: expense["description"],
        amount: double.parse(expense["amount"].toString()).toStringAsFixed(2),
        category: expense["category"],
      );

      setState(() {
        expenseList.add(newExpense);
      });

      await ExpenseService.addExpense(
        expense["description"], 
        expense["category"], 
        double.parse(expense["amount"].toString()) // ✅ Always convert to String before parsing
      );

      _loadExpenses(); // Refresh expenses list
    } else {
      // Remove from today's spending if unchecked
      setState(() {
        expenseList.removeWhere((expense) => expense.description == repeatedExpenseData[index]["description"]);
      });
    }
  }

  // Delete an expense
  void _deleteExpense(String expenseId, int index) async {
    await ExpenseService.deleteExpense(expenseId);
    setState(() {
      expenseList.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Expense deleted"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            // TODO: Implement undo feature
          },
        ),
      ),
    );
  }

  // Delete a repeated expense
  void _deleteRepeatedExpense(int index) async {
    await ExpenseService.deleteRepeatedExpense(index);
    setState(() {
      repeatedExpenseData.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Repeated Expense deleted"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () {
            // TODO: Implement undo feature
          },
        ),
      ),
    );
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
                  return Dismissible(
                    key: Key(expenseList[index].id), 
                    direction: DismissDirection.endToStart, 
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Delete Expense"),
                            content: const Text("Are you sure you want to delete this expense?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      _deleteExpense(expenseList[index].id, index);
                    },
                    child: ExpenseItem(
                      id: expenseList[index].id,
                      description: expenseList[index].description,
                      amount: expenseList[index].amount,
                      category: expenseList[index].category,
                    ),
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
                    return Dismissible(
                      key: Key(repeatedExpenseData[index]["description"]), 
                      direction: DismissDirection.endToStart, 
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Delete Repeated Expense"),
                              content: const Text("Are you sure you want to remove this repeated expense?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) async {
                        _deleteRepeatedExpense(index);
                      },
                      child: RepeatedExpenseItem(
                        description: repeatedExpenseData[index]["description"],
                        amount: double.parse(repeatedExpenseData[index]["amount"].toString()).toStringAsFixed(2),
                        category: repeatedExpenseData[index]["category"],
                        isActive: repeatedExpenseData[index]["isActive"],
                        onToggleActive: (bool isActive) => addExpenseFromRepeated(index, isActive),
                      ),
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
            await ExpenseService.addExpense(result["description"], result["category"], double.parse(result["amount"]));

            if (result["isRepeatedExpense"]) {
              await ExpenseService.addRepeatedExpense(result["description"], result["category"], double.parse(result["amount"]));
              _loadRepeatedExpenses(); // ✅ Ensure repeated expenses refresh after adding one
            }

            _loadExpenses(); // ✅ Refresh expense list after adding one
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
