# Stardew-like Time/Day Module Prompt Pack

**How to use**
- Run the prompts in order.
- Each prompt is self-contained (copy/paste to your coding agent).
- Prompts reference existing structures so your current save/advance-day flow keeps working.

---

## 1) Create the Time module scaffold
Add a new module `time` under `lib/gameplay/time/` with:
- Services: `time_manager.dart` (authoritative clock/day/seasons), `time_scheduler.dart` (scheduled callbacks).
- Models: `game_time.dart` (hour/minute, ticks), `day_state.dart` (day number, season, weather, weekday, festival flags), `weather_type.dart`, `season_type.dart`, `time_constants.dart`.
- Use ValueNotifiers/Streams for UI hooks.
- Provide `TimeServiceLocator` to register singletons.
- Ensure the manager can be initialized from save data and produce a JSON blob for save.
- Keep default start: Day 1, 6:00 AM, Season: Spring, Weather: sunny.
- Include doc comments on public APIs.

## 2) Define Stardew-like rules
Implement in `time/time_constants.dart`:
- Day length: 20 in-game hours (6:00 → 2:00), with forced sleep at 2:00.
- Tick granularity: 10 in-game minutes per tick.
- Real-time ratio: 1 in-game minute = 0.7 real seconds (configurable).
- Energy drain expectations per hour (leave hook only; not implemented yet).
- Seasons: Spring, Summer, Fall, Winter; 28 days each.
- Weather types: sunny, rain, storm, snow, festival.
Add helper functions for wrapping days/seasons.

## 3) Core clock and advancement
Implement in `time/time_manager.dart`:
- Hold current `GameTime` (hour, minute), `DayState` (dayIndex, season, weather, weekday).
- Methods: `start()`, `stop()`, `tick(dtRealSeconds)`, `advanceToNextDay()`.
- `tick` accumulates real seconds → advances 10 in-game minutes → emits notifiers.
- At or after 2:00, auto-trigger `advanceToNextDay()`.
- Expose ValueNotifiers: `timeNotifier`, `dayStateNotifier`.
- Allow pausing/unpausing (for menus/cutscenes).
- Respect manual advance (kAdvanceDayKey) by calling `advanceToNextDay()`.

## 4) Scheduling system
Implement in `time/time_scheduler.dart`:
- Accept scheduled callbacks keyed by absolute in-game time (day + minutes) or relative (N minutes from now).
- Support cancellation by id.
- Trigger due callbacks on each tick; handle catch-up if time jumps (manual day advance).
- Allow repeating schedules (e.g., every day at 6:10) with season/day filters.

## 5) Weather and festivals (minimal viable)
Implement in `time/day_state.dart`:
- Fields: `dayNumber`, `season`, `weather`, `isFestival`, `weekdayIndex`.
- Add simple weather generator: rule-based (e.g., storm chance in summer, snow in winter), overridable by saved state.
- Festival hook: bool plus optional `festivalId`; default false.
- Provide `copyWith`, `toJson`, `fromJson`.

## 6) Save/load integration
Integrate save:
- Add `TimeManager` state into existing save pipeline (both save and load) alongside current farm/inventory.
- JSON shape: `{ time: GameTime, day: DayState, isRunning: bool }`.
- On load, rehydrate TimeManager and restart ticking if game is not paused.
- Ensure kAdvanceDayKey flow still works: when invoked, call `TimeManager.advanceToNextDay()`; existing save paths should include time state.

## 7) Hook into existing kAdvanceDayKey
In input handling where kAdvanceDayKey is processed (keyboard_setup / controllers), replace direct farm advance with:
```
TimeManager.instance.advanceToNextDay();
await SaveGameController.save(); // or existing save hook you use on day-advance
```
Keep existing behaviors (farm advancement, etc.) by subscribing to day-change events (see next prompt).

## 8) Cross-module reactions on day change
Wire listeners:
- `FarmManager`: listen to `TimeManager.dayStateNotifier`; on day change, call existing `advanceDay()` to grow crops and consume water.
- `Energy/Stamina` (if present): reset daily.
- `NPC schedules` (future): hook via scheduler (not implemented now).
- `Shops`: placeholder hook to refresh stock.
Implement a `TimeEventsBus` or just expose `addDayChangeListener` in `TimeManager`.

## 9) UI surfaces (lightweight)
Add a tiny UI hook (no heavy UI required): a `TimeHudAdapter` that listens to `timeNotifier` and `dayStateNotifier` and exposes formatted strings for HUD. Keep UI opt-in; do not break existing HUD.

## 10) Map entry initial time handling
On map load (gameplay_screen), do not reset time. Just ensure TimeManager is started if not running. If map properties provide a `timeOverride` (optional), ignore unless specifically set; default is to keep current time.

## 11) Dependency registration
Add `setupTimeDependencies()` in a new `time_service_locator.dart`:
- Register singletons for `TimeManager`, `TimeScheduler`.
- Call this from main setup before modules that depend on time (farm, energy, NPC).

## 12) Testing checklist (manual)
Test cases:
1) Game start: time shows 6:00, Day 1 Spring, sunny.
2) Let time run: advances 10 in-game minutes at the configured rate.
3) Press kAdvanceDayKey: day increments, farm.advanceDay runs, time resets to 6:00, weather re-rolls.
4) Auto day roll at 2:00: triggers same as manual advance.
5) Save/load mid-day: state is restored, timers resume.
6) Scheduler: schedule an event 30 minutes from now; it fires after 3 real seconds (given the ratio).
7) Season wrap: after Day 28 Spring, move to Day 1 Summer.

## 13) Guardrails and compatibility
Ensure:
- TimeManager is authoritative; no other module mutates currentDay directly.
- Existing WorldStateManager currentDay usage: route through TimeManager (either deprecate or mirror value); provide a compatibility getter so existing code keeps working until refactor is complete.
- Keep defaults so current flows (farm advance) remain intact while you migrate listeners.

## 14) Nice-to-have backlog (optional)
Optional follow-ups:
- Sleep beds trigger day advance via TimeManager.
- Mail/events scheduled by scheduler.
- Weather impacts: crop watering, NPC schedules, lighting color.
- Festivals block time progression until completed.
