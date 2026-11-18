import 'package:cnattendance/utils/constant.dart';
import 'package:flutter/cupertino.dart';

BoxDecoration RadialDecoration() {
  return BoxDecoration(
      image: DecorationImage(
          image: AssetImage("assets/images/back.png"),
          fit: BoxFit.fitHeight,
          opacity: .7,
          alignment: Alignment.center),
      gradient: RadialGradient(colors: [
        Color(getAppTheme() ? appTheme : 0xff000000),
        Color(getAppTheme() ? appAlternateTheme : 0xff000000),
      ]));
}
