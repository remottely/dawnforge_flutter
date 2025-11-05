import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/new/floating_pickaxe.dart';

/// Mixin responsável por controlar a direção e comportamento da picareta
/// Reutilizável em qualquer SimplePlayer que precise de uma picareta flutuante
mixin PickaxeControllerMixin on SimplePlayer {
  FloatingPickaxe? _floatingPickaxe;
  bool _facingRight = true;

  /// Getter para acessar a picareta (read-only)
  FloatingPickaxe? get floatingPickaxe => _floatingPickaxe;

  /// Getter para verificar direção atual
  bool get isPickaxeFacingRight => _facingRight;

  /// Inicializa a picareta flutuante
  Future<void> initializePickaxe({
    String spritePath = 'gameplay/characters/weapons/SolarPoweredHammer.png',
  }) async {
    try {
      _floatingPickaxe = await FloatingPickaxe.create(
        knight: this,
        spritePath: spritePath,
      );
      gameRef.add(_floatingPickaxe!);
      _facingRight = true; // Inicializa virado para direita
    } catch (e) {
      throw Exception('Failed to initialize pickaxe: $e');
    }
  }

  /// Atualiza a direção da picareta baseada na velocidade (input intention)
  void updatePickaxeDirection() {
    if (_floatingPickaxe == null) return;

    final currentVelocity = velocity;

    // Se há movimento horizontal significativo, atualiza a direção
    if (currentVelocity.x.abs() > 1.0) {
      final shouldFaceRight = currentVelocity.x > 0;

      // Só atualiza se a direção mudou
      if (shouldFaceRight != _facingRight) {
        _facingRight = shouldFaceRight;
        _floatingPickaxe!.setDirection(facingRight: _facingRight);
      }
    }
  }

  /// Define manualmente a direção da picareta
  void setPickaxeDirection({required bool facingRight}) {
    _facingRight = facingRight;
    _floatingPickaxe?.setDirection(facingRight: facingRight);
  }

  /// Inicia animação de ataque da picareta com validação robusta
  /// [animationDuration] - Duração customizada da animação (sincronizada com AttackSpeedController)
  void animatePickaxeAttack({Duration? animationDuration}) {
    if (_floatingPickaxe == null) {
      return;
    }

    if (_floatingPickaxe!.isAttacking) {
      return;
    }

    _floatingPickaxe!.startAttackAnimation(customDuration: animationDuration);
  }

  /// Atualiza a duração da animação da picareta (para sincronização com sistema de velocidade)
  void updatePickaxeAnimationDuration(Duration newDuration) {
    _floatingPickaxe?.updateAnimationDuration(newDuration);
  }

  /// Obtém a duração atual da animação da picareta
  Duration? get currentPickaxeAnimationDuration =>
      _floatingPickaxe?.currentAnimationDuration;

  /// Verifica se a picareta está disponível e funcionando
  bool get isPickaxeReady =>
      _floatingPickaxe != null && !_floatingPickaxe!.isRemoved;

  /// Força reinicialização da picareta se necessário
  Future<void> ensurePickaxeAvailable({String? spritePath}) async {
    if (!isPickaxeReady) {
      await initializePickaxe(
        spritePath:
            spritePath ?? 'gameplay/characters/weapons/SolarPoweredHammer.png',
      );
    }
  }

  /// Debug: Informações sobre o estado da picareta
  Map<String, dynamic> get pickaxeDebugInfo => {
    'exists': _floatingPickaxe != null,
    'isRemoved': _floatingPickaxe?.isRemoved ?? 'N/A',
    'isAttacking': _floatingPickaxe?.isAttacking ?? 'N/A',
    'direction': _facingRight ? 'right' : 'left',
    'ready': isPickaxeReady,
  };

  /// Limpa recursos da picareta
  void disposePickaxe() {
    _floatingPickaxe?.removeFromParent();
    _floatingPickaxe = null;
  }
}
