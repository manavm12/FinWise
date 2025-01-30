import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:finwise/styles/blueText.dart';

class SetMonthlyBudget extends StatelessWidget {
  const SetMonthlyBudget({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      title: Center(child: BlueText(text: "Set Monthly Budget")),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                hintText: 'Enter Amount',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [ // Ensure only numbers are allowed
                FilteringTextInputFormatter.digitsOnly,
              ],
              onSubmitted: (value) {
                // Pop with the entered value when "Enter" is pressed
                if (value.isNotEmpty) {
                  Navigator.of(context).pop(value);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cancel button
                OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
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
                const SizedBox(width: 8),
                // Enter button
                ElevatedButton(
                  onPressed: () {
                    final input = controller.text;
                    if (input.isNotEmpty) {
                      Navigator.of(context).pop(input);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Enter"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
