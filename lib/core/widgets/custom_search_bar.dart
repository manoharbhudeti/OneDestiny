import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  const CustomSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterTap,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final surfaceColor = isDark ? AppColors.darkCardBg : AppColors.warmIvory;
    final unselectedBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final iconColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.fastOutSlowIn,
      height: 56,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isFocused ? AppColors.accentGold : unselectedBorder,
          width: _isFocused ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? AppColors.accentGold.withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: _isFocused ? 10 : 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: _isFocused ? 1.1 : 1.0,
            child: Icon(
              Icons.search_rounded,
              color: _isFocused ? primaryColor : iconColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              focusNode: _focusNode,
              controller: widget.controller,
              onChanged: widget.onChanged,
              style: AppTypography.description(context),
              decoration: InputDecoration(
                hintText: 'Search vendors, photographers, decorators...',
                hintStyle: AppTypography.description(context, isSecondary: true),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: widget.onFilterTap,
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.tune_rounded,
                  color: primaryColor,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }
}
