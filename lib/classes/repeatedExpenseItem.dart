import 'package:flutter/material.dart';

class RepeatedExpenseItem extends StatelessWidget {
  final String description;
  final String amount;
  final String category;
  final bool isActive;
  final Function(bool) onToggleActive; // Passes true/false on toggle

  const RepeatedExpenseItem({
    required this.description,
    required this.amount,
    required this.category,
    required this.isActive,
    required this.onToggleActive,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    description,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(fontSize: 12, color: Colors.blue[900]),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '\$$amount',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Checkbox(
                value: isActive,
                onChanged: (bool? value) {
                  if (value == true) { 
                    onToggleActive(true); // Only add if checked
                  } else {
                    onToggleActive(false); // Unchecking just updates state
                  }
                },
                activeColor: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
