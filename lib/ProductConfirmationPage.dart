import 'package:flutter/material.dart';
import 'SuccessPage.dart';

class ProductConfirmationPage extends StatelessWidget {
  final String productName;
  final String productId;
  final double productPrice;

  ProductConfirmationPage({required this.productName, required this.productId, required this.productPrice});

  void _confirmUsage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Usage'),
        backgroundColor: Color(0xFF3366FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStepButton("Afficher Produits", 0, false),
                _buildStepButton("Confirmer Utilisation", 1, true),
                _buildStepButton("Envoi Confirmation", 2, false),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "Produit sélectionné : $productName",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "Prix : $productPrice",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "Veuillez confirmer l'utilisation du produit.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF3366FF),
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                ),
                onPressed: () => _confirmUsage(context),
                child: Text('Confirmer Utilisation'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepButton(String title, int index, bool isActive) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? Colors.blue : Colors.grey.shade400,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.grey.shade700,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
