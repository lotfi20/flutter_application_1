import 'package:flutter/material.dart';
import 'package:flutter_application_1/AgendaPage.dart';
import 'package:flutter_application_1/login_page.dart'; 
import 'package:flutter_application_1/home_page.dart';
import 'package:flutter_application_1/stock_page.dart'; 
import 'package:flutter_application_1/planning_page.dart'; 
import 'package:flutter_application_1/technicien_home_page.dart'; 
import 'package:flutter_application_1/SupervisorPage.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> define() {
    return {
      '/': (context) => const LoginPage(),
      '/home': (context) => MyHomePage(),
      '/tec': (context) => MyHomePageTechnicien(),
      '/stock': (context) => StockPage(),
      '/planning': (context) => PlanningPage(technicianId: '',),
      '/supervisor': (context) => const SupervisorPage(),
      '/agenda': (context) => AgendaPage(technicianId: '',), 
      // Add other routes here
    };
  }
}
