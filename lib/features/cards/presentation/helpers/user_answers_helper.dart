import 'package:flutter/material.dart';

List<Widget> buildUserAnswers(Map<String, dynamic> userData) {
  if (userData.containsKey('answers') && userData['answers'] is Map) {
    final answers = userData['answers'] as Map<String, dynamic>;
    if (answers.isEmpty) {
      return [const Text('No answers provided.')];
    }
    return answers.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text('${entry.key}: ${entry.value}'),
      );
    }).toList();
  } else {
    return [const Text('No answers data found.')];
  }
}
