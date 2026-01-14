import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homepage.dart';

class CheckoutPage extends StatefulWidget {
  final int totalPrice;
  final List cartItems;

  const CheckoutPage({
    super.key,
    required this.totalPrice,
    required this.cartItems,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool isLoading = true;
  bool isWebViewLoading = true;
  String? snapToken;
  String? orderId;
  String? errorMessage;
  double progress = 0;

  final String checkoutUrl =
      "https://backend-mobile.mazdick.biz.id/midtrans_checkout.php";

  final String forcePaidUrl =
      "https://backend-mobile.mazdick.biz.id/force_payment_success.php";

  final String midtransSnapUrl =
      "https://app.sandbox.midtrans.com/snap/v2/vtweb/";

  @override
  void initState() {
    super.initState();
    _getSnapToken();
  }

  // =======================
  // GET SNAP TOKEN
  // =======================
  Future<void> _getSnapToken() async {
    try {
      List<Map<String, dynamic>> items = widget.cartItems.map((item) {
        return {
          "id": item['product_id'].toString(),
          "name": item['name'],
          "price": int.tryParse(item['price'].toString()) ?? 0,
          "quantity": int.tryParse(item['quantity'].toString()) ?? 1,
        };
      }).toList();

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("user_id") ?? 0;

      final response = await http.post(
        Uri.parse(checkoutUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": userId,
          "total_price": widget.totalPrice,
          "items": items,
        }),
      );

      final data = jsonDecode(response.body);

      if (data['success'] == true) {
        setState(() {
          snapToken = data['snap_token'];
          orderId = data['order_id'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = data['message'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Terjadi kesalahan: $e';
        isLoading = false;
      });
    }
  }

  // =======================
  // FORCE PAYMENT SUCCESS
  // =======================
  Future<void> _finishPayment() async {
    try {
      final res = await http.post(
        Uri.parse(forcePaidUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "order_id": orderId,
        }),
      );

      final data = jsonDecode(res.body);

      if (data['success'] == true) {
        _showSuccessDialog();
      } else {
        _showPendingDialog();
      }
    } catch (e) {
      _showPendingDialog();
    }
  }

  // =======================
  // DIALOGS
  // =======================
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 26,),
            SizedBox(width: 8),
            Text("Pembayaran Berhasil",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text("Pesanan Anda berhasil diproses.",
            style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
                (route) => false,
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showPendingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.access_time, color: Colors.orange),
            SizedBox(width: 10),
            Text("Menunggu Konfirmasi"),
          ],
        ),
        content: const Text(
            "Pembayaran belum terkonfirmasi, silakan coba lagi."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // =======================
  // UI
  // =======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green.shade400,
        title: const Text('Pembayaran', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (isWebViewLoading && snapToken != null)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            ),
          TextButton(
            onPressed: _finishPayment,
            child: const Text(
              "Selesai",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(child: Text(errorMessage!));
    }

    return Column(
      children: [
        if (progress < 1.0)
          LinearProgressIndicator(value: progress),
        Expanded(
          child: InAppWebView(
            initialUrlRequest: URLRequest(
  url: Uri.parse("$midtransSnapUrl$snapToken"),
),

            onProgressChanged: (_, p) {
              setState(() => progress = p / 100);
            },
            onLoadStart: (_, __) {
              setState(() => isWebViewLoading = true);
            },
            onLoadStop: (_, __) {
              setState(() => isWebViewLoading = false);
            },
          ),
        ),
      ],
    );
  }
}
