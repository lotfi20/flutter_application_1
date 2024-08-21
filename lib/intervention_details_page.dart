import 'package:flutter/material.dart';
import 'service/intervention_service.dart';

class InterventionDetailsPage extends StatefulWidget {
  final String technicianId;
  final Map<String, dynamic> intervention;
  final Function(Map<String, dynamic>) onUpdate;

  InterventionDetailsPage({
    required this.technicianId,
    required this.intervention, // Pass the intervention object here
    required this.onUpdate,
  });

  @override
  _InterventionDetailsPageState createState() => _InterventionDetailsPageState();
}

class _InterventionDetailsPageState extends State<InterventionDetailsPage> {
  late TextEditingController _descriptionController;
  late String _status;
  late Map<String, dynamic> _currentIntervention;
  final InterventionService _interventionService = InterventionService();

  @override
  void initState() {
    super.initState();
    _currentIntervention = widget.intervention;
    _descriptionController = TextEditingController(text: _currentIntervention['description']);
    _status = _currentIntervention['status'];
  }

  void _updateIntervention() async {
    try {
      final updatedIntervention = await _interventionService.updateIntervention(
        _currentIntervention['_id'],
        {
          'description': _descriptionController.text,
          'status': _status,
        },
      );
      widget.onUpdate(updatedIntervention);
      setState(() {
        _currentIntervention = updatedIntervention;
      });
      Navigator.pop(context);
    } catch (e) {
      print('Failed to update intervention: $e');
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Intervention Details'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Description'),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildSectionTitle('Status'),
            _buildStatusDropdown(),
            const SizedBox(height: 32),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        hintText: 'Enter description',
        filled: true,
        fillColor: Colors.teal.shade50,
      ),
      maxLines: 4,
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal),
      ),
      child: DropdownButton<String>(
        value: _status,
        onChanged: (newValue) {
          setState(() {
            _status = newValue!;
          });
        },
        items: ['Pending', 'In Progress', 'Completed']
            .map((status) => DropdownMenuItem<String>(
                  value: status,
                  child: Text(status),
                ))
            .toList(),
        isExpanded: true,
        underline: SizedBox(),
      ),
    );
  }

  Widget _buildUpdateButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _updateIntervention,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text('Update Intervention', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
