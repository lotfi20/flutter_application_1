import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Service/auth_service.dart'; // Mettez à jour avec le chemin réel de votre service

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  bool _isFormVisible = false;
  String _selectedRole = 'Technician';

  final AuthService _authService = AuthService(); // Créez une instance d'AuthService

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _isFormVisible = true;
      });
    });
  }

  Future<void> saveTechnicianId(String technicianId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('technicianId', technicianId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.lightBlueAccent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Hero(
                    tag: 'profile-pic',
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRoleSelector(),
                  const SizedBox(height: 16),
                  AnimatedOpacity(
                    opacity: _isFormVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 1000),
                    child: _buildForm(),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _showPasswordRecoveryDialog,
                    child: const Text(
                      'Forgot Email / Phone?',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    return ToggleButtons(
      borderRadius: BorderRadius.circular(20),
      isSelected: [_selectedRole == 'Technician', _selectedRole == 'Client', _selectedRole == 'Supervisor'],
      onPressed: (index) {
        setState(() {
          if (index == 0) _selectedRole = 'Technician';
          if (index == 1) _selectedRole = 'Client';
          if (index == 2) _selectedRole = 'Supervisor';
        });
      },
      children: const [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Technician'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Client'),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Supervisor'),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          _buildInputField(emailController, hint: 'Email', icon: Icons.email),
          const SizedBox(height: 16),
          _buildInputField(phoneController, hint: 'Phone', icon: Icons.phone),
          const SizedBox(height: 24),
          _buildLoginButton(),
        ],
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller,
      {required String hint, required IconData icon}) {
    return Container(
      width: 300,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: ElevatedButton(
        onPressed: () async {
          try {
            Map<String, dynamic> response;
            if (_selectedRole == 'Technician') {
              response = await _authService.loginTechnician(emailController.text, phoneController.text);
              debugPrint('Token: ${response['token']}');
              debugPrint('Technician: ${response['technician']}');
              
              // Save technician ID to shared preferences
              await saveTechnicianId(response['technician']['_id']);
              
              // Navigate to the home page with the technician data
              Navigator.pushReplacementNamed(
                context,
                '/tec',
                arguments: response['technician'],
              );
            } else if (_selectedRole == 'Client') {
              response = await _authService.loginClient(emailController.text, phoneController.text);
              debugPrint('Token: ${response['token']}');
              debugPrint('Client: ${response['client']}');
              
              // Navigate to the client home page with the client data
              Navigator.pushReplacementNamed(
                context,
                '/home',
                arguments: response['client'],
              );
            } else if (_selectedRole == 'Supervisor') {
              response = await _authService.loginSupervisor(emailController.text, phoneController.text);
              debugPrint('Token: ${response['token']}');
              debugPrint('Supervisor: ${response['supervisor']}');
              
              // Navigate to the supervisor home page with the supervisor data
              Navigator.pushReplacementNamed(
                context,
                '/supervisor',
                arguments: response['supervisor'],
              );
            }
          } catch (e) {
            debugPrint('Error: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Login failed: $e')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          backgroundColor: Colors.black87,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 80),
        ),
        child: const Text(
          "Login",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _showPasswordRecoveryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController recoveryEmailController = TextEditingController();
        TextEditingController recoveryPhoneController = TextEditingController();
        return AlertDialog(
          title: const Text('Recover Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your email and phone number to recover your details.'),
              const SizedBox(height: 8.0),
              TextField(
                controller: recoveryEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8.0),
              TextField(
                controller: recoveryPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Recovery details sent to ${recoveryEmailController.text} and ${recoveryPhoneController.text}')),
                );
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
