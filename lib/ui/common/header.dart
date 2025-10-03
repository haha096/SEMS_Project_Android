import 'package:flutter/material.dart';
import '../../src/constants.dart';

class SemsHeader extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry margin;
  final double radius;
  final double verticalPadding;

  const SemsHeader({
    super.key,
    this.title = "SEMS 시스템 관리자",
    this.margin = const EdgeInsets.fromLTRB(16, 12, 16, 12),
    this.radius = 22,
    this.verticalPadding = 28,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        margin: margin,
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(radius),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}