import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppLogoMark extends StatelessWidget {
  final double size;
  const AppLogoMark({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TicketStubPainter(),
      ),
    );
  }
}

class _TicketStubPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.width * 0.26),
    );

    final fillPaint = Paint()..color = AppColors.brand;
    canvas.drawRRect(rect, fillPaint);

    final notchPaint = Paint()..color = AppColors.paper;
    final notchRadius = size.width * 0.11;
    canvas.drawCircle(Offset(size.width, size.height * 0.35), notchRadius, notchPaint);
    canvas.drawCircle(Offset(size.width, size.height * 0.65), notchRadius, notchPaint);

    final dashPaint = Paint()
      ..color = AppColors.paper.withOpacity(0.55)
      ..strokeWidth = size.width * 0.03;
    final dashX = size.width * 0.74;
    double y = size.height * 0.18;
    while (y < size.height * 0.82) {
      canvas.drawLine(Offset(dashX, y), Offset(dashX, y + size.height * 0.08), dashPaint);
      y += size.height * 0.16;
    }

    final checkPaint = Paint()
      ..color = AppColors.paper
      ..strokeWidth = size.width * 0.07
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(size.width * 0.16, size.height * 0.52)
      ..lineTo(size.width * 0.30, size.height * 0.66)
      ..lineTo(size.width * 0.52, size.height * 0.36);
    canvas.drawPath(path, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
