import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'Service/stock_service.dart';

class StockSupervisorPage extends StatefulWidget {
  const StockSupervisorPage({super.key});

  @override
  _StockSupervisorPageState createState() => _StockSupervisorPageState();
}

class _StockSupervisorPageState extends State<StockSupervisorPage> {
  final StockService _stockService = StockService();
  late Future<List<dynamic>> _futureStocks;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchStocks();
  }

  void _fetchStocks() {
    setState(() {
      _futureStocks = _stockService.fetchStocks();
    });
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<Map<String, dynamic>> _filterStocks(List<Map<String, dynamic>> stocks) {
    if (_searchQuery.isEmpty) {
      return stocks;
    }
    return stocks.where((stock) {
      return stock['name'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _addStock() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController quantityController = TextEditingController();
    final TextEditingController priceController = TextEditingController();

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add New Stock',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildTextField(controller: nameController, labelText: 'Stock Name', icon: Icons.inventory),
            _buildTextField(controller: descriptionController, labelText: 'Stock Description', icon: Icons.description),
            _buildTextField(controller: quantityController, labelText: 'Stock Quantity', icon: Icons.confirmation_number, keyboardType: TextInputType.number),
            _buildTextField(controller: priceController, labelText: 'Stock Price', icon: Icons.price_change, keyboardType: TextInputType.number),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _stockService.createStock({
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'quantity': int.parse(quantityController.text),
                    'price': double.parse(priceController.text),
                    'image': 'assets/oil.png',
                  });
                  Navigator.of(context).pop();
                  _fetchStocks();
                  _showSuccessSnackBar('Stock added successfully');
                } catch (e) {
                  _showErrorDialog('Error adding stock', e.toString());
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Add Stock'),
            ),
          ],
        ),
      ),
    );
  }

  void _editStock(Map<String, dynamic> stock) {
    final TextEditingController nameController = TextEditingController(text: stock['name']);
    final TextEditingController descriptionController = TextEditingController(text: stock['description']);
    final TextEditingController quantityController = TextEditingController(text: stock['quantity'].toString());
    final TextEditingController priceController = TextEditingController(text: stock['price'].toString());

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit Stock',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            _buildTextField(controller: nameController, labelText: 'Stock Name', icon: Icons.inventory),
            _buildTextField(controller: descriptionController, labelText: 'Stock Description', icon: Icons.description),
            _buildTextField(controller: quantityController, labelText: 'Stock Quantity', icon: Icons.confirmation_number, keyboardType: TextInputType.number),
            _buildTextField(controller: priceController, labelText: 'Stock Price', icon: Icons.price_change, keyboardType: TextInputType.number),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final stockId = stock['_id'];
                if (stockId != null) {
                  try {
                    await _stockService.updateStock(stockId, {
                      'name': nameController.text,
                      'description': descriptionController.text,
                      'quantity': int.parse(quantityController.text),
                      'price': double.parse(priceController.text),
                      'image': stock['image'] ?? 'assets/oil.png',
                    });
                    Navigator.of(context).pop();
                    _fetchStocks();
                    _showSuccessSnackBar('Stock updated successfully');
                  } catch (e) {
                    _showErrorDialog('Error updating stock', e.toString());
                  }
                } else {
                  _showErrorDialog('Error', 'Stock ID is null');
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('Update Stock'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteStock(String? stockId) {
    if (stockId == null || stockId.isEmpty) {
      _showErrorDialog('Error', 'Stock ID is null');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Stock'),
          content: Text('Are you sure you want to delete this stock?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _stockService.deleteStock(stockId);
                  Navigator.of(context).pop();
                  _fetchStocks();
                  _showSuccessSnackBar('Stock deleted successfully');
                } catch (e) {
                  _showErrorDialog('Error deleting stock', e.toString());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String labelText, required IconData icon, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        keyboardType: keyboardType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/supervisor');
          },
        ),
        title: Text('Stock Supervisor'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addStock,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _futureStocks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No stocks available'));
                  } else {
                    final stocks = snapshot.data!.cast<Map<String, dynamic>>();
                    final filteredStocks = _filterStocks(stocks);

                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredStocks.length,
                      itemBuilder: (context, index) {
                        final stock = filteredStocks[index];
                        final stockId = stock['_id'];

                        return OpenContainer(
                          transitionType: ContainerTransitionType.fadeThrough,
                          closedBuilder: (context, openContainer) {
                            return GestureDetector(
                              onTap: openContainer,
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Image.asset(
                                            stock['image'] ?? 'assets/oil.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        stock['name'],
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Text('Quantity: ${stock['quantity']}'),
                                      Text('Price: \$${stock['price']}'),
                                      ButtonBar(
                                        alignment: MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () => _editStock(stock),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: Colors.red),
                                            onPressed: () => _deleteStock(stockId),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                          openBuilder: (context, closeContainer) => Scaffold(
                            appBar: AppBar(
                              leading: IconButton(
                                icon: Icon(Icons.arrow_back), // Back button icon for the edit page
                                onPressed: () {
                                  Navigator.pushReplacementNamed(context, '/supervisor'); // Navigate back to the supervisor page
                                },
                              ),
                              title: Text('Edit Stock Details'),
                            ),
                            body: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ListView(
                                children: [
                                  _buildTextField(controller: TextEditingController(text: stock['name']), labelText: 'Stock Name', icon: Icons.inventory),
                                  _buildTextField(controller: TextEditingController(text: stock['description']), labelText: 'Stock Description', icon: Icons.description),
                                  _buildTextField(controller: TextEditingController(text: stock['quantity'].toString()), labelText: 'Stock Quantity', icon: Icons.confirmation_number, keyboardType: TextInputType.number),
                                  _buildTextField(controller: TextEditingController(text: stock['price'].toString()), labelText: 'Stock Price', icon: Icons.price_change, keyboardType: TextInputType.number),
                                ],
                              ),
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

  Widget _buildSearchBar() {
    return TextField(
      onChanged: _onSearch,
      decoration: InputDecoration(
        hintText: 'Search stocks...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
