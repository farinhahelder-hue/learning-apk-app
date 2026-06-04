import 'package:flutter/material.dart';

class SubjectCard extends StatelessWidget {
  final String title;
  final String emoji;
  final String subtitle;
  final LinearGradient gradient;
  final int points;
  final VoidCallback onTap;

  const SubjectCard({
    super.key,
    required this.title,
    required this.emoji,
    required this.subtitle,
    required this.gradient,
    required this.points,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double pct = (points / 300).clamp(0.0, 1.0);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.4),
              blurRadius: 15, offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 52)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800,
                  )),
                  Text(subtitle, style: TextStyle(
                    color: Colors.white.withOpacity(0.85), fontSize: 12, fontWeight: FontWeight.w500,
                  )),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('$points pts', style: TextStyle(
                    color: Colors.white.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w600,
                  )),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}
