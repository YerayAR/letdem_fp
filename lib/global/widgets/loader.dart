import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double size;
  final Color color;

  const LoadingIndicator({
    super.key,
    this.size = 9.0,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoActivityIndicator(
      radius: size,
      color: color,
    );
  }
}
