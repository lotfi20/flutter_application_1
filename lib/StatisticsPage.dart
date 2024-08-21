import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'Service/stock_service.dart';

class StatisticsPage extends StatelessWidget {
  final List<Map<String, dynamic>> parts;
  final List<Color> _colors = [
    Colors.blueAccent,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
  ];

  StatisticsPage({required this.parts});

  List<PieChartSectionData> _createSampleData(List<Map<String, dynamic>> parts) {
    return List.generate(parts.length, (index) {
      final part = parts[index];
      final color = _colors[index % _colors.length];
      return PieChartSectionData(
        color: color,
        value: part['quantity'].toDouble(),
        title: part['name'] ?? '',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  List<BarChartGroupData> _createBarChartData(List<Map<String, dynamic>> parts) {
    return List.generate(parts.length, (index) {
      final part = parts[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            y: part['quantity'].toDouble(),
            colors: [_colors[index % _colors.length]],
          )
        ],
      );
    });
  }

  List<FlSpot> _createLineChartData(List<Map<String, dynamic>> parts) {
    return List.generate(parts.length, (index) {
      final part = parts[index];
      return FlSpot(index.toDouble(), part['quantity'].toDouble());
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredParts = parts.where((part) {
      return part['quantity'] > 0;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    sections: _createSampleData(filteredParts),
                    sectionsSpace: 0,
                    centerSpaceRadius: 40,
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
             
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: _createLineChartData(filteredParts),
                        isCurved: true,
                        colors: [Colors.blueAccent],
                        barWidth: 4,
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      bottomTitles: SideTitles(
                        showTitles: true,
                        getTextStyles: (value) => const TextStyle(color: Colors.white, fontSize: 10),
                        getTitles: (value) {
                          return filteredParts[value.toInt()]['name'] ?? '';
                        },
                      ),
                      leftTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SideBar extends StatelessWidget {
  final String? technicianName;
  final List<Map<String, dynamic>> parts;

  SideBar({this.technicianName, required this.parts});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.production_quantity_limits),
            title: Text('Products'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('Statistics'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StatisticsPage(parts: parts),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.inbox),
            title: Text('Inbox'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Notifications'),
            onTap: () {},
          ),
          Spacer(),
          ListTile(
            leading: CircleAvatar(),
            title: Text(technicianName ?? 'Technician'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> with TickerProviderStateMixin {
  final List<Color> _colors = [
    Colors.blueAccent,
    Colors.redAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
  ];

  String _sortCriteria = 'name';
  String _searchQuery = '';
  late Future<List<dynamic>> _futureParts;
  String? _technicianName;

  final StockService _stockService = StockService();


  @override
  void initState() {
    super.initState();
    _futureParts = _stockService.fetchStocks();

  }

  

  void _sortParts(String criteria, List<Map<String, dynamic>> parts) {
    setState(() {
      _sortCriteria = criteria;
      parts.sort((a, b) {
        if (criteria == 'name') {
          return a['name'].compareTo(b['name']);
        } else if (criteria == 'quantity') {
          return b['quantity'].compareTo(a['quantity']);
        } else if (criteria == 'price') {
          return b['price'].compareTo(a['price']);
        }
        return 0;
      });
    });
  }

  List<Map<String, dynamic>> _filterParts(List<Map<String, dynamic>> parts) {
    if (_searchQuery.isEmpty) {
      return parts;
    }
    return parts.where((part) {
      return part['name'].toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  List<PieChartSectionData> _createSampleData(List<Map<String, dynamic>> parts) {
    return List.generate(parts.length, (index) {
      final part = parts[index];
      final color = _colors[index % _colors.length];
      return PieChartSectionData(
        color: color,
        value: part['quantity'].toDouble(),
        title: part['name'] ?? '',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: FutureBuilder<List<dynamic>>(
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
            return SideBar(technicianName: _technicianName, parts: parts);
          }
        },
      ),
      appBar: AppBar(
        title: Text('Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {},
              child: Text('Add Product'),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SearchBar(
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<dynamic>>(
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

                  return Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              sections: _createSampleData(filteredParts),
                              sectionsSpace: 0,
                              centerSpaceRadius: 40,
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ProductTable(parts: filteredParts),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
  
  ProductTable({required List<Map<String, dynamic>> parts}) {}
}
