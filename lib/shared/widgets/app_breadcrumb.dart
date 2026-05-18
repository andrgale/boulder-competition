import 'package:flutter/material.dart';

class AppBreadcrumb extends StatelessWidget {
  final String current;

  const AppBreadcrumb({
    super.key,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          const Text('Home'),
          const Text(' / '),
          Text(current),
        ],
      ),
    );
  }
}