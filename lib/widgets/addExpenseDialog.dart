import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/expenseCategories.dart';

class AddExpense extends StatelessWidget {
  const AddExpense({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController customCategoryController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    String selectedCategory = ExpenseCategory.categories.first; 
    bool isRepeatedExpense = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Center(
            child: Text(
              "Add Expense",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          content: SizedBox(
            width: 350,
            child: SingleChildScrollView( 
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: "Amount",
                      hintText: "Enter Amount",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')), // Allow up to 2 decimal places
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: ExpenseCategory.categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                        if (selectedCategory != 'Other') {
                          customCategoryController.clear();
                        }
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Category",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Custom Category Field (Visible Only When "Other" is Selected)
                  if (selectedCategory == 'Other')
                    TextField(
                      controller: customCategoryController,
                      decoration: InputDecoration(
                        labelText: "Custom Category",
                        hintText: "Type your category",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.blue, width: 2),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Description Field
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: "Description",
                      hintText: "Type here",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Repeated Expense Checkbox
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Repeated Expense",
                        style: TextStyle(fontSize: 16),
                      ),
                      Checkbox(
                        value: isRepeatedExpense,
                        onChanged: (bool? value) {
                          setState(() {
                            isRepeatedExpense = value ?? false;
                          });
                        },
                        activeColor: Colors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close without saving
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (amountController.text.isNotEmpty &&
                              (selectedCategory != 'Other' || customCategoryController.text.isNotEmpty)) {
                            Navigator.of(context).pop({
                              'amount': amountController.text,
                              'category': selectedCategory == 'Other'
                                  ? customCategoryController.text
                                  : selectedCategory,
                              'description': descriptionController.text,
                              'isRepeatedExpense': isRepeatedExpense,
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Add"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
