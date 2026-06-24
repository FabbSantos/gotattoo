import 'package:flutter/material.dart';

/// Small "Dono" badge identifying the app owner.
class OwnerTag extends StatelessWidget {
  const OwnerTag({super.key});

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFB8860B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium, size: 11, color: gold),
          SizedBox(width: 3),
          Text(
            'Dono',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: gold,
            ),
          ),
        ],
      ),
    );
  }
}
