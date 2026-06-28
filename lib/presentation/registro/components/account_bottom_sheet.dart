import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/typography.dart';
import '../../../domain/models/account.dart';

class AccountBottomSheet extends StatelessWidget {
  final List<Account> accounts;
  final Account? selected;
  final Account? excluded;
  final ValueChanged<Account> onSelected;

  const AccountBottomSheet({
    super.key,
    required this.accounts,
    required this.selected,
    required this.onSelected,
    this.excluded,
  });

  static Future<void> show({
    required BuildContext context,
    required List<Account> accounts,
    required Account? selected,
    required ValueChanged<Account> onSelected,
    Account? excluded,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => AccountBottomSheet(
        accounts: accounts,
        selected: selected,
        excluded: excluded,
        onSelected: onSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final available = accounts.where((a) => a.id != excluded?.id).toList();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text('Selecciona la cuenta', style: AppTypography.heading2()),
          const SizedBox(height: 16),
          ...available.map((account) {
            final isSelected = selected?.id == account.id;
            return GestureDetector(
              onTap: () {
                onSelected(account);
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent.withValues(alpha: 0.1)
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.accent : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Text(account.emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 14),
                    Expanded(
                      child:
                          Text(account.name, style: AppTypography.bodyMedium()),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.accent, size: 20),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
