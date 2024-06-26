import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import 'package:nonogram/settings/settings.dart';
import 'package:nonogram/style/palette.dart';
import 'package:provider/provider.dart';

import '../audio/audio_controller.dart';
import '../audio/sounds.dart';
import '../game_internals/level_state.dart';
import '../level_selection/levels.dart';

class GameWidget extends StatefulWidget {
  const GameWidget({super.key});

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> {
  late LevelState levelState;
  late GameLevel level;
  late Palette palette;
  late SettingsController settings;
  bool loaded = false;
  final GlobalKey gridKey = GlobalKey();
  bool isDragging = false;
  Timer? timer;
  Duration timePassed = Duration.zero;

  @override
  void initState() {
    super.initState();
    level = context.read<GameLevel>();
    levelState = context.read<LevelState>();
    palette = context.read<Palette>();
    settings = context.read<SettingsController>();

    Future.microtask(() {
      levelState.initProgress(level.height, level.width);
      levelState.setIndicators(level.rowIndications, level.columnIndications);

      setState(() {
        loaded = true;
      });
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          timePassed += Duration(seconds: 1);
        });
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  double calculateCellSize() {
    final maxRows = _calculateMaxRowIndicationWidth(level.rowIndications);

    final screenWidth = MediaQuery.of(context).size.width;
    final maxPuzzleWidth = screenWidth - maxRows - 32;
    final cellSize = maxPuzzleWidth / level.width;

    final screenHeight = MediaQuery.of(context).size.height;
    final maxPuzzleHeight = screenHeight - 250;
    final cellSizeHeight = maxPuzzleHeight / level.height;

    if (cellSizeHeight < cellSize) {
      return cellSizeHeight;
    }

    return cellSize;
  }

  Widget _buildRowIndications(List<List<int>> rows, double cellSize) {
    final maxIndicationWidth = _calculateMaxRowIndicationWidth(rows);

    return GestureDetector(
      onTap: () {
        levelState.setMarker(levelState.marker == 'X' ? '.' : 'X');
      },
      child: Padding(
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
                  SizedBox(
                    width: maxIndicationWidth,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
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
      ),
    );
  }

  double _calculateMaxRowIndicationWidth(List<List<int>> rows) {
    double maxWidth = 0.0;
    final textStyle = TextStyle(fontSize: 12, fontFamily: 'Permanent Marker', color: palette.ink);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final row in rows) {
      final indicationText = row.join(' ');
      textPainter.text = TextSpan(text: indicationText, style: textStyle);
      textPainter.layout();
      maxWidth = max(maxWidth, textPainter.width);
    }

    return maxWidth + 6;
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

  Widget _buildPuzzleGrid(double cellSize) {
    int? startIndex;
    int? lastUpdatedIndex;
    String? dragMarker;

    void handleDragStart(DragStartDetails details) {
      isDragging = true;
      final RenderBox renderBox = gridKey.currentContext?.findRenderObject() as RenderBox;
      final offset = renderBox.globalToLocal(details.globalPosition);
      final int row = (offset.dy / cellSize).floor();
      final int col = (offset.dx / cellSize).floor();
      startIndex = row * level.width + col;
      lastUpdatedIndex = startIndex;
      levelState.setProgress(startIndex!);
      dragMarker = levelState.progress[row][col];
    }

    void handleDragUpdate(DragUpdateDetails details) {
      final RenderBox renderBox = gridKey.currentContext?.findRenderObject() as RenderBox;
      final offset = renderBox.globalToLocal(details.globalPosition);
      final int currentRow = (offset.dy / cellSize).floor();
      final int currentCol = (offset.dx / cellSize).floor();
      final currentIndex = currentRow * level.width + currentCol;

      final cellMarker = levelState.progress[currentRow][currentCol];
      if (cellMarker == dragMarker) {
        return;
      }

      if (currentIndex != lastUpdatedIndex) {
        levelState.setProgress(currentIndex);
        lastUpdatedIndex = currentIndex;
      }
    }

    void handleDragEnd(DragEndDetails details) {
      levelState.evaluate();
      level.setSolution(levelState.progress.map((e) => e.map((e) => e == 'X' ? 1 : 0).toList()).toList());

      isDragging = false;
      lastUpdatedIndex = null;
    }

    Widget buildCell(int index, double cellSize) {
      int row = index ~/ level.width;
      int col = index % level.width;
      final marker = levelState.progress[row][col];
      bool isRightEdge = (col + 1) % 5 == 0 && col != level.width - 1;
      bool isBottomEdge = (row + 1) % 5 == 0 && row != level.height - 1;

      BoxDecoration decoration = BoxDecoration(
        color: marker == 'X' ? settings.colorChosen.value : Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black, width: 0.1),
          left: BorderSide(color: Colors.black, width: 0.1),
          right: BorderSide(color: Colors.black, width: isRightEdge ? 1.5 : 0.1),
          bottom: BorderSide(color: Colors.black, width: isBottomEdge ? 1.5 : 0.1),
        ),
      );

      return GestureDetector(
        onPanStart: handleDragStart,
        onPanUpdate: handleDragUpdate,
        onPanEnd: handleDragEnd,
        onTap: () {
          // if (isDragging) return;
          context.read<AudioController>().playSfx(SfxType.wssh);
          levelState.setProgress(index);
          level.setSolution(levelState.progress.map((e) => e.map((e) => e == 'X' ? 1 : 0).toList()).toList());
          levelState.evaluate();
        },
        child: Container(
          decoration: decoration,
          child: marker == '.' ? FittedBox(child: Icon(Icons.close)) : null,
        ),
      );
    }

    return Consumer<LevelState>(builder: (context, levelState, child) {
      return GridView.builder(
        key: gridKey,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: level.height * level.width,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: level.width,
          childAspectRatio: 1,
          mainAxisSpacing: 1,
          crossAxisSpacing: 1,
        ),
        itemBuilder: (BuildContext context, int index) => buildCell(index, cellSize),
      );
    });
  }

