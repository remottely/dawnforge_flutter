import 'package:dawnforge/core/utils/game_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:bonfire/bonfire.dart';

/// UI:
///    - HUD
///    - GUI
///    -
///    -
///    -
enum InterfaceType {
  // Camadas Base
  HUD, // Head-Up Display /// [ALL SCREEN]
  GUI, // Graphical User Interface /// [ALL SCREEN]
  UI, // User Interface /// [ANY SCREEN]
  // Tipos de Tela
  Menu, // Menu System
  Screen, // Full Screen UI /// [FULL SCREEN]
  Panel, // UI Panel /// [ANY SIZE]
  Window, // Window/Dialog /// [CENTER]
  Modal, // Modal Dialog /// [BOTTOM CENTER]
  Popup, // Popup Window /// [CENTER]
  // Overlays
  Overlay, // UI Overlay /// [ANY SIZE / ALL SCREEN]
  InGameOverlay, // In-Game Overlay /// [ANY SIZE / ALL SCREEN]
  SystemOverlay, // System Overlay /// [ANY SIZE / ALL SCREEN]
  DebugOverlay, // Debug Overlay /// [ANY SIZE / ALL SCREEN]
  // Widgets/Componentes
  Widget, // UI Widget /// [ANY SIZE]
  Element, // UI Element /// [ANY SIZE]
  Component, // UI Component /// [ANY SIZE]
  // Control, // UI Control
  // Feedback Visual
  // VFX, // Visual Effects
  // SFX, // Sound Effects (interface de áudio)
  Indicator, // Visual Indicator /// [ANY SIZE]
  Marker, // World Marker /// [ANY SIZE]
  // Reticle, // Crosshair/Reticle
  // Cursor, // Mouse Cursor
  // Informação
  Tooltip, // Tooltip
  // Label, // Text Label
  // Caption, // Caption
  // Subtitle, // Subtitle
  Notification, // Notification /// [TOP CENTER]
  Alert, // Alert Message /// [TOP CENTER]
  Banner, // Banner /// [TOP CENTER]
  // Navegação
  Navigator, // Navigation System /// [ANY LOCATION]
  Tab, // Tab Interface /// [ANY LOCATION?]
  Sidebar, // Sidebar /// [LEFT / RIGHT LOCATION]
  Toolbar, // Toolbar /// [TOP / BOTTOM LOCATION?]
  ActionBar, // Action Bar
  QuickBar, // Quick Access Bar
  Hotbar, // Hotbar (MMO)
  Radial, // Radial Menu
  // Específicos de Jogo
  Minimap, // Mini Map /// [TOP RIGHT / BOTTOM RIGHT]
  // Worldmap, // World Map
  // Compass, // Compass
  // Crosshair, // Crosshair
  // HealthBar, // Health Bar
  // Stamina, // Stamina Bar
  // Mana, // Mana Bar
  // XPBar, // Experience Bar
  // QuestTracker, // Quest Tracker
  // Inventory, // Inventory
  // Crafting, // Crafting Interface
  // Journal, // Journal/Log
  // Bestiary, // Bestiary
  // Codex, // Codex/Encyclopedia
  // Diálogos e Interação
  Dialog, // Dialog Box /// [CENTER]
  // Dialogue, // Conversation Dialog (UK spelling)
  Conversation, // Conversation System /// [BOTTOM CENTER]
  ChoiceDialog, // Choice Dialog /// [CENTER]
  Cutscene, // Cutscene UI /// [ALL SCREEN]
  Cinematic, // Cinematic UI /// [ALL SCREEN]
  // Sistema
  // Pause, // Pause Menu
  // Settings, // Settings Menu
  // Options, // Options Menu
  // SaveLoad, // Save/Load Screen
  MainMenu, // Main Menu /// [PRE GAME]
  // TitleScreen, // Title Screen
  LoadingScreen, // Loading Screen /// [FULL SCREEN]
  SplashScreen, // Splash Screen /// [FULL SCREEN]
  Credits, // Credits Screen /// [FULL SIZE]
  // // Feedback
  // DamageNumber, // Damage Number
  FloatingText, // Floating Text /// [ANY LOCATION]
  // CombatLog, // Combat Log
  ChatBox, // Chat Box /// [BOTTOM LEFT]
  // Console, // Debug Console
  // // Temporal
  Transition, // Transition Effect /// [FULL SCREEN]
  // Fade, // Fade Effect
  // Vignette, // Vignette Effect
  // ChromaticAberration, // Screen Effect
}

