// Got the info from https://flutter-starter.geekyants.com/docs/add-color-constants and https://developer.spotify.com/documentation/design

import 'package:flutter/material.dart';

Color hexToColor(String hex) {
  assert(RegExp(r'^#([0-9a-fA-F]{6})|([0-9a-fA-F]{8})$').hasMatch(hex),
      'hex color must be #rrggbb or #rrggbbaa');

  return Color(
    int.parse(hex.substring(1), radix: 16) +
        (hex.length == 7 ? 0xff000000 : 0x00000000),
  );
}

  Color green = hexToColor('#1ed760');
  Color white = hexToColor('#ffffff');
  Color black = hexToColor('#121212');
  Color grey = hexToColor("#b3b3b3");
