import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:async';
import 'package:intl/intl.dart'; // Import the intl package
import 'service/intervention_service.dart';
import 'intervention_details_page.dart'; // Import the details page

class PlanningPage extends StatefulWidget {
  final String technicianId; // Add this parameter to identify the technician

  PlanningPage({required this.technicianId}); // Constructor to pass the technician ID

  @override
  _PlanningPageState createState() => _PlanningPageState();
}

class _PlanningPageState extends State<PlanningPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late Timer _timer;
  String _currentTime = '';
  List<dynamic> _interventions = [];

  final InterventionService _interventionService = InterventionService();

  @override
  void initState() {
    super.initState();
    _currentTime = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    _fetchInterventions();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _fetchInterventions() async {
    try {
      final interventions = await _interventionService.fetchInterventionsByTechnician(widget.technicianId);

      setState(() {
        _interventions = interventions;
      });
    } catch (e) {
      print('Failed to load interventions: $e');
    }
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    setState(() {
      _currentTime = formattedDateTime;
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd – kk:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planning des interventions'),
      ),
      body: Column(
        children: <Widget>[
          _buildClock(),
          _buildCalendar(),
          Expanded(
            child: Center(
              child: AnimatedOpacity(
                opacity: _selectedDay != null ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: _selectedDay != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Interventions for ${_selectedDay!.toLocal()}',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          _buildInterventions(),
                        ],
                      )
                    : Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClock() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        _currentTime,
        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueGrey),
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2020, 10, 16),
      lastDay: DateTime.utc(2030, 3, 14),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
      calendarStyle: CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: Colors.greenAccent,
          shape: BoxShape.circle,
        ),
        markersMaxCount: 1,
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
      ),
    );
  }

  Widget _buildInterventions() {
    final interventionsForSelectedDay = _interventions.where((intervention) {
      final startDate = DateTime.parse(intervention['startDate']);
      return isSameDay(startDate, _selectedDay);
    }).toList();

    return Column(
      children: interventionsForSelectedDay
          .map(
            (intervention) => ListTile(
              leading: Icon(Icons.build, color: Colors.blueAccent),
              title: Text(intervention['description']),
              subtitle: Text(
                  'Start: ${_formatDate(DateTime.parse(intervention['startDate']))}\nEnd: ${_formatDate(DateTime.parse(intervention['endDate']))}\nStatus: ${intervention['status']}'),
              trailing: Icon(Icons.chevron_right),
              onTap: () async {
                final updatedIntervention = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InterventionDetailsPage(
                      technicianId: intervention['technicianId'], // Pass the technicianId here
                      intervention: intervention, // Pass the intervention object
                      onUpdate: (updatedIntervention) {
                        setState(() {
                          final index = _interventions.indexWhere((i) => i['_id'] == updatedIntervention['_id']);
                          if (index != -1) {
                            _interventions[index] = updatedIntervention;
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          )
          .toList(),
    );
  }
}
