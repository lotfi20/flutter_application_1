import 'package:flutter/material.dart';
import 'package:flutter_application_1/AgendaPage.dart';
import 'package:flutter_application_1/login_page.dart'; 
import 'package:flutter_application_1/home_page.dart';
import 'package:flutter_application_1/planning_page.dart'; 
import 'package:flutter_application_1/technicien_home_page.dart'; 
import 'package:flutter_application_1/SupervisorPage.dart';
import 'package:flutter_application_1/statisticspage.dart' as stats;
import 'package:flutter_application_1/stock_page.dart' as stock;
import 'package:flutter_application_1/StockSupervisorPage.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> define() {
    return {
      '/': (context) => const LoginPage(),
      '/home': (context) => MyHomePage(),
      '/tec': (context) => MyHomePageTechnicien(),
      '/stock': (context) => stock.StockPage(),  // Use alias here
      '/planning': (context) => PlanningPage(technicianId: '',),
      '/supervisor': (context) => const SupervisorPage(),
      '/agenda': (context) => AgendaPage(technicianId: '',), 
      '/statistics': (context) => stats.StatisticsPage(parts: []), 
      '/stocksuperviseur': (context) => const StockSupervisorPage(), // Use alias here
      // Add other routes here
    };
  }
}