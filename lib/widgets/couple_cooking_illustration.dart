import 'package:flutter/material.dart';

class CoupleCookingIllustration extends StatelessWidget {
  final double height;

  const CoupleCookingIllustration({
    super.key,
    this.height = 300,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _CoupleCookingPainter(),
        child: Container(),
      ),
    );
  }
}

class _CoupleCookingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Woman (left side)
    // Head
    paint.color = const Color(0xFFFFD4C8); // Skin tone
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.35, size.height * 0.35),
        width: 60,
        height: 70,
      ),
      paint,
    );

    // Hair
    paint.color = const Color(0xFF6B5B5B);
    final hairPath = Path();
    hairPath.moveTo(size.width * 0.35 - 35, size.height * 0.35);
    hairPath.quadraticBezierTo(
      size.width * 0.35 - 40,
      size.height * 0.3,
      size.width * 0.35 - 25,
      size.height * 0.25,
    );
    hairPath.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.28,
      size.width * 0.35 + 25,
      size.height * 0.25,
    );
    hairPath.quadraticBezierTo(
      size.width * 0.35 + 40,
      size.height * 0.3,
      size.width * 0.35 + 35,
      size.height * 0.35,
    );
    hairPath.quadraticBezierTo(
      size.width * 0.35 + 30,
      size.height * 0.45,
      size.width * 0.35 + 20,
      size.height * 0.55,
    );
    hairPath.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.5,
      size.width * 0.35 - 20,
      size.height * 0.55,
    );
    hairPath.quadraticBezierTo(
      size.width * 0.35 - 30,
      size.height * 0.45,
      size.width * 0.35 - 35,
      size.height * 0.35,
    );
    canvas.drawPath(hairPath, paint);

    // Woman's eyes
    paint.color = Colors.black;
    canvas.drawCircle(
      Offset(size.width * 0.35 - 10, size.height * 0.35),
      2,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.35 + 10, size.height * 0.35),
      2,
      paint,
    );

    // Woman's smile
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    final smilePath1 = Path();
    smilePath1.moveTo(size.width * 0.35 - 10, size.height * 0.35 + 10);
    smilePath1.quadraticBezierTo(
      size.width * 0.35,
      size.height * 0.35 + 15,
      size.width * 0.35 + 10,
      size.height * 0.35 + 10,
    );
    canvas.drawPath(smilePath1, paint);

    // Woman's body (pink apron)
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFFFFB3BA); // Light pink
    final womanBody = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.35, size.height * 0.6),
        width: 80,
        height: 100,
      ),
      const Radius.circular(20),
    );
    canvas.drawRRect(womanBody, paint);

    // Man (right side)
    // Head
    paint.color = const Color(0xFFFFD4C8); // Skin tone
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.65, size.height * 0.32),
        width: 65,
        height: 75,
      ),
      paint,
    );

    // Hair (short)
    paint.color = const Color(0xFF5D4E4E);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.65, size.height * 0.28),
        width: 70,
        height: 45,
      ),
      paint,
    );

    // Man's eyes
    paint.color = Colors.black;
    canvas.drawCircle(
      Offset(size.width * 0.65 - 12, size.height * 0.32),
      2,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.65 + 12, size.height * 0.32),
      2,
      paint,
    );

    // Man's smile
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    final smilePath2 = Path();
    smilePath2.moveTo(size.width * 0.65 - 12, size.height * 0.32 + 10);
    smilePath2.quadraticBezierTo(
      size.width * 0.65,
      size.height * 0.32 + 15,
      size.width * 0.65 + 12,
      size.height * 0.32 + 10,
    );
    canvas.drawPath(smilePath2, paint);

    // Man's body (gray/blue shirt)
    paint.style = PaintingStyle.fill;
    paint.color = const Color(0xFFB8D4E3); // Light blue
    final manBody = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.65, size.height * 0.58),
        width: 85,
        height: 105,
      ),
      const Radius.circular(20),
    );
    canvas.drawRRect(manBody, paint);

    // Bowl/cooking pot between them
    paint.color = const Color(0xFFFFE5CC);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.7),
        width: 60,
        height: 30,
      ),
      paint,
    );

    // Heart above
    paint.color = const Color(0xFFFF8DA1).withOpacity(0.6);
    final heartPath = Path();
    final heartCenter = Offset(size.width * 0.5, size.height * 0.15);
    heartPath.moveTo(heartCenter.dx, heartCenter.dy + 15);
    heartPath.cubicTo(
      heartCenter.dx - 15,
      heartCenter.dy - 5,
      heartCenter.dx - 25,
      heartCenter.dy + 5,
      heartCenter.dx,
      heartCenter.dy + 20,
    );
    heartPath.cubicTo(
      heartCenter.dx + 25,
      heartCenter.dy + 5,
      heartCenter.dx + 15,
      heartCenter.dy - 5,
      heartCenter.dx,
      heartCenter.dy + 15,
    );
    canvas.drawPath(heartPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
