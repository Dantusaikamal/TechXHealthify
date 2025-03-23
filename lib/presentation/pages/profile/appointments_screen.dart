import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Appointments")),
      body: const Center(child: Text("Upcoming and past appointments.")),
    );
  }
}
