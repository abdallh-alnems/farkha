import 'package:flutter/material.dart';

Widget buildSection(String title, Widget content) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        content,
      ],
    ),
  );
}

Widget buildList(List<String> items) {
  return Column(
    children:
        items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text("• $item", style: const TextStyle(fontSize: 16)),
              ),
            )
            .toList(),
  );
}

Widget buildCriteriaList(Map<String, List<String>> criteria) {
  return Column(
    children:
        criteria.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text(
                "${entry.key} : ( ${entry.value.join(" , ")} )",
                style: const TextStyle(fontSize: 16),
              ),
            ),
          );
        }).toList(),
  );
}
