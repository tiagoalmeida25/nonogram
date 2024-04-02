import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nonogram/level_selection/level_provider.dart';

void showCustomFilterDialog(BuildContext context, LevelProvider levelProvider) {
  showGeneralDialog(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) =>
          CustomFilterDialog(animation: animation, levelProvider: levelProvider));
}

class CustomFilterDialog extends StatefulWidget {
  final Animation<double> animation;
  final LevelProvider levelProvider;

  const CustomFilterDialog({required this.animation, required this.levelProvider, super.key});

  @override
  State<CustomFilterDialog> createState() => _CustomFilterDialogState();
}

class _CustomFilterDialogState extends State<CustomFilterDialog> {
  final TextEditingController _controller = TextEditingController();
  int minHeight = 5;
  int maxHeight = 35;
  int minWidth = 5;
  int maxWidth = 35;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: widget.animation,
        curve: Curves.easeOutCubic,
      ),
      child: SimpleDialog(
        title: const Text(
          'Change Filter',
          style: TextStyle(
            fontFamily: 'Permanent Marker',
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search:',
                    style: const TextStyle(
                      fontFamily: 'Permanent Marker',
                      fontSize: 16,
                    ),
                  ),
                  TextField(
                    controller: _controller,
                    maxLength: 20,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                  ),
                  Text(
                    'Height:',
                    style: const TextStyle(
                      fontFamily: 'Permanent Marker',
                      fontSize: 16,
                    ),
                  ),
                  RangeSlider(
                    values: RangeValues(minHeight.toDouble(), maxHeight.toDouble()),
                    min: 5,
                    max: 35,
                    divisions: 30,
                    labels: RangeLabels(minHeight.toString(), maxHeight.toString()),
                    onChanged: (RangeValues values) {
                      setState(() {
                        minHeight = values.start.toInt();
                        maxHeight = values.end.toInt();
                      });
                    },
                  ),
                  Text(
                    'Width:',
                    style: const TextStyle(
                      fontFamily: 'Permanent Marker',
                      fontSize: 16,
                    ),
                  ),
                  RangeSlider(
                    values: RangeValues(minWidth.toDouble(), maxWidth.toDouble()),
                    min: 5,
                    max: 35,
                    divisions: 30,
                    labels: RangeLabels(minWidth.toString(), maxWidth.toString()),
                    onChanged: (RangeValues values) {
                      setState(() {
                        minWidth = values.start.toInt();
                        maxWidth = values.end.toInt();
                      });
                    },
                  ),
                ]),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  _controller.clear();
                  setState(() {
                    minHeight = 5;
                    maxHeight = 35;
                    minWidth = 5;
                    maxWidth = 35;
                  });

                  widget.levelProvider.clearFilter();

                  Navigator.pop(context);
                },
                child: const Text('Clear'),
              ),
              TextButton(
                onPressed: () {
                  widget.levelProvider.setFilter(_controller.text, minHeight, maxHeight, minWidth, maxWidth);

                  Navigator.pop(context);
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
