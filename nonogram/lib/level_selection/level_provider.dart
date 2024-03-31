import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nonogram/level_selection/levels.dart'; // Import your GameLevel class

class LevelProvider with ChangeNotifier {
  List<GameLevel> _levels = [];
  bool _isLoading = true;

  List<GameLevel> get levels => _levels;
  bool get isLoading => _isLoading;

  LevelProvider() {
    loadLevels();
  }

  Future<void> loadLevels() async {
    _isLoading = true;
    notifyListeners();

    List<GameLevel> loadedLevels = [];
    try {
      final value = await FirebaseFirestore.instance.collection('levels').get();

      for (var element in value.docs) {
        final level = GameLevel.fromFirestore(element, loadedLevels.length + 1);
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

      _levels = loadedLevels;
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
