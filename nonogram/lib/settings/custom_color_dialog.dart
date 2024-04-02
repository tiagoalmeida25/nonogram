import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:provider/provider.dart';

import 'settings.dart';

void showCustomColorDialog(BuildContext context) {
  showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) => CustomColorDialog(animation: animation));
}

class CustomColorDialog extends StatefulWidget {
  final Animation<double> animation;

  const CustomColorDialog({required this.animation, super.key});

  @override
  State<CustomColorDialog> createState() => _CustomColorDialogState();
}

class _CustomColorDialogState extends State<CustomColorDialog> {
  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: widget.animation,
        curve: Curves.easeOutCubic,
      ),
      child: SimpleDialog(
        title: const Text('Change Color'),
        children: [
          MaterialColorPicker(
            selectedColor: context.read<SettingsController>().colorChosen.value,
            onColorChange: (color) {
              context.read<SettingsController>().setColorChosen(color);
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
