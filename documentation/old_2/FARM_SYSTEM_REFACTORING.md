# Farm System Refactoring

## Overview

The farm system has been refactored from a monolithic component to a professional, layered architecture following Clean Architecture principles and SOLID design patterns.

## Architecture

### Before (Monolithic)

```
farm_interaction_component.dart (216 lines)
├── Input handling
├── Business logic
├── UI feedback
└── Save integration
```

**Problems:**

- Mixed responsibilities (SRP violation)
- Hard to test
- Hard to maintain
- Tight coupling

### After (Layered)

```
farm/
├── constants/
│   ├── farm_input_constants.dart   # Keyboard mappings
│   └── farm_messages.dart          # User messages
├── services/
│   ├── farm_action_service.dart    # Business logic
│   └── farm_feedback_service.dart  # UI feedback
├── handlers/
│   └── farm_input_handler.dart     # Input routing
└── components/
    └── farm_interaction_component.dart  # Legacy wrapper (deprecated)
```

**Benefits:**

- ✅ Single Responsibility Principle
- ✅ Dependency Inversion Principle
- ✅ Easy to test (mockable services)
- ✅ Easy to maintain (small, focused files)
- ✅ Easy to extend (just add methods to services)

## Layer Responsibilities

### 1. Constants Layer

**Purpose:** Configuration and messages
**Files:** `farm_input_constants.dart`, `farm_messages.dart`

**Responsibilities:**

- Define keyboard key mappings
- Define user-facing messages
- Provide single source of truth for configuration

**Example:**

```dart
class FarmInputConstants {
  static const kTillSoilKey = LogicalKeyboardKey.keyH;
  static const kWaterKey = LogicalKeyboardKey.keyJ;
  // ...
}

class FarmMessages {
  static const kSoilTilled = 'Terra Arada!';
  static const kCropWatered = 'Regado!';

  static String cropHarvested(int amount, String cropName) =>
    'Colhido ${amount}x $cropName!';
}
```

### 2. Services Layer

**Purpose:** Business logic and coordination
**Files:** `farm_action_service.dart`, `farm_feedback_service.dart`

**Responsibilities:**

- Execute farm actions (till, water, plant, harvest)
- Coordinate between FarmManager and InventoryManager
- Provide UI feedback (floating text, HUD updates)
- Return typed results for error handling

**Example:**

```dart
// Business logic
final result = FarmActionService.instance.harvestCrop(x, y);
if (result.success && result.crop != null) {
  // Handle success
}

// UI feedback
FarmFeedbackService.instance.showFloatingText('Success!');
FarmFeedbackService.instance.refreshInventoryHUD(gameRef);
```

### 3. Handlers Layer

**Purpose:** Input routing
**Files:** `farm_input_handler.dart`

**Responsibilities:**

- Listen to keyboard events
- Route inputs to appropriate service methods
- Handle debug commands (advance day, clear save)
- Provide clear separation between input and logic

**Example:**

```dart
class FarmInputHandler extends GameComponent with KeyboardEventListener {
  @override
  bool onKeyboard(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Route to service
    final result = _actionService.tillSoil(x, y);
    if (result.success) {
      _feedbackService.showFloatingText(FarmMessages.kSoilTilled);
    }
    return true;
  }
}
```

### 4. Components Layer (Legacy)

**Purpose:** Backward compatibility
**Files:** `farm_interaction_component.dart`

**Status:** Deprecated
**Migration:** Use `FarmInputHandler` directly

## Data Flow

```
Keyboard Input
    ↓
FarmInputHandler (routing)
    ↓
FarmActionService (business logic)
    ↓
FarmManager + InventoryManager (state)
    ↓
FarmFeedbackService (UI feedback)
    ↓
User sees result
```

## Result Classes

### FarmActionResult

```dart
class FarmActionResult {
  final bool success;
  final String? errorMessage;
}
```

### HarvestResult

```dart
class HarvestResult extends FarmActionResult {
  final Crop? crop;
  final bool addedToInventory;
}
```

**Benefits:**

- Type-safe returns
- Clear success/failure handling
- Rich error information
- Enables proper error handling in UI

## Testing Strategy

### Unit Tests (Easy with new structure)

