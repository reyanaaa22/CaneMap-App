import 'package:flutter/material.dart';

class DotsIndicator extends StatelessWidget {
  final int count;
  final int index;
  const DotsIndicator({super.key, required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 10 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.white70,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}


