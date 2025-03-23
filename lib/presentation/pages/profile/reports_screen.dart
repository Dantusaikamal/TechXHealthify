import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Progress Reports")),
      body: const Center(child: Text("Track your health progress over time.")),
    );
  }
}
