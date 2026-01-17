hj eu possuo o meu jogo da seguinte maneira. o "interface: gameplayHUD" ficou deprecated pois estava ficando muito complexo trabalhar com a camada de GUI/HUD/Interface/Overlay(como quiser chamar) no jogo. Então eu deleguei 100% da GUI do meu jogo para GlobalStateOverlay, e ele controla toda a camada de GUI do meu jogo por inteiro, desde HUD até Menus, market, etc, qualquer coisa que não seja nativamente do estado do gameworld. porem eu percebi que quando adiciono essas GUI, o comportamento dos inputs:
 return Stack(
          children: [
            BonfireWidget(
              key: ValueKey(mapItem.id),
              onReady: (gameRef) {
                GlobalStateMachine.instance.initialize(gameRef);
                TimeManager.instance.start();
              },
              // onDispose: () {
              //   GlobalStateMachine.instance.dispose();
              //   TimeManager.instance.stop();
              // },
              playerControllers: [playerInput],
              player: player,
              map: mapItem.map,
              components: [
                gameplayGameStateManager,
                inventoryInputHandler,
                shieldDefenseInputHandler,
                farmInputHandler,
                globalInputHandler,
              ],
              hudComponents: const [],
              // interface: gameplayHUD,
              lightingColorGame: mapLightingColor,
              overlayBuilderMap: const {},
              backgroundColor: const Color(0xFF000000),
              cameraConfig: getCameraConfig(gameplayContext),
              debugMode: AppEnvironment.kIsDebugMode,
              showCollisionArea: AppEnvironment.kShowCollisionArea,
            ),

            GlobalStateOverlay(player: player, playerInput: playerInput),
          ],
        );