import 'package:flutter/material.dart';

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;

  const Indicator({
    Key? key,
    required this.color,
    required this.text,
    required this.isSquare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 14,
          height: 14,
          color: color,
          // decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
          child: isSquare
              ? null
              : Center(
                  child: Icon(
                    Icons.circle,
                    size: 4,
                    color: Colors.white,
                  ),
                ),
        ),
        const SizedBox(
          width: 14,
        ),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
