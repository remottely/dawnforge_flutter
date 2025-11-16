import 'package:darkness_dungeon/app/screens/menu_screen.dart';
import 'package:darkness_dungeon/gameplay/core/modules/localization/gameplay_localizations_delegate.dart';
import 'package:darkness_dungeon/gameplay/inventory/item_factory.dart';
import 'package:flame/flame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'gameplay/core/modules/audio/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await Flame.device.setLandscape();
    await Flame.device.fullScreen();
  }

  // Initialize game systems
  await AudioManager.instance.initialize();
  await ItemFactory.initialize(); // Carrega database de itens

  GameplayLocalizationsDelegate location =
      const GameplayLocalizationsDelegate();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Normal'),
      home: MenuScreen(),
      supportedLocales: GameplayLocalizationsDelegate.supportedLocales(),
      localizationsDelegates: [
        location,
        DefaultCupertinoLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      localeResolutionCallback: location.resolution,
    ),
  );
}
