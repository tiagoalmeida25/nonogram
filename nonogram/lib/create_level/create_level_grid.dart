import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nonogram_dart/nonogram_dart.dart' as no;
import 'package:provider/provider.dart';

import '../style/my_button.dart';
import '../style/palette.dart';
import '../style/responsive_screen.dart';

class CreateLevelGridScreen extends StatefulWidget {
  final int width;
  final int height;
  final String name;
  static const _gap = SizedBox(height: 45);

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
  final gridKey = GlobalKey();
  List<List<int>> grid = [];
  List<List<int>> rowIndications = [];
  List<List<int>> columnIndications = [];
  bool isSolvable = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      grid = List.generate(widget.height, (_) => List.generate(widget.width, (_) => 0));
      rowIndications = List.generate(widget.height, (_) => List.generate(1, (_) => 0));
      columnIndications = List.generate(widget.width, (_) => List.generate(1, (_) => 0));
    });
  }

  void checkFirebase() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('levels').get();
      print('Fetched ${snapshot.docs.length} documents from Firestore.');
    } catch (e) {
      print('Failed to fetch documents: $e');
    }
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
      final RenderBox renderBox = gridKey.currentContext?.findRenderObject() as RenderBox;
      final offset = renderBox.globalToLocal(details.globalPosition);
      final int row = (offset.dy / cellSize).floor();
      final int col = (offset.dx / cellSize).floor();
      startIndex = row * widget.width + col;
      lastUpdatedIndex = startIndex;

      grid[row][col] = grid[row][col] == 1 ? 0 : 1;

      dragMarker = grid[row][col];
    }

    void handleDragUpdate(DragUpdateDetails details) {
      final RenderBox renderBox = gridKey.currentContext?.findRenderObject() as RenderBox;
      final offset = renderBox.globalToLocal(details.globalPosition);
      final int currentRow = (offset.dy / cellSize).floor();
      final int currentCol = (offset.dx / cellSize).floor();
      final currentIndex = currentRow * widget.width + currentCol;

      if (grid[currentRow][currentCol] == dragMarker) {
        return;
      }

      if (currentIndex != lastUpdatedIndex) {
        grid[currentRow][currentCol] = grid[currentRow][currentCol] == 1 ? 0 : 1;
        lastUpdatedIndex = currentIndex;
      }
    }

    void handleDragEnd(DragEndDetails details) {
      startIndex = null;
      lastUpdatedIndex = null;
    }

    void updateIndicators() {
      for (int i = 0; i < widget.height; i++) {
        final row = grid[i].map((e) => e == 1 ? 1 : 0).toList();
        for (int j = 0; j < row.length; j++) {
          if (row[j] == 1) {
            if (j > 0) {
              row[j] += row[j - 1];
              row[j - 1] = 0;
            }
          }
        }
        rowIndications[i] = row.where((element) => element > 0).toList();
      }

      for (int i = 0; i < widget.width; i++) {
        final column = grid.map((e) => e[i]).map((e) => e == 1 ? 1 : 0).toList();
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

    Widget buildCell(int index, double cellSize) {
      int row = index ~/ widget.width;
      int col = index % widget.width;

      bool isRightEdge = (col + 1) % 5 == 0 && col != widget.width - 1;
      bool isBottomEdge = (row + 1) % 5 == 0 && row != widget.height - 1;

      BoxDecoration decoration = BoxDecoration(
        color: grid[row][col] == 1 ? Colors.black : Colors.white,
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
          final col = index % widget.width;
          final row = index ~/ widget.width;

          setState(() {
            grid[row][col] = grid[row][col] == 1 ? 0 : 1;
          });
          updateIndicators();
          validatePuzzle();
        },
        child: Container(
          decoration: decoration,
        ),
      );
    }

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
  }

  double calculateCellSize() {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxPuzzleWidth = screenWidth - 64;
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
        squarishMainArea: ListView(
          children: [
            CreateLevelGridScreen._gap,
            const Text(
              'Create level',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Permanent Marker',
                fontSize: 30,
                height: 1,
              ),
            ),
            CreateLevelGridScreen._gap,
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
              onPressed: () {
                if (isSolvable) {
                FirebaseFirestore.instance.collection('levels').doc(widget.name).set({
                  'rowIndications': rowIndications,
                  'columnIndications': columnIndications,
                  'name': widget.name,
                  'goal': grid,
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
