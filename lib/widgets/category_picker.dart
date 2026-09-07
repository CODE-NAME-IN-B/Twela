import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/twela_provider.dart';

class CategoryPicker extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<String> onSelect;

  const CategoryPicker({
    super.key,
    this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TwelaProvider>(
      builder: (context, provider, _) {
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: provider.categories.map((category) {
            final isSelected = selectedId == category.id;
            return GestureDetector(
              onTap: () => onSelect(category.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? category.color.withOpacity(0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? category.color : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category.icon,
                      size: 16,
                      color: isSelected ? category.color : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: isSelected ? category.color : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
