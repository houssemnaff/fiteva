import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class EtoilesCard extends StatelessWidget {
  final int etoiles;
  const EtoilesCard({super.key, required this.etoiles});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white, // ✅ toujours blanc
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          /// ICON
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9F0A).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.star_fill,
                color: Color(0xFFFF9F0A),
                size: 22,
              ),
            ),
          ),

          const SizedBox(width: 14),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Étoiles disponibles',
                  style: TextStyle(
                    color: Colors.black54, // ✅ noir soft
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$etoiles',
                      style: const TextStyle(
                        color: Colors.black, // ✅ noir
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'étoiles',
                      style: TextStyle(
                        color: Colors.black45, // ✅ gris noir
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// LINK
          GestureDetector(
            onTap: () {},
            child: const Text(
              'Historique',
              style: TextStyle(
                color: Color(0xFF007AFF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}