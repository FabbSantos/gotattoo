import 'package:flutter/material.dart';

class AvailabilityInfo extends StatelessWidget {
  final int stock;

  const AvailabilityInfo({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Disponível:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        Text(
          '$stock unidades',
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
      ],
    );
  }
}
