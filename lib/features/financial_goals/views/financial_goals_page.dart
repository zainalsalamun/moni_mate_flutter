import 'package:flutter/material.dart';
import 'goals_section.dart';

class FinancialGoalsPage extends StatelessWidget {
  const FinancialGoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Goals',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: GoalsSection(),
        ),
      ),
    );
  }
}
