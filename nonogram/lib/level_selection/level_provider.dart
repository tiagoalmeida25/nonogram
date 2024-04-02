import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nonogram/level_selection/levels.dart'; // Import your GameLevel class

class LevelProvider with ChangeNotifier {
  List<GameLevel> _levels = [];
  List<GameLevel> _allLevels = [];
  bool _isLoading = true;

  List<GameLevel> get levels => _levels;
  bool get isLoading => _isLoading;

  LevelProvider() {
    loadLevels();
  }

  void clearFilter() {
    _levels = _allLevels;
    notifyListeners();
  }

  void setFilter(String filter, int minHeight, int maxHeight, int minWidth, int maxWidth) {
    List<GameLevel> filteredLevels = _allLevels.where((level) {
      if (filter.isNotEmpty && !level.puzzleName.toLowerCase().contains(filter.toLowerCase())) {
        return false;
      }
      if (minHeight > level.height || maxHeight < level.height) {
        return false;
      }
      if (minWidth > level.width || maxWidth < level.width) {
        return false;
      }
      return true;
    }).toList();

    _levels = filteredLevels;

    notifyListeners();
  }

  Future<void> loadLevels() async {
    _isLoading = true;
    notifyListeners();

    List<GameLevel> loadedLevels = [];
    try {
      final value = await FirebaseFirestore.instance.collection('levels').get();

      for (var element in value.docs) {
        final level = GameLevel(
          number: loadedLevels.length + 1,
          puzzleName: element['name'] as String,
          goal: (jsonDecode(element['goal'] as String) as List).map((e) => (e as List).cast<int>()).toList(),
          columnIndications: (jsonDecode(element['columnIndications'] as String) as List)
              .map((e) => (e as List).cast<int>())
              .toList(),
          rowIndications: (jsonDecode(element['rowIndications'] as String) as List)
              .map((e) => (e as List).cast<int>())
              .toList(),
          width: element['width'] as int,
          height: element['height'] as int,
          difficulty: element.data().containsKey('difficulty') ? element['difficulty'] as double : null,
          ratings: element.data().containsKey('ratings')
              ? (element['ratings'] as List).map((e) => e as double).toList()
              : null,
        );

        if (!loadedLevels.any((loadedLevel) =>
            (loadedLevel.puzzleName == level.puzzleName) &&
            (loadedLevel.width == level.width) &&
            (loadedLevel.height == level.height))) {
          loadedLevels.add(level);
        }
      }
      loadedLevels.sort((a, b) {
        int compare = a.height.compareTo(b.height);
        if (compare != 0) {
          return compare;
        } else {
          return a.width.compareTo(b.width);
        }
      });

      for (var i = 0; i < loadedLevels.length; i++) {
        loadedLevels[i].number = i + 1;
      }

      _allLevels = loadedLevels;
      _levels = _allLevels;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading levels: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
