// Copyright 2023, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nonogram/create_level/create_level.dart';
import 'package:nonogram/create_level/create_level_grid.dart';
import 'package:nonogram/game_internals/level_state.dart';
import 'package:nonogram/level_selection/level_provider.dart';
import 'package:nonogram/level_selection/levels.dart';
import 'package:provider/provider.dart';

import 'game_internals/score.dart';
import 'level_selection/level_selection_screen.dart';
import 'main_menu/main_menu_screen.dart';
import 'play_session/play_session_screen.dart';
import 'settings/settings_screen.dart';
import 'style/my_transition.dart';
import 'style/palette.dart';
import 'win_game/win_game_screen.dart';

/// The router describes the game's navigational hierarchy, from the main
/// screen through settings screens all the way to each individual level.
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const MainMenuScreen(key: Key('main menu')),
      routes: [
        GoRoute(
            path: 'play',
            pageBuilder: (context, state) => buildMyTransition<void>(
                  key: ValueKey('play'),
                  color: context.watch<Palette>().backgroundLevelSelection,
                  child: const LevelSelectionScreen(
                    key: Key('level selection'),
                  ),
                ),
            routes: [
              GoRoute(
                path: 'session/:level',
                pageBuilder: (context, state) {
                  final levelProvider = Provider.of<LevelProvider>(context, listen: false);
                  if (levelProvider.isLoading) {
                    return MaterialPage(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final levelNumber = int.parse(state.pathParameters['level']!);
                  final level = levelProvider.levels.singleWhere((e) => e.number == levelNumber);
                  return buildMyTransition<void>(
                    key: ValueKey('level'),
                    color: context.watch<Palette>().backgroundPlaySession,
                    child: PlaySessionScreen(
                      level,
                      key: const Key('play session'),
                    ),
                  );
                },
              ),
              GoRoute(
                path: 'won',
                redirect: (context, state) {
                  if (state.extra == null) {
                    // Trying to navigate to a win screen without any data.
                    // Possibly by using the browser's back button.
                    return '/';
                  }

                  // Otherwise, do not redirect.
                  return null;
                },
                pageBuilder: (context, state) {
                  final map = state.extra! as Map<String, dynamic>;
                  final score = map['score'] as Score;
                  final level = map['level'] as GameLevel;

                  return buildMyTransition<void>(
                    key: ValueKey('won'),
                    color: context.watch<Palette>().backgroundPlaySession,
                    child: WinGameScreen(
                      score: score,
                      level: level,
                      key: const Key('win game'),
                    ),
                  );
                },
              )
            ]),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsScreen(key: Key('settings')),
        ),
        GoRoute(
          path: 'create_level',
          builder: (context, state) => CreateLevelScreen(),
        ),
        GoRoute(
            path: 'create_level_grid/:width/:height/:name',
            builder: (context, state) {
              int width = int.parse(state.pathParameters['width'] ?? '0');
              int height = int.parse(state.pathParameters['height'] ?? '0');
              String name = state.pathParameters['name'] ?? '';

              return ChangeNotifierProvider<LevelState>(
                  create: (context) => LevelState(
                        onWin: () {},
                      ),
                  child: CreateLevelGridScreen(width: width, height: height, name: name));
            }),
      ],
    ),
  ],
);