enum GlobalState {
  gameLoading,
  gameCutscene,
  gameTransitioning,
  gameplayResumed,
  gameplayResumedFishing,
  gameplayPaused,
  uiMenuInventory,
  uiMenuQuest,
  uiMenuMap,
  uiMenuSettings,
  uiMenuTutorial,
  uiOverlayCrafting,
  uiOverlayCooking,
  uiOverlayMarket,
  uiOverlayChoice,
  uiOverlayConversation,
  uiOverlayGameover,
}

final class GlobalStateMachine {
  GlobalStateMachine._();
  static final GlobalStateMachine instance = GlobalStateMachine._();

  // ✅ ÚNICA FONTE DA VERDADE
  final ValueNotifier<GlobalState> _rxCurrentState = ValueNotifier(
    // GlobalState.loading, // TODO(Kevin): NOW NOW - put it back
    GlobalState.gameplayResumed, // TODO(Kevin): NOW NOW - remove it
  );

  ValueNotifier<GlobalState> getRxCurrentState() => _rxCurrentState;
  GlobalState getCurrentState() => _rxCurrentState.value;

  GlobalState? _previousState;
  final List<GlobalState> _stateHistory = [];

  BonfireGameInterface? _gameRef;

  void initialize(BonfireGameInterface gameRef) {
    _gameRef = gameRef;
    GameLogger.info('[GlobalState] Initialized');
  }

  void dispose() {
    _rxCurrentState.dispose();
  }

  void _changeState(GlobalState newState) {
    if (_rxCurrentState.value == newState) {
      GameLogger.info('[GlobalState] Already in ${newState.name}');
      return;
    }

    GameLogger.info(
      '[GlobalState] ${_rxCurrentState.value.name} → ${newState.name}',
    );

    _previousState = _rxCurrentState.value;
    _stateHistory.add(_rxCurrentState.value);

    _onStateExit(_rxCurrentState.value);

    _rxCurrentState.value = newState;

    _onStateEnter(newState);
  }

  void _returnToPreviousState() {
    if (_previousState != null) {
      _changeState(_previousState!);
    } else {
      _changeState(GlobalState.gameplayResumed);
    }
  }

  void _onStateEnter(GlobalState state) {
    switch (state) {
      case GlobalState.gameplayResumed:
      case GlobalState.gameplayResumedFishing:
        _resumeEngine();
        break;
      default:
        _pauseEngine();
        break;
    }
  }

  void _onStateExit(GlobalState state) {
    switch (state) {
      case GlobalState.gameplayResumed:
      case GlobalState.gameplayResumedFishing:
        break;
      default:
        _resumeEngine();
        break;
    }
  }

  void _resumeEngine() {
    if (_gameRef != null) {
      _gameRef!.resumeEngine();
      GameLogger.info('[GlobalState] ▶️ Engine resumed');
    }
  }

  void _pauseEngine() {
    if (_gameRef != null) {
      _gameRef!.pauseEngine();
      GameLogger.info('[GlobalState] ⏸️ Engine paused');
    }
  }

