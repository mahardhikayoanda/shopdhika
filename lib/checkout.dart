import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'payment_page.dart';
import 'payment_success_page.dart';

class Checkout {
  static const String baseUrl = "http://192.168.18.6/server_shopdhika";

  static Future<Map<String, dynamic>> createTransaction() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId == null) {
      return {"success": false, "message": "Silahkan login terlebih dahulu"};
    }

    print("DEBUG: checkout user_id: $userId"); // Custom Debug

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/checkout.php"),
        body: {
          "user_id": userId,
          "action": "checkout" // Ensure backend knows it's a checkout
        },
      );
      
      print("DEBUG: checkout response: ${response.statusCode} - ${response.body}"); // Custom Debug

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {"success": false, "message": "Error: $e"};
    }
  }

  static Future<void> clearCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('user_id');

    if (userId == null) return;

    try {
      await http.post(
        Uri.parse("$baseUrl/cart.php"),
        body: {
          "user_id": userId,
          "action": "clear"
        },
      );
    } catch (e) {
      debugPrint("Error clearing cart: $e");
    }
  }

  static Future<void> checkout(BuildContext context,
      {VoidCallback? onSuccess}) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Create transaction on backend
    final result = await createTransaction();

    // Hide loading dialog
    Navigator.of(context).pop();

    if (result['success'] == true) {
      final redirectUrl = result['redirect_url'];

      if (redirectUrl != null) {
        // Navigate to PaymentPage (WebView)
        // ignore: use_build_context_synchronously
        final paymentResult = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PaymentPage(paymentUrl: redirectUrl),
          ),
        );

        // Handle payment result
        if (paymentResult == true) {
          // Payment was successful
          await clearCart(); // Clear the cart now

          if (onSuccess != null) {
            onSuccess();
          }

          // Navigate to Success Page
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const PaymentSuccessPage(),
            ),
          );
        } else {
          // Payment failed or cancelled
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Pembayaran dibatalkan atau gagal"),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? "Checkout gagal"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
