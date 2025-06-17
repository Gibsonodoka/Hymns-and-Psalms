import 'package:flutter/material.dart';

class ProScreen extends StatelessWidget {
  const ProScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PRO')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enjoy full access for free!', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Text('PRO features coming soon.'),
          ],
        ),
      ),
    );
  }
}