  bool get isGameLoading => _rxCurrentState.value == GlobalState.gameLoading;
  bool get isGameCutscene => _rxCurrentState.value == GlobalState.gameCutscene;
  bool get isGameTransitioning =>
      _rxCurrentState.value == GlobalState.gameTransitioning;
  bool get isGameplayResumed =>
      _rxCurrentState.value == GlobalState.gameplayResumed;
  bool get isGameplayResumedFishing =>
      _rxCurrentState.value == GlobalState.gameplayResumedFishing;
  bool get isGameplayPaused =>
      _rxCurrentState.value == GlobalState.gameplayPaused;
  bool get isUiMenuInventory =>
      _rxCurrentState.value == GlobalState.uiMenuInventory;
  bool get isUiMenuQuest => _rxCurrentState.value == GlobalState.uiMenuQuest;
  bool get isUiMenuMap => _rxCurrentState.value == GlobalState.uiMenuMap;
  bool get isUiMenuSettings =>
      _rxCurrentState.value == GlobalState.uiMenuSettings;
  bool get isUiMenuTutorial =>
      _rxCurrentState.value == GlobalState.uiMenuTutorial;
  bool get isUiOverlayCrafting =>
      _rxCurrentState.value == GlobalState.uiOverlayCrafting;
  bool get isUiOverlayCooking =>
      _rxCurrentState.value == GlobalState.uiOverlayCooking;
  bool get isUiOverlayChoice =>
      _rxCurrentState.value == GlobalState.uiOverlayChoice;
  bool get isUiOverlayConversation =>
      _rxCurrentState.value == GlobalState.uiOverlayConversation;
  bool get isUiOverlayMarket =>
      _rxCurrentState.value == GlobalState.uiOverlayMarket;
  bool get isUiOverlayGameover =>
      _rxCurrentState.value == GlobalState.uiOverlayGameover;

  bool get isTimePlaying =>
      _rxCurrentState.value == GlobalState.gameplayResumed;
  bool get isTimePaused =>
      !(_rxCurrentState.value == GlobalState.gameplayResumed) &&
      !(_rxCurrentState.value == GlobalState.gameplayResumedFishing);

  // bool get canPlayerMove => isTimePlaying;

  // bool get canPlayerAttack => isTimePlaying;

  // bool get canPlayerInteract =>
  //     rxCurrentState.value == GlobalState.playing ||
  //     rxCurrentState.value == GlobalState.conversation;

  // bool get canOpenInventory =>
  //     rxCurrentState.value == GlobalState.playing ||
  //     rxCurrentState.value == GlobalState.pausedInPlayingMode;

  bool get shouldShowHUD => isTimePlaying;

  // bool get shouldPauseGameLogic =>
  //     rxCurrentState.value == GlobalState.pausedInPlayingMode ||
  //     rxCurrentState.value == GlobalState.inventory ||
  //     rxCurrentState.value == GlobalState.uiOverlayMarket ||
  //     rxCurrentState.value == GlobalState.map ||
  //     rxCurrentState.value == GlobalState.settings;

  // bool shouldShowOverlay(GlobalState state) => rxCurrentState.value == state;

  void openUiMenuInventory() => _changeState(GlobalState.uiMenuInventory);
  void closeUiMenuInventory() => _changeState(GlobalState.gameplayResumed);

  void openMarket() => _changeState(GlobalState.uiOverlayMarket);
  void closeMarket() => _changeState(GlobalState.gameplayResumed);

  void startConversation() => _changeState(GlobalState.uiOverlayConversation);
  void endConversation() => _changeState(GlobalState.gameplayResumed);

  void pauseGameplay() => _changeState(GlobalState.gameplayPaused);
  void resumeGameplay() => _changeState(GlobalState.gameplayResumed);

  void openQuest() => _changeState(GlobalState.uiMenuQuest);
  void closeQuest() => _changeState(GlobalState.gameplayResumed);

  void openMap() => _changeState(GlobalState.uiMenuMap);
  void closeMap() => _changeState(GlobalState.gameplayResumed);

  void openSettings() => _changeState(GlobalState.uiMenuSettings);
  void closeSettings() => _returnToPreviousState();

  void openUiMenuTutorial() => _changeState(GlobalState.uiMenuTutorial);
  void closeUiMenuTutorial() => _changeState(GlobalState.gameplayResumed);

  void openCrafting() => _changeState(GlobalState.uiOverlayCrafting);
  void closeCrafting() => _changeState(GlobalState.gameplayResumed);

  void openCooking() => _changeState(GlobalState.uiOverlayCooking);
  void closeCooking() => _changeState(GlobalState.gameplayResumed);

  void printStateHistory() {
    GameLogger.info(
      '[GlobalState] History: ${_stateHistory.map((s) => s.name).join(" → ")}',
    );
  }
}
