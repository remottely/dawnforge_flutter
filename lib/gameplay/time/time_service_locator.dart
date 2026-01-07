import 'package:get_it/get_it.dart';

import 'time_manager.dart';
import 'time_scheduler.dart';

final getIt = GetIt.instance;

/// Registers time-related services.
Future<void> setupTimeDependencies() async {
  if (!getIt.isRegistered<TimeManager>()) {
    getIt.registerSingleton<TimeManager>(TimeManager.instance);
  }

  if (!getIt.isRegistered<TimeScheduler>()) {
    getIt.registerSingleton<TimeScheduler>(TimeManager.instance.scheduler);
  }
}
