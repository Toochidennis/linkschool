import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:linkschool/modules/common/app_colors.dart';

class FlatBottomNavigation extends StatelessWidget {
  final List<NavigationItem> items;
  final int selectedIndex;
  final Function(int) onTabSelected;

  const FlatBottomNavigation({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          items.length,
          (index) => _buildNavItem(items[index], index),
        ),
      ),
    );
  }

Widget _buildNavItem(NavigationItem item, int index) {
  final isSelected = selectedIndex == index;

  // Determine the icon path based on active/inactive state
  final String currentIconPath = isSelected
      ? (item.activeIconPath ?? item.iconPath)
      : (item.inactiveIconPath ?? item.iconPath);

  // Use custom color if provided, otherwise use default colors
  final Color iconColor =
      item.color ?? (isSelected ? const Color(0xFFFFA500) : Colors.grey.shade600);

  // Build the icon widget first (so we can flip/rotate it conditionally)
  Widget iconWidget;

  if (index == 2) {
    // Center item icon (white)
    iconWidget = SvgPicture.asset(
      currentIconPath,
      width: item.iconWidth ?? 16,
      height: item.iconHeight ?? 16,
      colorFilter: const ColorFilter.mode(
        Colors.white,
        BlendMode.srcIn,
      ),
    );
  } else {
    // Normal icon
    iconWidget = SvgPicture.asset(
      currentIconPath,
      width: item.iconWidth ?? 24,
      height: item.iconHeight ?? 24,
      colorFilter: ColorFilter.mode(
        iconColor,
        BlendMode.srcIn,
      ),
    );
  }

  // ✅ Flip icon direction if enabled on this item
  if (item.flipIcon) {
    iconWidget = Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(3.1416), // horizontal mirror (face other side)
      child: iconWidget,
    );
  }

  return Expanded(
    child: InkWell(
      onTap: () => onTabSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon (special circle for center item)
            if (index == 2)
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: AppColors.text2Light,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: iconWidget,
              )
            else
              iconWidget,

            const SizedBox(height: 4),

            // Label
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: index == 2
                    ? (isSelected
                        ? const Color(0xFFFFA500)
                        : (item.color ?? const Color(0xFF1E3A8A)))
                    : (isSelected
                        ? const Color(0xFFFFA500)
                        : Colors.grey.shade600),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}
}

class NavigationItem {
  final String iconPath;
  final String label;
  final double? iconWidth;
  final double? iconHeight;
  final Color? color;
  final String? activeIconPath;
  final String? inactiveIconPath;
  final bool flipIcon; // ✅ ADD THIS

  NavigationItem({
    required this.iconPath,
    required this.label,
    this.iconWidth,
    this.iconHeight,
    this.color,
    this.activeIconPath,
    this.inactiveIconPath,
    this.flipIcon = false, // default
  });
}

 
