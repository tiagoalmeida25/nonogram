// Copyright 2022, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';

/// A palette of colors to be used in the game.
///
/// The reason we're not going with something like Material Design's
/// `Theme` is simply that this is simpler to work with and yet gives
/// us everything we need for a game.
///
/// Games generally have more radical color palettes than apps. For example,
/// every level of a game can have radically different colors.
/// At the same time, games rarely support dark mode.
///
/// Colors taken from this fun palette:
/// https://lospec.com/palette-list/crayola84
///
/// Colors here are implemented as getters so that hot reloading works.
/// In practice, we could just as easily implement the colors
/// as `static const`. But this way the palette is more malleable:
/// we could allow players to customize colors, for example,
/// or even get the colors from the network.
class Palette {
  Color get pen => const Color(0xff1d75fb);
  Color get darkPen => const Color(0xFF0050bc);
  Color get redPen => const Color(0xFFd10841);
  Color get inkFullOpacity => Color.fromARGB(255, 255, 255, 255);
  Color get ink => Color.fromARGB(237, 255, 255, 255);
  Color get backgroundMain => Color.fromARGB(255, 74, 76, 78);
  Color get backgroundLevelSelection => Color.fromARGB(255, 126, 167, 197);
  Color get backgroundPlaySession => Color.fromARGB(255, 29, 29, 29);
  Color get background4 => const Color(0xffffd7ff);
  Color get backgroundSettings => Color.fromARGB(255, 175, 175, 175);
  Color get trueWhite => const Color(0xffffffff);
}