  Widget appBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(level.puzzleName,
            style: TextStyle(
              color: palette.ink,
              fontSize: 24,
              fontFamily: 'Permanent Marker',
            )),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildTimerDisplay() {
    return Text(
      _formatDuration(timePassed),
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Permanent Marker'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cellSize = calculateCellSize();

    if (!loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        appBar(),
        const SizedBox(height: 16),
        _buildTimerDisplay(),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildRowIndications(level.rowIndications, cellSize),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildColumnIndications(level.columnIndications, cellSize),
                      SizedBox(
                          height: cellSize * level.height + 0,
                          width: cellSize * level.width + 0,
                          child: _buildPuzzleGrid(cellSize)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // Spacer(),
        SizedBox(
          height: 50,
          width: double.infinity,
          child: Stack(
            children: [
              Center(
                child: FlutterToggleTab(
                  width: 30,
                  borderRadius: 30,
                  height: 50,
                  marginSelected: EdgeInsets.all(3),
                  selectedIndex: levelState.marker == 'X' ? 0 : 1,
                  selectedBackgroundColors: [palette.backgroundPlaySession],
                  unSelectedBackgroundColors: const [Colors.white],
                  selectedTextStyle: TextStyle(color: Colors.white),
                  unSelectedTextStyle: TextStyle(color: palette.backgroundPlaySession),
                  labels: const ['', ''],
                  icons: const [Icons.square, Icons.close],
                  selectedLabelIndex: (index) {
                    setState(() {
                      levelState.setMarker(index == 0 ? 'X' : '.');
                    });
                  },
                  isScroll: false,
                ),
              ),
              Positioned(
                left: 32,
                child: IconButton(
                  onPressed: () {
                    levelState.undo();
                  },
                  icon: Icon(Icons.undo, color: palette.ink),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
