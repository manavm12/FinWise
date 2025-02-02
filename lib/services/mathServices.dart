import '../classes/expenseItem.dart';

class MathService {
  static String calculateTotal(List<ExpenseItem> expenseList) {
    double total = expenseList.fold(
      0.0,
      (sum, item) => sum + double.parse(item.amount),
    );
    return total.toStringAsFixed(2); 
  }

  static double calculateRemainingBudget(double monthlyBudget, double budgetUsed) {
    return (monthlyBudget - budgetUsed).clamp(0, double.infinity); // Ensures no negative values
  }

  /// Calculates the average daily budget based on the remaining budget and days left in the month.
  static double calculateAverageDailyBudget(double remainingBudget) {
    DateTime now = DateTime.now();
    int daysLeft = DateTime(now.year, now.month + 1, 0).day - now.day; // Days left in the current month

    if (daysLeft <= 0) return remainingBudget; // Avoid division by zero

    return remainingBudget / daysLeft;
  }

    double calculateMean(List<double> data) {
    if (data.isEmpty) return 0.0;
    return data.reduce((a, b) => a + b) / data.length;
  }

  double calculateLowest(List<double> data) {
    if (data.isEmpty) return 0.0;
    return data.reduce((a, b) => a < b ? a : b);
  }

  double calculateHighest(List<double> data) {
    if (data.isEmpty) return 0.0;
    return data.reduce((a, b) => a > b ? a : b);
  }
  
}