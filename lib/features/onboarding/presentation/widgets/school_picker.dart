import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// Tezkor maktab tanlash chiplari + custom input.
class SchoolPicker extends StatefulWidget {
  const SchoolPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<SchoolPicker> createState() => _SchoolPickerState();
}

class _SchoolPickerState extends State<SchoolPicker> {
  static const _presets = [
    AppStrings.schoolPresidential,
    AppStrings.schoolSpecialized,
  ];

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant SchoolPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
      _controller.selection =
          TextSelection.collapsed(offset: widget.value.length);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presets.map((school) {
            final selected = widget.value == school;
            return ChoiceChip(
              label: Text(school),
              selected: selected,
              onSelected: (_) => widget.onChanged(school),
              selectedColor: AppColors.accentSoft,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w800,
                color: selected ? AppColors.accentDark : AppColors.textPrimary,
              ),
              side: BorderSide(
                color: selected ? AppColors.accent : AppColors.surfaceAlt,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _controller,
          onChanged: widget.onChanged,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: AppStrings.schoolHint,
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.surfaceAlt),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.surfaceAlt),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.accent, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
