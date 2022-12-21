import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

final ButtonStyle outlineButtonStyleOrange = OutlinedButton.styleFrom(
  backgroundColor: CupertinoColors.activeOrange,
  primary: CupertinoColors.white,
  side: const BorderSide(
      color: CupertinoColors.systemOrange, width: 2), //<-- SEE HERE
);

final ButtonStyle outlineButtonStyleGrey = OutlinedButton.styleFrom(
  backgroundColor: CupertinoColors.white,
  primary: CupertinoColors.darkBackgroundGray,
  side: const BorderSide(
      color: CupertinoColors.systemGrey3, width: 2), //<-- SEE HERE
);

final ButtonStyle outlineButtonStyleSuccess = OutlinedButton.styleFrom(
  backgroundColor: CupertinoColors.activeGreen,
  primary: CupertinoColors.white,
  side: const BorderSide(
      color: CupertinoColors.activeGreen, width: 2), //<-- SEE HERE
);
