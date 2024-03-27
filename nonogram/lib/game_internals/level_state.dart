import 'package:flutter/foundation.dart';

class LevelState extends ChangeNotifier {
  final VoidCallback onWin;
  List<List<int>> goal;
  String marker;

  LevelState({required this.onWin, this.goal = const <List<int>>[], this.marker = 'X'});

  List<List<int>> rowIndicatorsCompleted = [];
  List<List<int>> columnIndicatorsCompleted = [];
  List<List<int>> rowIndicators = [];
  List<List<int>> columnIndicators = [];

  List<List<String>> _progress = [];
  List<Map<String, dynamic>> _moves = [];

  List<List<String>> get progress => _progress;
  List<Map<String, dynamic>> get moves => _moves;

  void initProgress(int height, int width) {
    _progress = List.generate(height, (_) => List.generate(width, (_) => ''));
    notifyListeners();
  }

  void setIndicators(List<List<int>> rowIndicators, List<List<int>> columnIndicators) {
    rowIndicatorsCompleted = List.generate(rowIndicators.length, (i) => rowIndicators[i]);
    this.rowIndicators = List.generate(rowIndicators.length, (i) => rowIndicators[i]);
    columnIndicatorsCompleted = List.generate(columnIndicators.length, (i) => columnIndicators[i]);
    this.columnIndicators = List.generate(columnIndicators.length, (i) => columnIndicators[i]);
    notifyListeners();
  }

  void setMarker(String value) {
    marker = value;
    notifyListeners();
  }

  void updateIndicators() {
    _updateRowIndicators();
    _updateColumnIndicators();
  }

  void _updateRowIndicators() {
    for (int rowIndex = 0; rowIndex < _progress.length; rowIndex++) {
      List<int> filledBlocks = _calculateFilledBlocksRow(_progress[rowIndex]);
      List<int> indicators = rowIndicators[rowIndex];

      if (listEquals(filledBlocks, indicators)) {
        rowIndicatorsCompleted[rowIndex] = [];
        for (int i = 0; i < _progress[rowIndex].length; i++) {
          if (_progress[rowIndex][i] != 'X') {
            _progress[rowIndex][i] = '.';
          }
        }
      }
    }
  }

  void _updateColumnIndicators() {
    for (int colIndex = 0; colIndex < _progress[0].length; colIndex++) {
      List<String> column = List.generate(_progress.length, (rowIndex) => _progress[rowIndex][colIndex]);
      List<int> filledBlocks = _calculateFilledBlocksForColumn(column);
      List<int> indicators = columnIndicators[colIndex];

      if (listEquals(filledBlocks, indicators)) {
        columnIndicatorsCompleted[colIndex] = [];
        for (int i = 0; i < _progress.length; i++) {
          if (_progress[i][colIndex] != 'X') {
            _progress[i][colIndex] = '.';
          }
        }
      }
    }
  }

  List<int> _calculateFilledBlocksRow(List<String> row) {
    List<int> line = row.map((e) => e == 'X' ? 1 : 0).toList();

    for (int i = 0; i < line.length; i++) {
      if (line[i] == 1) {
        if (i > 0) {
          line[i] += line[i - 1];
          line[i - 1] = 0;
        }
      }
    }
    return line.where((element) => element > 0).toList();
  }

  List<int> _calculateFilledBlocksForColumn(List<String> column) {
    List<int> line = column.map((e) => e == 'X' ? 1 : 0).toList();

    for (int i = 0; i < line.length; i++) {
      if (line[i] == 1) {
        if (i > 0) {
          line[i] += line[i - 1];
          line[i - 1] = 0;
        }
      }
    }
    return line.where((element) => element > 0).toList();
  }

  void setProgress(int index) {
    int row = index ~/ _progress[0].length;
    int col = index % _progress[0].length;

    if (_progress[row][col] == marker) {
      _progress[row][col] = '';
      _moves.add({'order': _moves.length, '': marker, 'index': index});
    } else {
      _progress[row][col] = marker;
      _moves.add({'order': _moves.length, 'marker': marker, 'index': index});
    }

    updateIndicators();

    notifyListeners();
  }

  void setProgressForDrag(int startIndex, int endIndex) {
    int startRow = startIndex ~/ _progress[0].length;
    int startCol = startIndex % _progress[0].length;

    int endRow = endIndex ~/ _progress[0].length;
    int endCol = endIndex % _progress[0].length;

    if (_progress[startRow][startCol] == marker) {
      for (int i = startRow; i <= endRow; i++) {
        for (int j = startCol; j <= endCol; j++) {
          final int index = i * _progress[0].length + j;
          _progress[i][j] = '';
          _moves.add({'order': _moves.length, 'marker': marker, 'index': index});
        }
      }
    } else {
      for (int i = startRow; i <= endRow; i++) {
        for (int j = startCol; j <= endCol; j++) {
          final int index = i * _progress[0].length + j;

          _progress[i][j] = marker;
          _moves.add({'order': _moves.length, 'marker': marker, 'index': index});
        }
      }
    }

    notifyListeners();
  }

  void undo() {
    if (_moves.isNotEmpty) {
      int index = _moves.last['index'] as int;
      int row = index ~/ _progress[0].length;
      int col = index % _progress[0].length;

      _progress[row][col] = '';
      _moves.removeLast();
      notifyListeners();
    }
  }

  void evaluate() {
    int counter = 0;
    List<List<int>> userGrid = _progress.map((e) => e.map((e) => e == 'X' ? 1 : 0).toList()).toList();

    if (goal.isNotEmpty) {
      for (int i = 0; i < goal.length; i++) {
        if (listEquals(userGrid[i], goal[i])) {
          counter++;
        }
      }

      if (counter == goal.length) {
        onWin();
      }
    } else {
      print('rows: $rowIndicatorsCompleted columns: $columnIndicatorsCompleted');
      for (int i = 0; i < rowIndicatorsCompleted.length; i++) {
        if (rowIndicatorsCompleted[i].isEmpty) {
          counter++;
        }
      }
      for (int i = 0; i < columnIndicatorsCompleted.length; i++) {
        if (columnIndicatorsCompleted[i].isEmpty) {
          counter++;
        }
      }
      if (counter == rowIndicatorsCompleted.length + columnIndicatorsCompleted.length) {
        onWin();
      }
    }
  }
}
