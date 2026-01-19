import 'package:dawnforge/game/features/farm/managers/farm_manager.dart';
import 'package:dawnforge/game/features/farm/services/crop_factory_service.dart';
import 'package:dawnforge/game/features/inventory/managers/equipment_manager.dart';
import 'package:dawnforge/game/features/inventory/managers/inventory_manager.dart';
import 'package:dawnforge/game/features/inventory/services/item_factory_service.dart';
import 'package:dawnforge/game/global/global_state_machine.dart';
import 'package:dawnforge/pre_game/screens/menu_screen.dart';
import 'package:dawnforge/game/systems/localization/gameplay_localizations_delegate.dart';
import 'package:dawnforge/core/utils/app_environment.dart';
import 'package:dawnforge/game/features/farm/farm_service_locator.dart';
import 'package:dawnforge/game/features/inventory/config/inventory_service_locator.dart';
import 'package:dawnforge/shared/design_system/theme/app_design_system.dart';
import 'package:dawnforge/core/managers/settings_manager.dart';
import 'package:flame/flame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'game/systems/audio/audio_manager.dart';

Future<void> _initializeSingletons() async {
  await SettingsManager.instance.initializeOrientation();
  await AudioManager.instance.initialize();
  await CropFactoryService.instance.initialize();
  await ItemFactoryService.instance.initialize();
  FarmManager.instance.initializeTiles();
  InventoryManager.instance.initializeSlots();
  EquipmentManager.instance.initialize();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    await Flame.device.fullScreen();
  }

  await _initializeSingletons();

  await setupInventoryDependencies();
  await setupFarmDependencies();

  runApp(const AppRoot());
}

final class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    GameplayLocalizationsDelegate location =
        const GameplayLocalizationsDelegate();

    return AppDesignSystemProvider(
      debugIsOn: AppEnvironment.kIsDevToolsMode ? false : false,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // theme: ThemeData(fontFamily: 'Pixel'),
        themeMode: ThemeMode.dark,
        darkTheme: ThemeData(fontFamily: 'Pixel'),
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
}
