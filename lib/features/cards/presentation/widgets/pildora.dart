import 'package:flutter/material.dart';

class Pildora extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final Color borderColor;

  const Pildora({
    Key? key,
    required this.text,
    required this.color,
    required this.textColor,
    this.borderColor = Colors.black,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(66, 179, 179, 179),
            blurRadius: 0,
            offset: const Offset(3, 4),
          ),
        ],
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 15)),
    );
  }
}
