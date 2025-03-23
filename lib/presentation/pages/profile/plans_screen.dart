import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PlansScreen extends StatelessWidget {
  const PlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Plans")),
      body: const Center(child: Text("Your active subscriptions or plans.")),
    );
  }
}
