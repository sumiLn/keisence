import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShogiPieceButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const ShogiPieceButton({super.key, required this.text, required this.onTap});

  @override
  State<ShogiPieceButton> createState() => _ShogiPieceButtonState();
}

class _ShogiPieceButtonState extends State<ShogiPieceButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => pressed = true),
      onTapUp: (_) => setState(() => pressed = false),
      onTapCancel: () => setState(() => pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 80),
        child: CustomPaint(
          painter: ShogiButtonPainter(),
          child: SizedBox(
            width: 310,
            height: 142,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  widget.text,
                  style: GoogleFonts.notoSerifJp(color: Colors.black, fontSize: 34, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SmallPieceButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const SmallPieceButton({super.key, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(scale: 0.78, child: ShogiPieceButton(text: text, onTap: onTap));
  }
}

class ShogiButtonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = shogiPiecePath(size);
    canvas.drawShadow(path, Colors.black.withOpacity(0.55), 8, false);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF0C36A), Color(0xFFE0A84D), Color(0xFFBA7827)],
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, paint);
    canvas.drawPath(path, Paint()..color = const Color(0xFF3D240D)..style = PaintingStyle.stroke..strokeWidth = 3.2);
    canvas.drawPath(path.shift(const Offset(0, 1)), Paint()..color = const Color(0xFFFFE2A1).withOpacity(0.26)..style = PaintingStyle.stroke..strokeWidth = 1.2);
  }

  Path shogiPiecePath(Size s) {
    final w = s.width;
    final h = s.height;
    return Path()
      ..moveTo(w * 0.5, h * 0.02)
      ..lineTo(w * 0.80, h * 0.22)
      ..quadraticBezierTo(w * 0.83, h * 0.58, w * 0.84, h * 0.95)
      ..lineTo(w * 0.16, h * 0.95)
      ..quadraticBezierTo(w * 0.17, h * 0.58, w * 0.20, h * 0.22)
      ..close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
