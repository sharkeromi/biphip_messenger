import 'package:flutter/material.dart';

import '../../../utils/constants/const.dart';

class NormalText extends StatelessWidget {
  final String title;
  final Color color;
  final TextAlign txtAlign;
  final double fontSize;
  final double height;
  final FontWeight weight;
  const NormalText(
    this.title, {
    super.key,
    this.color = Colors.black,
    this.txtAlign = TextAlign.justify,
    this.fontSize = h16,
    this.height = 1.5,
    this.weight = FontWeight.normal,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      // maxLines: 5,
      textAlign: txtAlign,
      title,
      style: TextStyle(fontSize: fontSize, fontWeight: weight, color: color, height: height),
    );
  }
}
