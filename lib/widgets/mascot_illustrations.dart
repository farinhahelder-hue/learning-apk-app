import 'package:flutter/material.dart';

/// Petits accessoires vectoriels placés derrière le cercle de chaque
/// mascotte pour la distinguer visuellement au-delà du simple emoji.
/// Formes simples (cercles/ellipses), pas de dessin complexe — l'emoji
/// reste l'élément principal affiché par [MascotWidget].
class MascotAccessories extends StatelessWidget {
  final String mascotId;
  final double size;
  final Color color;

  const MascotAccessories({
    super.key,
    required this.mascotId,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    switch (mascotId) {
      case 'papa_seal':
      case 'baby_seal':
        return _flippers();
      case 'monika_jellyfish':
        return _tentacles();
      case 'night_squirrel':
        return _tail();
      case 'ainy_crab':
        return _pincers();
      case 'barbenoire_cat':
        return _ears();
      case 'ninon_dolphin':
        return _fin();
      case 'billy_bird':
        return _wings();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _shape(double w, double h, {double opacity = 0.55}) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: color.withOpacity(opacity),
          borderRadius: BorderRadius.circular(h / 2),
        ),
      );

  Widget _flippers() => SizedBox(
        width: size * 1.35,
        height: size * 1.1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              bottom: size * 0.12,
              child: Transform.rotate(angle: -0.5, child: _shape(size * 0.3, size * 0.15)),
            ),
            Positioned(
              right: 0,
              bottom: size * 0.12,
              child: Transform.rotate(angle: 0.5, child: _shape(size * 0.3, size * 0.15)),
            ),
          ],
        ),
      );

  Widget _tentacles() => SizedBox(
        width: size * 1.1,
        height: size * 1.5,
        child: CustomPaint(
          painter: _TentaclesPainter(color: color.withOpacity(0.45)),
        ),
      );

  Widget _tail() => SizedBox(
        width: size * 1.4,
        height: size * 1.4,
        child: Stack(
          children: [
            Positioned(
              right: 0,
              top: 0,
              child: Transform.rotate(
                angle: 0.6,
                child: _shape(size * 0.4, size * 0.75, opacity: 0.4),
              ),
            ),
          ],
        ),
      );

  Widget _pincers() => SizedBox(
        width: size * 1.4,
        height: size * 1.1,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              top: size * 0.05,
              child: _shape(size * 0.26, size * 0.26, opacity: 0.55),
            ),
            Positioned(
              right: 0,
              top: size * 0.05,
              child: _shape(size * 0.26, size * 0.26, opacity: 0.55),
            ),
          ],
        ),
      );

  Widget _ears() => SizedBox(
        width: size * 1.1,
        height: size * 1.2,
        child: Stack(
          children: [
            Positioned(
              left: size * 0.08,
              top: 0,
              child: ClipPath(
                clipper: _TriangleClipper(),
                child: _shape(size * 0.22, size * 0.22, opacity: 0.6),
              ),
            ),
            Positioned(
              right: size * 0.08,
              top: 0,
              child: ClipPath(
                clipper: _TriangleClipper(),
                child: _shape(size * 0.22, size * 0.22, opacity: 0.6),
              ),
            ),
          ],
        ),
      );

  Widget _fin() => SizedBox(
        width: size,
        height: size * 1.35,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: size * 0.38,
              child: ClipPath(
                clipper: _TriangleClipper(),
                child: _shape(size * 0.24, size * 0.3, opacity: 0.45),
              ),
            ),
          ],
        ),
      );

  Widget _wings() => SizedBox(
        width: size * 1.4,
        height: size * 1.05,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              child: Transform.rotate(angle: -0.3, child: _shape(size * 0.35, size * 0.2, opacity: 0.5)),
            ),
            Positioned(
              right: 0,
              child: Transform.rotate(angle: 0.3, child: _shape(size * 0.35, size * 0.2, opacity: 0.5)),
            ),
          ],
        ),
      );
}

class _TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _TentaclesPainter extends CustomPainter {
  final Color color;
  const _TentaclesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final baseY = size.height * 0.35;
    final count = 4;
    for (var i = 0; i < count; i++) {
      final x = size.width * (0.2 + i * 0.2);
      final path = Path()..moveTo(x, baseY);
      path.quadraticBezierTo(
        x + (i.isEven ? 8 : -8), baseY + size.height * 0.3,
        x, size.height,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TentaclesPainter oldDelegate) => oldDelegate.color != color;
}
