import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

/// Counter compact (− valeur +).
class CounterField extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  const CounterField({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 99,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _circleBtn(
          icon: Icons.remove_rounded,
          enabled: value > min,
          onTap: () => onChanged((value - 1).clamp(min, max)),
          highlight: false,
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 36),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          child: Text(
            '$value',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _circleBtn(
          icon: Icons.add_rounded,
          enabled: value < max,
          onTap: () => onChanged((value + 1).clamp(min, max)),
          highlight: true,
        ),
      ],
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
    required bool highlight,
  }) {
    return Material(
      color: highlight ? AppColors.primary.withOpacity(0.10) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: highlight
              ? AppColors.primary.withOpacity(0.40)
              : Colors.black.withOpacity(0.08),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            size: 18,
            color: highlight ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Champ texte numérique avec libellé et suffixe.
class LabeledNumberField extends StatelessWidget {
  final String label;
  final String? suffix;
  final String? hint;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  const LabeledNumberField({
    super.key,
    required this.label,
    required this.controller,
    this.suffix,
    this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6, left: 2),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint, fontWeight: FontWeight.w400),
            suffixText: suffix,
            suffixStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// Indicateur 3 étapes.
class StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> labels;
  const StepIndicator({super.key, required this.currentStep, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(labels.length, (i) {
        final reached = i <= currentStep;
        final completed = i < currentStep;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (i > 0)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: reached ? AppColors.primary : Colors.black.withOpacity(0.08),
                      ),
                    ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: reached ? AppColors.primary : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: reached ? AppColors.primary : Colors.black.withOpacity(0.12),
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: completed
                        ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                        : Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: reached ? Colors.white : AppColors.textHint,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                  ),
                  if (i < labels.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i < currentStep ? AppColors.primary : Colors.black.withOpacity(0.08),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                labels[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: i == currentStep ? FontWeight.w700 : FontWeight.w400,
                  color: reached ? AppColors.primary : AppColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Bouton primaire orange.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? trailingIcon;
  final IconData? leadingIcon;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
    this.trailingIcon,
    this.leadingIcon,
    this.fullWidth = false,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: fullWidth ? double.infinity : null,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.30),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  Icon(trailingIcon, color: Colors.white, size: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Bouton secondaire (transparent / outline orange).
class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? leadingIcon;
  const GhostButton({super.key, required this.label, required this.onTap, this.leadingIcon});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary.withOpacity(0.35)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(leadingIcon, color: AppColors.primary, size: 18),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
