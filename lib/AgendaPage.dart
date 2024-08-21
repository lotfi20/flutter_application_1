import 'package:flutter/material.dart';
import 'service/technician_service.dart'; // Import your TechnicianService
import 'intervention_details_page.dart'; // Import InterventionDetailsPage

class AgendaPage extends StatefulWidget {
  final String technicianId; // Pass the technicianId from the login

  AgendaPage({required this.technicianId});

  @override
  _AgendaPageState createState() => _AgendaPageState();
}

class _AgendaPageState extends State<AgendaPage> {
  final TechnicianService _technicianService = TechnicianService();
  List<dynamic> _interventions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInterventions();
  }

  void _fetchInterventions() async {
    try {
      final interventions = await _technicianService.fetchInterventionsForTechnician(widget.technicianId); // Use the technician ID
      setState(() {
        _interventions = interventions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Failed to load interventions: $e');
    }
  }

  void _updateInterventionInList(Map<String, dynamic> updatedIntervention) {
    setState(() {
      int index = _interventions.indexWhere((intervention) => intervention['_id'] == updatedIntervention['_id']);
      if (index != -1) {
        _interventions[index] = updatedIntervention;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Agenda'),
        backgroundColor: Colors.blueGrey,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _interventions.isEmpty
              ? Center(child: Text('Aucune intervention trouvée.'))
              : ListView.builder(
                  itemCount: _interventions.length,
                  itemBuilder: (context, index) {
                    final intervention = _interventions[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(
                          intervention['description'] ?? 'Aucune description',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Date: ${intervention['startDate'] != null ? DateTime.parse(intervention['startDate']).toLocal().toString() : 'Non spécifiée'}',
                        ),
                        trailing: Text(
                          'Statut: ${intervention['status'] ?? 'Inconnu'}',
                          style: TextStyle(
                            color: _getStatusColor(intervention['status']),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          // Navigate to the InterventionDetailsPage with the onUpdate callback and pass the intervention
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InterventionDetailsPage(
                                technicianId: widget.technicianId, // Pass the technicianId here
                                onUpdate: _updateInterventionInList, // Pass the required onUpdate callback
                                intervention: intervention, // Pass the selected intervention
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
