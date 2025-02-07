import '../classes/expenseItem.dart';

class MathService {
  static String calculateTotal(List<ExpenseItem> expenseList) {
    double total = expenseList.fold(
      0.0,
      (sum, item) => sum + double.parse(item.amount),
    );
    return total.toStringAsFixed(2); 
  }

  static double calculateRemainingBudget(double monthlyBudget, double totalSpending) {
    return (monthlyBudget - totalSpending).clamp(0, double.infinity); // ✅ Prevent negative values
  }

  static double calculateAverageDailyBudget(double remainingBudget) {
    DateTime now = DateTime.now();
    int totalDays = DateTime(now.year, now.month + 1, 0).day; // Days in the month
    int remainingDays = totalDays - now.day; // Days left in month

    if (remainingDays <= 0) return remainingBudget; // ✅ Avoid division by zero

    return remainingBudget / remainingDays;
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