```dart
// Test business logic in isolation
test('tillSoil should succeed on untilled land', () {
  final result = FarmActionService.instance.tillSoil(0, 0);
  expect(result.success, true);
});

// Mock services for handler tests
test('handler routes till action correctly', () {
  final mockService = MockFarmActionService();
  final handler = FarmInputHandler(player: player, service: mockService);

  handler.onKeyboard(/* H key event */);

  verify(mockService.tillSoil(any, any)).called(1);
});
```

### Integration Tests

```dart
testWidgets('harvesting updates inventory', (tester) async {
  // Plant crop, wait for growth, harvest
  // Verify inventory contains items
  // Verify HUD updates correctly
});
```

## Migration Guide

### For Existing Code

**Old:**

```dart
player.add(FarmInteractionComponent(player: player));
```

**New:**

```dart
player.add(FarmInputHandler(player: player));
```

### For New Features

**Adding a new farm action:**

1. **Add constant** (if new key):

```dart
// farm_input_constants.dart
static const kNewActionKey = LogicalKeyboardKey.keyU;
```

2. **Add message**:

```dart
// farm_messages.dart
static const kNewActionSuccess = 'Action completed!';
```

3. **Add service method**:

```dart
// farm_action_service.dart
FarmActionResult performNewAction(int x, int y) {
  // Business logic here
  return FarmActionResult(success: true);
}
```

4. **Add handler routing**:

```dart
// farm_input_handler.dart
if (key == FarmInputConstants.kNewActionKey) {
  return _handleNewAction(x, y);
}

bool _handleNewAction(int x, int y) {
  final result = _actionService.performNewAction(x, y);
  if (result.success) {
    _feedbackService.showFloatingText(FarmMessages.kNewActionSuccess);
  }
  return true;
}
```

## Future Improvements

### Short Term

- [ ] Implement actual floating text visual
- [ ] Add sound effects (methods already stubbed in FarmFeedbackService)
- [ ] Add crop selection UI for planting
- [ ] Add visual feedback for watered tiles

### Medium Term

- [ ] Add unit tests for all service methods
- [ ] Add integration tests for complete workflows
- [ ] Implement i18n support (messages already centralized)
- [ ] Add undo/redo system for farm actions

### Long Term

- [ ] Add multiplayer support (services already stateless)
- [ ] Add analytics tracking for farm actions
- [ ] Add achievements system
- [ ] Add tutorial system

## Keyboard Reference

| Key | Action              | Service Method                          |
| --- | ------------------- | --------------------------------------- |
| H   | Till soil           | `tillSoil(x, y)`                        |
| J   | Water crop          | `waterTile(x, y)`                       |
| K   | Plant seed          | `plantSeed(x, y, cropId)`               |
| R   | Harvest crop        | `harvestCrop(x, y)`                     |
| N   | Advance day (debug) | `WorldStateManager.advanceDay()`        |
| G   | Clear save (debug)  | `GameSaveController.clearGameAndSave()` |

## Dependencies

```
FarmInputHandler
  ├── FarmActionService
  │     ├── FarmManager (state)
  │     └── InventoryManager (state)
  └── FarmFeedbackService
        └── HUDView (UI)
```

## File Sizes (After Refactoring)

| File                              | Lines | Responsibility |
| --------------------------------- | ----- | -------------- |
| `farm_input_constants.dart`       | 25    | Configuration  |
| `farm_messages.dart`              | 40    | Messages       |
| `farm_action_service.dart`        | 150   | Business logic |
| `farm_feedback_service.dart`      | 70    | UI feedback    |
| `farm_input_handler.dart`         | 180   | Input routing  |
| `farm_interaction_component.dart` | 20    | Legacy wrapper |

**Total:** ~485 lines (well-organized, testable)
**Before:** 216 lines (monolithic, hard to test)

**Trade-off:** More files, but each is focused and maintainable.

## Conclusion

This refactoring transforms the farm system from a maintenance burden into a professional, extensible codebase that follows industry best practices. The new structure makes it easy to:

- Add new features
- Write tests
- Fix bugs
- Onboard new developers
- Scale the system

The investment in proper architecture pays dividends in long-term maintainability.
