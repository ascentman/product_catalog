import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final int maxStars;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 14.0,
    this.maxStars = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final starValue = index + 1;
        IconData icon;
        Color color;

        if (rating >= starValue) {
          icon = Icons.star_rounded;
          color = AppColors.starFilled;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half_rounded;
          color = AppColors.starFilled;
        } else {
          icon = Icons.star_border_rounded;
          color = AppColors.starEmpty;
        }

        return Icon(icon, size: size, color: color);
      }),
    );
  }
}
