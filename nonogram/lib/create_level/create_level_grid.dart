import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nonogram/game_internals/level_state.dart';
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
  final Palette palette = Palette();
  late LevelState levelState;
  final gridKey = GlobalKey();
  List<List<int>> rowIndications = [];
  List<List<int>> columnIndications = [];
  bool isSolvable = false;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    levelState = context.read<LevelState>();

    Future.microtask(() {
      setState(() {
        rowIndications = List.generate(widget.height, (_) => List.generate(1, (_) => 0));
        columnIndications = List.generate(widget.width, (_) => List.generate(1, (_) => 0));
      });
      levelState.initProgress(widget.height, widget.width);
      levelState.setIndicators(rowIndications, columnIndications);
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
                  child: Text(
                    indicationText,
                    style: TextStyle(fontSize: 12, color: palette.ink),
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
            children: col.map((val) => Text(val.toString())).toList(),
          ),
        );
      }).toList(),
    );
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

    void validatePuzzle() {
      final nonogram = no.Nonogram.monochrome(rowIndications, columnIndications);

      setState(() {
        isSolvable = nonogram.isLineSolveable();
      });
    }

    void handleDragEnd(DragEndDetails details) {
      setState(() {
        isDragging = false;
        startIndex = null;
        lastUpdatedIndex = null;
        updateIndicators();
        validatePuzzle();
      });
    }

    Widget buildCell(int index, double cellSize) {
      int row = index ~/ widget.width;
      int col = index % widget.width;

      bool isRightEdge = (col + 1) % 5 == 0 && col != widget.width - 1;
      bool isBottomEdge = (row + 1) % 5 == 0 && row != widget.height - 1;

      BoxDecoration decoration = BoxDecoration(
        color: levelState.progress[row][col] == 'X' ? Colors.black : Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black, width: 0.1),
          left: BorderSide(color: Colors.black, width: 0.1),
          right: BorderSide(color: Colors.black, width: isRightEdge ? 1 : 0.1),
          bottom: BorderSide(color: Colors.black, width: isBottomEdge ? 1 : 0.1),
        ),
      );

      return GestureDetector(
        onPanStart: handleDragStart,
        onPanUpdate: handleDragUpdate,
        onPanEnd: handleDragEnd,
        onTap: () {
          if (isDragging) return;
          levelState.setProgress(index);
          updateIndicators();
          validatePuzzle();
        },
        child: Container(
          decoration: decoration,
        ),
      );
    }

    return Consumer<LevelState>(builder: (context, levelState, child) {
      return GridView.builder(
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
        itemBuilder: (BuildContext context, int index) => buildCell(index, cellSize),
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
      backgroundColor: palette.backgroundMain,
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
          ],
        ),
        rectangularMenuArea: Column(
          children: [
            MyButton(
              onPressed: () async {
                if (isSolvable) {
                  FirebaseFirestore.instance.collection('levels').doc(widget.name).set({
                    'rowIndications': jsonEncode(rowIndications),
                    'columnIndications': jsonEncode(columnIndications),
                    'goal': jsonEncode(
                        levelState.progress.map((e) => e.map((e) => e == 'X' ? 1 : 0).toList()).toList()),
                    'name': widget.name,
                    'height': widget.height,
                    'width': widget.width,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Puzzle saved! Thank you for contributing!'),
                    ),
                  );

                  GoRouter.of(context).push('/');
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Puzzle is not solvable, cannot save.'),
                    ),
                  );
                }
                // checkFirebase();
              },
              child: Text(isSolvable ? 'Save' : 'Not solvable'),
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
