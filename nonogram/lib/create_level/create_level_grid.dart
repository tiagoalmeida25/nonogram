import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nonogram/game_internals/level_state.dart';
import 'package:nonogram/settings/settings.dart';
import 'package:nonogram_dart/nonogram_dart.dart' as no;
import 'package:provider/provider.dart';

import '../style/my_button.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class CreateLevelGridScreen extends StatefulWidget {
  final int width;
  final int height;
  final String name;

  const CreateLevelGridScreen({
    super.key,
    required this.width,
    required this.height,
    required this.name,
  });

  @override
  State<CreateLevelGridScreen> createState() => _CreateLevelGridScreenState();
}

class _CreateLevelGridScreenState extends State<CreateLevelGridScreen> {
  late SettingsController settings = SettingsController();

  final Palette palette = Palette();
  late LevelState levelState;
  final gridKey = GlobalKey();
  List<List<int>> rowIndications = [];
  List<List<int>> columnIndications = [];
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    levelState = context.read<LevelState>();
    settings = context.read<SettingsController>();

    Future.microtask(() {
      setState(() {
        rowIndications = List.generate(widget.height, (_) => List.generate(1, (_) => 0));
        columnIndications = List.generate(widget.width, (_) => List.generate(1, (_) => 0));
      });
      levelState.initProgress(widget.height, widget.width);
      levelState.setIndicators(rowIndications, columnIndications);
    });
  }

  void confirmPuzzleName() {
    final TextEditingController controller = TextEditingController(text: widget.name);

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Create level'),
            content: TextField(
              controller: controller,
            ),
            actions: [
              MyButton(
                onPressed: () async {
                  final docSnapshot =
                      await FirebaseFirestore.instance.collection('levels').doc(controller.text.trim()).get();
                  if (docSnapshot.exists) {
                    final querySnapshot = await FirebaseFirestore.instance
                        .collection('levels')
                        .where('name', isGreaterThanOrEqualTo: controller.text)
                        .get();

                    final existingNames = querySnapshot.docs.map((doc) => doc.id).toList();

                    int maxVersion = existingNames
                        .where((name) => name.startsWith(controller.text))
                        .map((name) => int.tryParse(name.split('_').last) ?? 1)
                        .fold(1, max);

                    final newName = '${controller.text} ${maxVersion + 1}';

                    FirebaseFirestore.instance.collection('levels').doc(newName.trim()).set({
                      'rowIndications': jsonEncode(rowIndications),
                      'columnIndications': jsonEncode(columnIndications),
                      'goal': jsonEncode(
                          levelState.progress.map((e) => e.map((e) => e == 'X' ? 1 : 0).toList()).toList()),
                      'name': controller.text.trim(),
                      'height': widget.height,
                      'width': widget.width,
                    });
                  } else {
                    FirebaseFirestore.instance.collection('levels').doc(controller.text).set({
                      'rowIndications': jsonEncode(rowIndications),
                      'columnIndications': jsonEncode(columnIndications),
                      'goal': jsonEncode(
                          levelState.progress.map((e) => e.map((e) => e == 'X' ? 1 : 0).toList()).toList()),
                      'name': controller.text,
                      'height': widget.height,
                      'width': widget.width,
                    });
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Puzzle saved! Thank you for contributing!'),
                    ),
                  );

                  GoRouter.of(context).push('/');
                },
                child: Text('Save'),
              ),
            ],
          );
        });
  }

  Widget _buildRowIndications(List<List<int>> rows, double cellSize) {
    final maxIndicationWidth = _calculateMaxRowIndicationWidth(rows);

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: rows.map((row) {
          final indicationText = row.join(' ');
          return SizedBox(
            height: cellSize,
            width: maxIndicationWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: FittedBox(
                    child: Text(
                      indicationText,
                      style: TextStyle(fontSize: 12, color: palette.ink),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  double _calculateMaxRowIndicationWidth(List<List<int>> rows) {
    double maxWidth = 0.0;
    final textStyle = TextStyle(fontSize: 12, color: palette.ink);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final row in rows) {
      final indicationText = row.join(' ');
      textPainter.text = TextSpan(text: indicationText, style: textStyle);
      textPainter.layout();
      maxWidth = max(maxWidth, textPainter.width);
    }

    return maxWidth + 4;
  }

  Widget _buildColumnIndications(List<List<int>> cols, double cellSize) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: cols.map((col) {
        return SizedBox(
          width: cellSize,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: col
                .map((val) => FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(val.toString(), style: TextStyle(fontSize: 12)),
                    ))
                .toList(),
          ),
        );
      }).toList(),
    );
  }

  bool validatePuzzle() {
    final nonogram = no.Nonogram.monochrome(rowIndications, columnIndications);

    final solver = no.LogicalSolver.empty(nonogram).solve();
    final solution = solver.toList();

    return solution.isNotEmpty;
  }

  Widget _buildPuzzleGrid(double cellSize) {
    int? startIndex;
    int? lastUpdatedIndex;
    int? dragMarker;

    void handleDragStart(DragStartDetails details) {
      isDragging = true;

      final RenderBox renderBox = gridKey.currentContext?.findRenderObject() as RenderBox;
      final offset = renderBox.globalToLocal(details.globalPosition);
      final int row = (offset.dy / cellSize).floor();
      final int col = (offset.dx / cellSize).floor();
      startIndex = row * widget.width + col;
      lastUpdatedIndex = startIndex;
      levelState.setProgress(startIndex!);
      dragMarker = levelState.progress[row][col] == 'X' ? 1 : 0;
    }

    void handleDragUpdate(DragUpdateDetails details) {
      final RenderBox renderBox = gridKey.currentContext?.findRenderObject() as RenderBox;
      final offset = renderBox.globalToLocal(details.globalPosition);
      final int currentRow = (offset.dy / cellSize).floor();
      final int currentCol = (offset.dx / cellSize).floor();
      final currentIndex = currentRow * widget.width + currentCol;
      final cellMarker = levelState.progress[currentRow][currentCol] == 'X' ? 1 : 0;
      if (cellMarker == dragMarker) return;

      if (currentIndex != lastUpdatedIndex) {
        levelState.setProgress(currentIndex);
        lastUpdatedIndex = currentIndex;
      }
    }

    void updateIndicators() {
      for (int i = 0; i < widget.height; i++) {
        final row = levelState.progress[i].map((e) => e == 'X' ? 1 : 0).toList();
        for (int j = 0; j < row.length; j++) {
          if (row[j] == 1) {
            if (j > 0) {
              row[j] += row[j - 1];
              row[j - 1] = 0;
            }
          }
        }
        rowIndications[i] = row.where((element) => element > 0).toList();
        if (rowIndications[i].isEmpty) {
          rowIndications[i] = [0];
        }
      }

      for (int i = 0; i < widget.width; i++) {
        final column = levelState.progress.map((e) => e[i]).map((e) => e == 'X' ? 1 : 0).toList();
        for (int j = 0; j < column.length; j++) {
          if (column[j] == 1) {
            if (j > 0) {
              column[j] += column[j - 1];
              column[j - 1] = 0;
            }
          }
        }

        columnIndications[i] = column.where((element) => element > 0).toList();
        if (columnIndications[i].isEmpty) {
          columnIndications[i] = [0];
        }
      }

      setState(() {
        rowIndications = rowIndications;
        columnIndications = columnIndications;
      });
    }

    void handleDragEnd(DragEndDetails details) {
      setState(() {
        isDragging = false;
        startIndex = null;
        lastUpdatedIndex = null;
        updateIndicators();
      });
    }

    return Consumer<LevelState>(builder: (context, levelState, child) {
      return Container(
        color: Colors.black,
        child: GridView.builder(
          key: gridKey,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: widget.height * widget.width,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.width,
            childAspectRatio: 1,
            mainAxisSpacing: 1,
            crossAxisSpacing: 1,
          ),
          itemBuilder: (BuildContext context, int index) => Cell(
            row: index ~/ widget.width,
            col: index % widget.width,
            cellSize: cellSize,
            levelState: levelState,
            width: widget.width,
            height: widget.height,
            onPanStart: handleDragStart,
            onPanUpdate: handleDragUpdate,
            onPanEnd: handleDragEnd,
            updateIndicators: updateIndicators,
            color: settings.colorChosen.value,
          ),
        ),
      );
    });
  }

  double calculateCellSize() {
    final maxRow = _calculateMaxRowIndicationWidth(rowIndications);

    final screenWidth = MediaQuery.of(context).size.width;
    final maxPuzzleWidth = screenWidth - maxRow - 30;
    final cellSize = maxPuzzleWidth / widget.width;

    final screenHeight = MediaQuery.of(context).size.height;
    final maxPuzzleHeight = screenHeight - 236;
    final cellSizeHeight = maxPuzzleHeight / widget.height;

    if (cellSizeHeight < cellSize) {
      return cellSizeHeight;
    }

    return cellSize;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<Palette>();
    final cellSize = calculateCellSize();

    return Scaffold(
      backgroundColor: palette.backgroundCreateLevel,
      body: ResponsiveScreen(
        squarishMainArea: Column(
          children: [
            const Text(
              'Create level',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Permanent Marker',
                fontSize: 30,
                height: 1,
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRowIndications(rowIndications, cellSize),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildColumnIndications(columnIndications, cellSize),
                    SizedBox(
                        height: cellSize * widget.height + 0,
                        width: cellSize * widget.width + 0,
                        child: _buildPuzzleGrid(cellSize)),
                  ],
                ),
              ],
            ),
            Spacer(),
          ],
        ),
        rectangularMenuArea: Column(
          children: [
            MyButton(
              onPressed: () {
                final isSolvable = validatePuzzle();

                if (isSolvable) {
                  confirmPuzzleName();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Puzzle is not solvable, cannot save.'),
                    ),
                  );
                }
                // checkFirebase();
              },
              child: Text('Save'),
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

class Cell extends StatefulWidget {
  final int row;
  final int col;
  final double cellSize;
  final LevelState levelState;
  final int width;
  final int height;
  final Function(DragStartDetails) onPanStart;
  final Function(DragUpdateDetails) onPanUpdate;
  final Function(DragEndDetails) onPanEnd;
  final Function() updateIndicators;
  final Color color;

  const Cell({
    super.key,
    required this.row,
    required this.col,
    required this.cellSize,
    required this.levelState,
    required this.width,
    required this.height,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.updateIndicators,
    required this.color,
  });

  @override
  CellState createState() => CellState();
}

class CellState extends State<Cell> {
  @override
  Widget build(BuildContext context) {
    bool isRightEdge = (widget.col + 1) % 5 == 0 && widget.col != widget.width - 1;
    bool isBottomEdge = (widget.row + 1) % 5 == 0 && widget.row != widget.height - 1;

    BoxDecoration decoration = BoxDecoration(
      color: widget.levelState.progress[widget.row][widget.col] == 'X' ? widget.color : Colors.white,
      border: Border(
        top: BorderSide(color: Colors.black, width: 0.1),
        left: BorderSide(color: Colors.black, width: 0.1),
        right: BorderSide(color: Colors.black, width: isRightEdge ? 1 : 0.1),
        bottom: BorderSide(color: Colors.black, width: isBottomEdge ? 1 : 0.1),
      ),
    );

    return GestureDetector(
      onPanStart: (details) {
        widget.onPanStart(details);
      },
      onPanUpdate: (details) {
        widget.onPanUpdate(details);
      },
      onPanEnd: (details) {
        widget.onPanEnd(details);
      },
      onTap: () {
        setState(() {
          widget.levelState.setProgress((widget.row * widget.width + widget.col));
        });
        widget.updateIndicators();
      },
      child: Container(
        decoration: decoration,
      ),
    );
  }
}
