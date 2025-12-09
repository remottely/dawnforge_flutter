import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/gameplay/characters/player/new/game_player.dart';
import 'package:darkness_dungeon/gameplay/characters/player/new/tool_type.dart';
import 'package:flutter/material.dart';

class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: BonfireWidget(
        // Apenas UM controlador (Joystick) para evitar conflitos/inversões
        playerControllers: [
          Joystick(
            directional: JoystickDirectional(),
            actions: [
              JoystickAction(
                actionId: 0,
                margin: const EdgeInsets.only(bottom: 50, right: 50),
                color: Colors.blue,
                size: 50,
                enableDirection: false,
              ),
              JoystickAction(
                actionId: 1,
                margin: const EdgeInsets.only(bottom: 50, right: 160),
                color: Colors.brown,
                size: 40,
                enableDirection: false,
              ),
              JoystickAction(
                actionId: 2,
                margin: const EdgeInsets.only(bottom: 120, right: 160),
                color: Colors.orange,
                size: 40,
                enableDirection: false,
              ),
              JoystickAction(
                actionId: 3,
                margin: const EdgeInsets.only(bottom: 190, right: 160),
                color: Colors.grey,
                size: 40,
                enableDirection: false,
              ),
              JoystickAction(
                actionId: 4,
                margin: const EdgeInsets.only(bottom: 260, right: 160),
                color: Colors.cyan,
                size: 40,
                enableDirection: false,
              ),
            ],
          ),
        ],

        map: WorldMapByTiled(WorldMapReader.fromAsset('tiled/map.json')),
        cameraConfig: CameraConfig(
          moveOnlyMapArea: true,
          zoom: getZoomFromMaxVisibleTile(context, 16, 32),
        ),
        onReady: (game) async {
          final player = await GamePlayer.create(
            position: Vector2(100, 100),
            initialTool: ToolType.pickaxe,
          );
          game.add(player);
        },
        overlayBuilderMap: {'toolBar': (context, game) => _ToolBar(game)},
        initialActiveOverlays: const ['toolBar'],
        backgroundColor: const Color(0xFF2C2C2C),
        debugMode: false,
        showCollisionArea: false,
      ),
    );
  }
}

class _ToolBar extends StatefulWidget {
  final BonfireGame game;

  const _ToolBar(this.game);

  @override
  State<_ToolBar> createState() => _ToolBarState();
}

class _ToolBarState extends State<_ToolBar> {
  GamePlayer? _player;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePlayer();
    });
  }

  void _updatePlayer() {
    if (mounted) {
      setState(() {
        _player = widget.game.player as GamePlayer?;
      });

      if (_player == null) {
        Future.delayed(const Duration(milliseconds: 100), _updatePlayer);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
        ),
        child: _player == null
            ? const SizedBox(
                width: 150,
                child: Text(
                  'Carregando...',
                  style: TextStyle(color: Colors.white),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _getToolIcon(_player!.currentTool),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Ferramenta',
                        style: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                      Text(
                        _getToolName(_player!.currentTool),
                        style: const TextStyle(
                          color: Colors.yellow,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _getToolIcon(ToolType tool) {
    String emoji;
    Color color;

    switch (tool) {
      case ToolType.pickaxe:
        emoji = '⛏️';
        color = Colors.brown;
        break;
      case ToolType.axe:
        emoji = '🪓';
        color = Colors.orange;
        break;
      case ToolType.shovel:
        emoji = '🥄';
        color = Colors.grey;
        break;
      case ToolType.wateringCan:
        emoji = '💧';
        color = Colors.cyan;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 24)),
    );
  }

  String _getToolName(ToolType tool) {
    switch (tool) {
      case ToolType.pickaxe:
        return 'Picareta';
      case ToolType.axe:
        return 'Machado';
      case ToolType.shovel:
        return 'Pá';
      case ToolType.wateringCan:
        return 'Regador';
    }
  }
}
