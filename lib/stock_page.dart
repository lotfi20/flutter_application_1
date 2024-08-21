import 'package:flutter/material.dart';
import 'ProductConfirmationPage.dart';
import 'Service/stock_service.dart';
import 'Service/auth_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StockPage(),
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF1A1A2E),
        primaryColor: Color(0xFF16213E),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.blueAccent),
      ),
    );
  }
}

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  late Future<List<dynamic>> _futureParts;

  final StockService _stockService = StockService();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _futureParts = _stockService.fetchStocks();
  }

  List<Map<String, dynamic>> _filterParts(List<Map<String, dynamic>> parts) {
    return parts; // Filtrage si nécessaire
  }

  void _onProductSelected(String productName, String productId, double productPrice) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductConfirmationPage(
          productName: productName,
          productId: productId,
          productPrice: productPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Load'),
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
                _buildStepButton("Afficher Produits", 0, true),
                _buildStepButton("Confirmer Utilisation", 1, false),
                _buildStepButton("Envoi Confirmation", 2, false),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _futureParts,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No parts available'));
                  } else {
                    final parts = snapshot.data!.cast<Map<String, dynamic>>();
                    final filteredParts = _filterParts(parts);

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredParts.length,
                      itemBuilder: (context, index) {
                        final productName = filteredParts[index]["name"] ?? "Unknown Product";
                        final productId = filteredParts[index]["id"] ?? "Unknown ID";
                        final productPrice = filteredParts[index]["price"] ?? 0.0;

                        return GestureDetector(
                          onTap: () {
                            _onProductSelected(productName, productId, productPrice);
                          },
                          child: Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(
                                color: Colors.grey.shade300,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.network(
                                  filteredParts[index]["image"] ?? '',
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  productName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  filteredParts[index]["description"] ?? '',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
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
