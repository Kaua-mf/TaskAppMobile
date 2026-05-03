import 'package:flutter/material.dart';

class CategoryBadge extends StatelessWidget {
  final String category;
  final bool small;

  const CategoryBadge({
    super.key,
    required this.category,
    this.small = false,
  });

  Color _colorForCategory(String cat) {
    switch (cat) {
      case 'Trabalho':
        return Colors.blue.shade600;
      case 'Pessoal':
        return Colors.green.shade600;
      case 'Estudos':
        return Colors.orange.shade600;
      case 'Saúde':
        return Colors.red.shade500;
      case 'Finanças':
        return Colors.teal.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _iconForCategory(String cat) {
    switch (cat) {
      case 'Trabalho':
        return Icons.work_rounded;
      case 'Pessoal':
        return Icons.person_rounded;
      case 'Estudos':
        return Icons.school_rounded;
      case 'Saúde':
        return Icons.favorite_rounded;
      case 'Finanças':
        return Icons.attach_money_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForCategory(category);
    final icon = _iconForCategory(category);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: small ? 12 : 14, color: color),
          const SizedBox(width: 4),
          Text(
            category,
            style: TextStyle(
              fontSize: small ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
