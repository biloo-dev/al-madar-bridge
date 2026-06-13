import 'package:flutter/material.dart';

class BuildCard extends StatelessWidget {
  const BuildCard({super.key, required this.children, this.padding});

  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white10,

        // border: Border(bottom: BorderSide(color: Colors.blueGrey)),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            // blurRadius: 25,
            // offset: const Offset(0, 10),
            color: Colors.black.withOpacity(.09),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
