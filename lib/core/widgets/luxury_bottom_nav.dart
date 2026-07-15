import 'package:booking_app/core/theme/app_colors.dart';
import 'package:booking_app/core/theme/app_typography.dart';
import 'package:flutter/material.dart';

class LuxuryBottomNav extends StatelessWidget {
  const LuxuryBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    _NavItem(Icons.search_rounded, 'Explore'),
    _NavItem(Icons.calendar_month_outlined, 'Trips'),
    _NavItem(Icons.person_outline_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(18, 10, 18, bottom > 0 ? bottom : 10),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final selected = index == currentIndex;
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onTap(index),
              child: SizedBox(
                height: 54,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      item.icon,
                      size: 22,
                      color: selected ? AppColors.accent : AppColors.textMuted,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.label,
                      style: AppTypography.caption.copyWith(
                        color:
                            selected ? AppColors.accent : AppColors.textMuted,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: selected ? 24 : 0,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.icon, this.label);
  final IconData icon;
  final String label;
}
