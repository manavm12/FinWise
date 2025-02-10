import 'package:flutter/material.dart';
import 'package:finwise/services/expense_service.dart';
import 'package:finwise/widgets/addExpenseDialog.dart';
import 'package:finwise/classes/expenseItem.dart';
import 'package:finwise/classes/repeatedExpenseItem.dart';
import 'package:finwise/services/mathServices.dart';
import 'package:intl/intl.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  List<ExpenseItem> expenseList = [];
  List<Map<String, dynamic>> repeatedExpenseData = [];
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadExpenses(); // Fetch normal expenses
    _loadRepeatedExpenses(); // Fetch repeated expenses
  }

  String get formattedDate => DateFormat('d MMMM').format(selectedDate);


  // Fetch expenses from the backend
  void _loadExpenses() async {
  final fetchedExpenses = await ExpenseService.fetchExpenses(dateFilter: selectedDate);
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

  void _previousDay() {
    setState(() {
      selectedDate = selectedDate.subtract(const Duration(days: 1));
    });
    _loadExpenses();
  }

  void _nextDay() {
    if (selectedDate.isBefore(DateTime.now())) {
      setState(() {
        selectedDate = selectedDate.add(const Duration(days: 1));
      });
      _loadExpenses();
    }
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000), // Set a reasonable past limit
      lastDate: DateTime.now(),  // Prevent selection of future dates
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
      _loadExpenses();
    }
  }

  // Toggle a repeated expense's active state
  void addExpenseFromRepeated(int index, bool isActive) async {
  try {
    await ExpenseService.toggleRepeatedExpense(index);

    setState(() {
      repeatedExpenseData[index]["isActive"] = isActive;
    });

    if (isActive) {
      final expense = repeatedExpenseData[index];

      // Ensure amount is safely converted to double
      double amount = (expense["amount"] is int)
          ? expense["amount"].toDouble() // Convert int to double
          : double.parse(expense["amount"].toString()); // Parse String safely

      // ✅ Send expense to the database instead of manually adding to the list
      await ExpenseService.addExpense(expense["description"], expense["category"], amount);
    }

    // ✅ Refresh the expenses list after any toggle to prevent duplicates
    _loadExpenses();

  } catch (e) {
    print("Error toggling repeated expense: $e");
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_left, size: 30),
                  onPressed: _previousDay,
                ),
                GestureDetector(
                  onTap: _selectDate,
                  child: Row(
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.calendar_today, size: 20, color: Colors.blue),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_right, size: 30),
                  onPressed: _nextDay,
                ),
              ],
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
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/chatbot');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Expense"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "ChatBot"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
