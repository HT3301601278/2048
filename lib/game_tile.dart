import 'package:flutter/material.dart';

class GameTile extends StatelessWidget {
  final int value;

  GameTile({required this.value});

  Color _getTileColor(int value) {
    switch (value) {
      case 2:
        return Colors.grey[300]!;
      case 4:
        return Colors.grey[400]!;
      case 8:
        return Colors.orange[300]!;
      case 16:
        return Colors.orange[400]!;
      case 32:
        return Colors.orange[500]!;
      case 64:
        return Colors.redAccent;
      case 128:
        return Colors.purpleAccent;
      case 256:
        return Colors.purple;
      case 512:
        return Colors.blueAccent;
      case 1024:
        return Colors.blue;
      case 2048:
        return Colors.green;
      default:
        return Colors.grey[500]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _getTileColor(value),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text(
          value == 0 ? '' : '$value',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: value <= 4 ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}