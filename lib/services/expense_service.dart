import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_services.dart';
import 'package:intl/intl.dart';

class ExpenseService {
  static const String baseUrl = "http://10.0.2.2:3000/api/expenses";
  static const String userBaseUrl = "http://10.0.2.2:3000/api/users";
  static const String chatBaseurl = "http://10.0.2.2:3000/api/ai";

  // Fetch all expenses for the logged-in user
  static Future<List<Map<String, dynamic>>> fetchExpenses({DateTime? dateFilter}) async {
  try {
    final headers = await AuthService.getAuthHeaders();
    
    // Format the date correctly for the backend
    String url = dateFilter != null
        ? "$baseUrl/by-date/${DateFormat('yyyy-MM-dd').format(dateFilter)}" // ✅ Ensures matching format
        : "$baseUrl/";

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception("Failed to fetch expenses");
    }
  } catch (error) {
    print("Error fetching expenses: $error");
    return [];
  }
}



  // Add a new expense
  static Future<Map<String, dynamic>?> addExpense(String description, String category, double amount) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/add"),
        headers: headers,
        body: jsonEncode({
          "description": description,
          "category": category,
          "amount": amount,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print("Error adding expense: ${response.body}");
        return null;
      }
    } catch (error) {
      print("Error: $error");
      return null;
    }
  }

  // Fetch repeated expenses for the logged-in user
  static Future<List<Map<String, dynamic>>> fetchRepeatedExpenses() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse("$userBaseUrl/repeated-expenses"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception("Failed to fetch repeated expenses");
      }
    } catch (error) {
      print("Error fetching repeated expenses: $error");
      return [];
    }
  }

  // Add a new repeated expense
  static Future<void> addRepeatedExpense(String description, String category, double amount) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      await http.post(
        Uri.parse("$userBaseUrl/add-repeated-expense"),
        headers: headers,
        body: jsonEncode({
          "description": description,
          "category": category,
          "amount": amount,
        }),
      );
    } catch (error) {
      print("Error adding repeated expense: $error");
    }
  }

  // Toggle repeated expense activation (Mark it as used today)
  static Future<void> toggleRepeatedExpense(int index) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.put(
        Uri.parse("$userBaseUrl/toggle-repeated-expense/$index"),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to toggle repeated expense");
      }
    } catch (error) {
      print("Error toggling repeated expense: $error");
    }
  }

  // Fetch Monthly Budget
  static Future<double> fetchMonthlyBudget() async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.get(
        Uri.parse("http://10.0.2.2:3000/api/users/budget"), 
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["monthlyBudget"].toDouble(); // Ensure it's double
      } else {
        throw Exception("Failed to fetch monthly budget");
      }
    } catch (error) {
      print("Error fetching monthly budget: $error");
      return 0.0; // Default if error occurs
    }
  }

  // Update Monthly Budget
  static Future<void> updateMonthlyBudget(double monthlyBudget) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.put(
        Uri.parse("http://10.0.2.2:3000/api/users/update-budget"),
        headers: headers,
        body: jsonEncode({"monthlyBudget": monthlyBudget}),
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to update monthly budget");
      }
    } catch (error) {
      print("Error updating monthly budget: $error");
    }
  }

    static Future<void> deleteExpense(String expenseId) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.delete(
        Uri.parse("http://10.0.2.2:3000/api/expenses/delete/$expenseId"),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to delete expense");
      }
    } catch (error) {
      print("Error deleting expense: $error");
    }
  }

  // Delete a repeated expense
  static Future<void> deleteRepeatedExpense(int index) async {
    try {
      final headers = await AuthService.getAuthHeaders();
      final response = await http.delete(
        Uri.parse("http://10.0.2.2:3000/api/users/delete-repeated-expense/$index"),
        headers: headers,
      );

      if (response.statusCode != 200) {
        throw Exception("Failed to delete repeated expense");
      }
    } catch (error) {
      print("Error deleting repeated expense: $error");
    }
  }

// Fetch Monthly Spending 
    static Future<Map<String, double>> fetchMonthlySpending() async {
      try {
        final headers = await AuthService.getAuthHeaders();
        final response = await http.get(Uri.parse("$baseUrl/monthly-spending"), headers: headers);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return {
            "totalSpendingThisMonth": (data["totalSpendingThisMonth"] as num).toDouble(),
            "lowestSpending": (data["lowestSpending"] as num).toDouble(),
            "highestSpending": (data["highestSpending"] as num).toDouble(),
          };
        } else {
          throw Exception("Failed to fetch monthly spending");
        }
      } catch (error) {
        print("Error fetching monthly spending: $error");
        return {
          "totalSpendingThisMonth": 0.0,
          "lowestSpending": 0.0,
          "highestSpending": 0.0,
        };
      }
    }

    static Future<String> sendAIQuery(String userMessage) async {
      try {
        final headers = await AuthService.getAuthHeaders();
        headers['Content-Type'] = 'application/json'; // Ensure Content-Type is set

        // Send POST request to backend
        final response = await http.post(
          Uri.parse("$chatBaseurl/analyze-spending"),
          headers: headers,
          body: jsonEncode({"query": userMessage}), // Ensure proper JSON encoding
        );

        // Log the response for debugging
        print("Response Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");

        // Handle the response
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          return responseData["response"] ?? "I couldn't analyze your spending."; // ✅ Corrected key to 'response'
        } else {
          print("Error: ${response.body}");
          return "I encountered an error while analyzing your spending.";
        }
      } catch (error) {
        print("Error in sendAIQuery: $error");
        return "I encountered an error while analyzing your spending.";
      }
    }




}
