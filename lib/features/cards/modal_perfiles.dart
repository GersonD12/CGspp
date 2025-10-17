import 'package:flutter/material.dart';

class CustomModal extends StatelessWidget {
  final double? width;
  final double? height;
  final String text;
  final Color? color;
  final Widget? content;

  const CustomModal({
    Key? key,
    this.width,
    this.height,
    required this.text,
    this.color,
    this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: color ?? Colors.white,
      child: SizedBox(
        width: width ?? MediaQuery.of(context).size.width * 0.8,
        height: height ?? MediaQuery.of(context).size.height * 0.6,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (content != null) ...[
                const SizedBox(height: 16),
                Expanded(child: content!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
