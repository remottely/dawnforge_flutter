import 'package:dawnforge/app/screens/menu_screen.dart';
import 'package:dawnforge/gameplay/core/modules/localization/gameplay_localizations_delegate.dart';
import 'package:dawnforge/gameplay/farm/database/crop_database.dart';
import 'package:dawnforge/gameplay/farm/farm_service_locator.dart';
import 'package:dawnforge/gameplay/inventory/config/inventory_service_locator.dart';
import 'package:dawnforge/gameplay/time/time_service_locator.dart';
import 'package:dawnforge/shared/managers/settings_manager.dart';
import 'package:flame/flame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'gameplay/core/modules/audio/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize orientation based on input mode (joystick = landscape, keyboard = all orientations)
  await SettingsManager.instance.initializeOrientation();

  if (!kIsWeb) {
    await Flame.device.fullScreen();
  }

  await AudioManager.instance.initialize();
  await CropDatabase.initialize();

  // Setup dependency injection
  await setupTimeDependencies();
  await setupInventoryDependencies();
  await setupFarmDependencies();

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
