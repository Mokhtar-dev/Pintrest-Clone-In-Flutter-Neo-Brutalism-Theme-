import 'package:flutter/material.dart';

class NeoBrutalistCard extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final double offset;

  const NeoBrutalistCard({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
    this.offset = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        // Thick solid border
        border: Border.all(
          color: Colors.black,
          width: 3.0,
        ),
        // Sharp, hard shadow (no blur radius!)
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(offset, offset),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: child,
      ),
    );
  }
}