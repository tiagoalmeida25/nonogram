import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../style/my_button.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class CreateLevelScreen extends StatefulWidget {
  static const _gap = SizedBox(height: 45);

  const CreateLevelScreen({super.key});

  @override
  State<CreateLevelScreen> createState() => _CreateLevelScreenState();
}

class _CreateLevelScreenState extends State<CreateLevelScreen> {
  int height = 5;
  int width = 5;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();

    return Scaffold(
      backgroundColor: palette.backgroundSettings,
      body: ResponsiveScreen(
        squarishMainArea: ListView(
          children: [
            CreateLevelScreen._gap,
            const Text(
              'Create level',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Permanent Marker',
                fontSize: 30,
                height: 1,
              ),
            ),
            CreateLevelScreen._gap,
            Text(
              'Puzzle name:',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Permanent Marker',
                fontSize: 20,
              ),
            ),
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Enter puzzle name'),
              maxLength: 20,
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                setState(() {});
              },
            ),
            Text(
              'Height:',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Permanent Marker',
                fontSize: 20,
              ),
            ),
            Slider(
              value: height.toDouble(),
              min: 5,
              max: 35,
              divisions: 30,
              onChanged: (double value) {
                setState(() {
                  height = value.toInt();
                });
              },
              label: height.toString(),
            ),
            CreateLevelScreen._gap,
            Text(
              'Width:',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Permanent Marker',
                fontSize: 20,
              ),
            ),
            Slider(
              value: width.toDouble(),
              min: 5,
              max: 35,
              divisions: 30,
              onChanged: (double value) {
                setState(() {
                  width = value.toInt();
                });
              },
              label: width.toString(),
            ),
          ],
        ),
        rectangularMenuArea: Column(
          children: [
            MyButton(
              onPressed: () {
                if (controller.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a puzzle name'),
                    ),
                  );
                  return;
                }

                GoRouter.of(context).push('/create_level_grid/$width/$height/${controller.text}');
              },
              child: const Text('Create'),
            ),
            SizedBox(height: 10),
            MyButton(
              onPressed: () {
                GoRouter.of(context).pop();
              },
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
