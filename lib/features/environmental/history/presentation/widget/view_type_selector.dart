import 'package:flutter/material.dart';
import '../../../../../core/config/theme.dart';

enum HistoryViewType { hourly, daily }

class ViewTypeSelector extends StatelessWidget {
  const ViewTypeSelector({
    super.key,
    required this.selectedViewType,
    required this.onViewTypeChanged,
  });

  final HistoryViewType selectedViewType;
  final ValueChanged<HistoryViewType> onViewTypeChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 12,
      children: [
        _ViewTypeChip(
          label: 'Hourly',
          viewType: HistoryViewType.hourly,
          isSelected: selectedViewType == HistoryViewType.hourly,
          onTap: () => onViewTypeChanged(HistoryViewType.hourly),
        ),
        _ViewTypeChip(
          label: 'Daily',
          viewType: HistoryViewType.daily,
          isSelected: selectedViewType == HistoryViewType.daily,
          onTap: () => onViewTypeChanged(HistoryViewType.daily),
        ),
      ],
    );
  }
}

class _ViewTypeChip extends StatelessWidget {
  const _ViewTypeChip({
    required this.label,
    required this.viewType,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final HistoryViewType viewType;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.dividerColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

