import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:darkness_dungeon/new/pickaxe_controller_mixin.dart';

/// Tipos de ataque suportados
enum AttackType {
  melee, // Ataque corpo a corpo
  ranged, // Ataque à distância
  special, // Ataque especial
  combo, // Ataque em combo
}

/// Informações de execução de um ataque
class AttackExecutionInfo {
  final AttackType type;
  final DateTime executionTime;
  final Duration cooldownDuration;
  final Duration animationDuration;
  final int playerLevel;
  final Map<String, AttackSpeedModifier> activeModifiers;

  AttackExecutionInfo({
    required this.type,
    required this.executionTime,
    required this.cooldownDuration,
    required this.animationDuration,
    required this.playerLevel,
    required this.activeModifiers,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'executionTime': executionTime.toIso8601String(),
      'cooldownDurationMs': cooldownDuration.inMilliseconds,
      'animationDurationMs': animationDuration.inMilliseconds,
      'playerLevel': playerLevel,
      'activeModifiers': activeModifiers.keys.toList(),
    };
  }
}

/// Durações calculadas para um ataque
class AttackDurations {
  final Duration cooldown;
  final Duration animation;

  AttackDurations({required this.cooldown, required this.animation});
}

/// Modificador temporário de velocidade de ataque
class AttackSpeedModifier {
  final String name;
  final double
  speedMultiplier; // 1.0 = normal, 0.5 = 50% mais rápido, 2.0 = 50% mais lento
  final String description;
  final DateTime appliedAt;
  final Duration? duration;

  AttackSpeedModifier({
    required this.name,
    required this.speedMultiplier,
    this.description = '',
    required this.appliedAt,
    this.duration,
  });

  bool get isExpired {
    if (duration == null) return false;
    return DateTime.now().difference(appliedAt) >= duration!;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'speedMultiplier': speedMultiplier,
      'description': description,
      'appliedAt': appliedAt.toIso8601String(),
      'durationMs': duration?.inMilliseconds,
      'isExpired': isExpired,
    };
  }
}

/// Configuração para o sistema sincronizado de ataque
class SynchronizedAttackConfig {
  final int baseAttackSpeedMs;
  final String? pickaxeSpritePath;
  final Map<AttackType, double>? attackTypeMultipliers;
  final double speedBonusPerLevel;
  final bool enableVisualFeedback;
  final bool enableDebugLogging;

  SynchronizedAttackConfig({
    required this.baseAttackSpeedMs,
    this.pickaxeSpritePath,
    this.attackTypeMultipliers,
    this.speedBonusPerLevel = 0.05,
    this.enableVisualFeedback = true,
    this.enableDebugLogging = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'baseAttackSpeedMs': baseAttackSpeedMs,
      'pickaxeSpritePath': pickaxeSpritePath,
      'attackTypeMultipliers': attackTypeMultipliers?.map(
        (k, v) => MapEntry(k.name, v),
      ),
      'speedBonusPerLevel': speedBonusPerLevel,
      'enableVisualFeedback': enableVisualFeedback,
      'enableDebugLogging': enableDebugLogging,
    };
  }
}

/// Mixin que integra perfeitamente o sistema de velocidade de ataque
/// com o controle da picareta, garantindo sincronização total entre
/// cooldowns, animações e feedback visual.
///
/// Este mixin substitui tanto ActionRateLimiter quanto oferece
/// funcionalidades avançadas de controle de velocidade de ataque
/// sincronizado com animações.
///
/// Funcionalidades integradas:
/// - Sincronização automática de animações
/// - Evolução de velocidade por nível
/// - Buffs/debuffs temporários
/// - Feedback visual coordenado
/// - Sistema de logging unificado
/// - Compatibilidade com sistema antigo
///
/// Exemplo de uso:
/// ```dart
/// class Knight extends SimplePlayer
///     with PickaxeControllerMixin, SynchronizedAttackSystem {
///
///   @override
///   void onMount() {
///     super.onMount();
///     initializeIntegratedAttackSystem(
///       baseAttackSpeedMs: 800,
///       pickaxeSpritePath: 'items/my_pickaxe.png',
///     );
///   }
///
///   void atacar() {
///     executeSynchronizedAttack(AttackType.melee, () {
///       // Sua lógica de ataque aqui
///       performMeleeAttack();
///     });
///   }
/// }
/// ```
mixin SynchronizedAttackSystem on SimplePlayer, PickaxeControllerMixin {
  // ═══════════════════════════════════════════════════════════════════════════
  // 🎛️ CONFIGURAÇÕES BASE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Velocidade base de ataque em milissegundos (padrão: 800ms)
  int _baseAttackSpeedMs = 800;

  /// Multiplicadores por tipo de ataque
  Map<AttackType, double> _attackTypeMultipliers = {
    AttackType.melee: 1.0, // Ataque corpo a corpo normal
    AttackType.ranged: 0.8, // Ataque à distância mais rápido
    AttackType.special: 1.5, // Ataques especiais mais lentos
    AttackType.combo: 0.6, // Combos mais rápidos
  };

  // ═══════════════════════════════════════════════════════════════════════════
  // 🚀 SISTEMA DE EVOLUÇÃO
  // ═══════════════════════════════════════════════════════════════════════════

  /// Nível atual do jogador (afeta velocidade de ataque)
  int _playerLevel = 1;

  /// Velocidade de ataque adicional por nível (em %)
  double _speedBonusPerLevel = 0.05; // 5% mais rápido por nível

  /// Buffs/debuffs temporários de velocidade
  Map<String, AttackSpeedModifier> _temporaryModifiers = {};

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔒 ESTADO INTERNO
  // ═══════════════════════════════════════════════════════════════════════════

  // Timer para controlar o rate limiting
  async.Timer? _attackCooldownTimer;

  // Flag para indicar se pode atacar
  bool _canAttack = true;

  // Último ataque realizado (para debugging)
  AttackExecutionInfo? _lastAttackInfo;

  // Callbacks para eventos
  void Function(AttackExecutionInfo info)? _onAttackExecutedCallback;
  void Function(String attackType, Duration remainingCooldown)?
  _onAttackBlockedCallback;
  void Function(AttackExecutionInfo info)? _onAnimationSyncCallback;

  /// Flag para indicar se o sistema foi inicializado
  bool _systemInitialized = false;

  /// Configurações do sistema integrado
  late SynchronizedAttackConfig _config;

  // ═══════════════════════════════════════════════════════════════════════════
  // 🚀 INICIALIZAÇÃO INTEGRADA
  // ═══════════════════════════════════════════════════════════════════════════

  /// Inicializa o sistema integrado de ataque e animação
  Future<void> initializeIntegratedAttackSystem({
    required int baseAttackSpeedMs,
    String? pickaxeSpritePath,
    Map<AttackType, double>? attackTypeMultipliers,
    double speedBonusPerLevel = 0.05,
    bool enableVisualFeedback = true,
    bool enableDebugLogging = false,
  }) async {
    if (_systemInitialized) {
      throw Exception('SynchronizedAttackSystem already initialized');
    }

    // Salva configuração
    _config = SynchronizedAttackConfig(
      baseAttackSpeedMs: baseAttackSpeedMs,
      pickaxeSpritePath: pickaxeSpritePath,
      attackTypeMultipliers: attackTypeMultipliers,
      speedBonusPerLevel: speedBonusPerLevel,
      enableVisualFeedback: enableVisualFeedback,
      enableDebugLogging: enableDebugLogging,
    );

    try {
      // 1. Configura sistema de velocidade
      _setupAttackSpeed(
        baseAttackSpeedMs: baseAttackSpeedMs,
        attackTypeMultipliers: attackTypeMultipliers,
        speedBonusPerLevel: speedBonusPerLevel,
      );

      // 2. Inicializa picareta se especificado
      if (pickaxeSpritePath != null) {
        await initializePickaxe(spritePath: pickaxeSpritePath);
      }

      // 3. Configura callbacks de sincronização
      _setupSynchronizationCallbacks();

      _systemInitialized = true;

      if (_config.enableDebugLogging) {
        print('🎯 SynchronizedAttackSystem: Successfully initialized');
      }
    } catch (e) {
      throw Exception('Failed to initialize SynchronizedAttackSystem: $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🎛️ CONFIGURAÇÃO INTERNA
  // ═══════════════════════════════════════════════════════════════════════════

  /// Configura o sistema de velocidade de ataque
  void _setupAttackSpeed({
    required int baseAttackSpeedMs,
    Map<AttackType, double>? attackTypeMultipliers,
    double speedBonusPerLevel = 0.05,
  }) {
    _baseAttackSpeedMs = baseAttackSpeedMs;

    if (attackTypeMultipliers != null) {
      _attackTypeMultipliers = Map.from(attackTypeMultipliers);
    }

    _speedBonusPerLevel = speedBonusPerLevel;

    _logSystemSetup();
  }

  /// Configura callbacks para sincronização perfeita
  void _setupSynchronizationCallbacks() {
    // Callback para sincronizar animação quando ataque é executado
    _onAnimationSyncCallback = (attackInfo) {
      // Sincroniza duração da animação da picareta
      if (isPickaxeReady) {
        animatePickaxeAttack(animationDuration: attackInfo.animationDuration);
      }

      // Log de sincronização se habilitado
      if (_config.enableDebugLogging) {
        print(
          '🎯 SynchronizedAttackSystem: Attack executed - ${attackInfo.type.name} '
          '(cooldown: ${attackInfo.cooldownDuration.inMilliseconds}ms, '
          'animation: ${attackInfo.animationDuration.inMilliseconds}ms)',
        );
      }
    };

    // Callback para feedback visual quando ataque é bloqueado
    if (_config.enableVisualFeedback) {
      _onAttackBlockedCallback = (attackTypeName, remainingCooldown) {
        // Feedback visual para ataque bloqueado (piscar vermelho na picareta)
        if (isPickaxeReady) {
          floatingPickaxe?.flashColor(
            const Color(0xFFFF4444),
            duration: const Duration(milliseconds: 150),
          );
        }

        if (_config.enableDebugLogging) {
          print(
            '🚫 SynchronizedAttackSystem: Attack blocked - $attackTypeName '
            '(remaining: ${remainingCooldown.inMilliseconds}ms)',
          );
        }
      };
    }

    // Callback para quando ataque é executado com sucesso
    if (_config.enableVisualFeedback) {
      _onAttackExecutedCallback = (attackInfo) {
        // Feedback visual positivo
        if (isPickaxeReady) {
          Color effectColor;
          switch (attackInfo.type) {
            case AttackType.melee:
              effectColor = const Color(0xFFFF8800); // Laranja para melee
              break;
            case AttackType.ranged:
              effectColor = const Color(0xFF4488FF); // Azul para ranged
              break;
            case AttackType.special:
              effectColor = const Color(0xFF8844FF); // Roxo para special
              break;
            case AttackType.combo:
              effectColor = const Color(0xFFFFFF44); // Amarelo para combo
              break;
          }

          floatingPickaxe?.flashColor(
            effectColor,
            duration: Duration(
              milliseconds: (attackInfo.animationDuration.inMilliseconds * 0.3)
                  .round(),
            ),
          );
        }
      };
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ⚔️ API UNIFICADA DE ATAQUE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Executa um ataque sincronizado (substitui executeActionIfAllowed)
  ///
  /// Este método coordena:
  /// - Rate limiting baseado na velocidade calculada
  /// - Animação da picareta com duração sincronizada
  /// - Callbacks de feedback visual
  /// - Logging integrado
  ///
  /// [attackType] - Tipo do ataque
  /// [attackAction] - Função a ser executada
  /// [visualEffectCallback] - Callback opcional para efeitos visuais adicionais
  bool executeSynchronizedAttack(
    AttackType attackType,
    void Function() attackAction, {
    void Function()? visualEffectCallback,
  }) {
    if (!_systemInitialized) {
      throw Exception(
        'SynchronizedAttackSystem not initialized. Call initializeIntegratedAttackSystem first.',
      );
    }

    // Verifica se pode atacar
    if (!_canAttack) {
      _handleBlockedAttack(attackType);
      return false;
    }

    // Calcula durações baseadas no sistema
    final calculatedDurations = _calculateAttackDurations(attackType);

    // Cria informações do ataque
    final attackInfo = AttackExecutionInfo(
      type: attackType,
      executionTime: DateTime.now(),
      cooldownDuration: calculatedDurations.cooldown,
      animationDuration: calculatedDurations.animation,
      playerLevel: _playerLevel,
      activeModifiers: Map.from(_temporaryModifiers),
    );

    // Executa o ataque
    _handleExecutedAttack(attackInfo);
    attackAction();

    // Executa callback de efeito visual adicional se fornecido
    visualEffectCallback?.call();

    // Chama callback para sincronização de animação
    _onAnimationSyncCallback?.call(attackInfo);

    // Chama callback de execução
    _onAttackExecutedCallback?.call(attackInfo);

    // Inicia cooldown
    _startAttackCooldown(calculatedDurations.cooldown);

    return true;
  }

  /// Método compatível com ActionRateLimiter (para facilitar migração)
  bool executeActionIfAllowed(String actionName, void Function() action) {
    // Mapeia string para AttackType
    AttackType attackType = _mapActionNameToType(actionName);

    return executeSynchronizedAttack(attackType, action);
  }

  /// Verifica se pode atacar (compatível com ActionRateLimiter)
  bool canPerformAction() => _canAttack;

  // ═══════════════════════════════════════════════════════════════════════════
  // 📊 EVOLUÇÃO E CONFIGURAÇÃO DINÂMICA
  // ═══════════════════════════════════════════════════════════════════════════

  /// Atualiza o nível do jogador e recalcula velocidades
  void levelUp(int newLevel) {
    if (newLevel <= 0) return;

    int oldLevel = _playerLevel;
    _playerLevel = newLevel;

    if (_config.enableDebugLogging) {
      print(
        '📈 SynchronizedAttackSystem: Player leveled up from $oldLevel to $newLevel',
      );
    }
  }

  /// Adiciona buff temporário de velocidade
  void addAttackSpeedBuff(
    String buffName,
    double speedMultiplier, {
    Duration? duration,
    String description = '',
  }) {
    final modifier = AttackSpeedModifier(
      name: buffName,
      speedMultiplier: speedMultiplier,
      description: description,
      appliedAt: DateTime.now(),
      duration: duration,
    );

    _temporaryModifiers[buffName] = modifier;

    // Remove automaticamente após duração (se especificada)
    if (duration != null) {
      async.Timer(duration, () {
        removeAttackSpeedBuff(buffName);
      });
    }

    if (_config.enableDebugLogging) {
      print(
        '🎪 SynchronizedAttackSystem: Speed buff added: $buffName (${speedMultiplier}x)',
      );
    }
  }

  /// Remove buff de velocidade
  void removeAttackSpeedBuff(String buffName) {
    final removed = _temporaryModifiers.remove(buffName);

    if (removed != null && _config.enableDebugLogging) {
      print('🎪 SynchronizedAttackSystem: Speed buff removed: $buffName');
    }
  }

  /// Limpa todos os modificadores temporários
  void clearAllAttackSpeedBuffs() {
    final count = _temporaryModifiers.length;
    _temporaryModifiers.clear();

    if (_config.enableDebugLogging) {
      print(
        '🗑️ SynchronizedAttackSystem: All speed buffs cleared ($count removed)',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📈 INFORMAÇÕES E STATUS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Obtém informações completas do sistema
  Map<String, dynamic> getSynchronizedSystemStatus() {
    if (!_systemInitialized) {
      return {'initialized': false};
    }

    return {
      'initialized': true,
      'config': _config.toMap(),
      'canAttack': _canAttack,
      'playerLevel': _playerLevel,
      'baseAttackSpeedMs': _baseAttackSpeedMs,
      'speedBonusPerLevel': _speedBonusPerLevel,
      'lastAttack': _lastAttackInfo?.toMap(),
      'remainingCooldownMs': getRemainingCooldown().inMilliseconds,
      'cooldownProgress': getCooldownProgress(),
      'activeModifiers': _temporaryModifiers.map(
        (key, value) => MapEntry(key, value.toMap()),
      ),
      'attackTypeMultipliers': _attackTypeMultipliers.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'isTimerActive': _attackCooldownTimer?.isActive ?? false,
      'pickaxe': pickaxeDebugInfo,
      'currentSpeeds': {
        for (AttackType type in AttackType.values)
          type.name: {
            'attacksPerSecond': getCurrentAttackSpeed(type).toStringAsFixed(2),
            'cooldownMs': getCalculatedCooldown(type).inMilliseconds,
            'animationMs': getCalculatedAnimationDuration(type).inMilliseconds,
          },
      },
    };
  }

  /// Obtém velocidade de ataque atual para display na UI
  double getAttackSpeedForUI(AttackType attackType) {
    return getCurrentAttackSpeed(attackType);
  }

  /// Obtém tempo de cooldown atual para display na UI
  Duration getCooldownForUI(AttackType attackType) {
    return getCalculatedCooldown(attackType);
  }

  /// Obtém velocidade de ataque atual (ataques por segundo)
  double getCurrentAttackSpeed(AttackType attackType) {
    final cooldownMs = getCalculatedCooldown(attackType).inMilliseconds;
    return cooldownMs > 0 ? 1000.0 / cooldownMs : 0.0;
  }

  /// Obtém a duração calculada do cooldown para um tipo de ataque
  Duration getCalculatedCooldown(AttackType attackType) {
    return _calculateAttackDurations(attackType).cooldown;
  }

  /// Obtém a duração calculada da animação para um tipo de ataque
  Duration getCalculatedAnimationDuration(AttackType attackType) {
    return _calculateAttackDurations(attackType).animation;
  }

  /// Obtém tempo restante de cooldown
  Duration getRemainingCooldown() {
    if (_attackCooldownTimer?.isActive != true || _lastAttackInfo == null) {
      return Duration.zero;
    }

    final elapsed = DateTime.now().difference(_lastAttackInfo!.executionTime);
    final remaining = _lastAttackInfo!.cooldownDuration - elapsed;

    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Obtém porcentagem do cooldown completado (0.0 a 1.0)
  double getCooldownProgress() {
    if (_lastAttackInfo == null) return 1.0;

    final total = _lastAttackInfo!.cooldownDuration.inMilliseconds;
    final remaining = getRemainingCooldown().inMilliseconds;

    if (total == 0) return 1.0;

    final progress = (total - remaining) / total;
    return progress.clamp(0.0, 1.0);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔧 MÉTODOS INTERNOS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Calcula durações de cooldown e animação para um tipo de ataque
  AttackDurations _calculateAttackDurations(AttackType attackType) {
    // Multiplicador base por tipo de ataque
    final typeMultiplier = _attackTypeMultipliers[attackType] ?? 1.0;

    // Bonus de velocidade por nível (reduz o tempo)
    final levelSpeedBonus = 1.0 - (_speedBonusPerLevel * (_playerLevel - 1));

    // Multiplicador de modificadores temporários
    double tempModifierMultiplier = 1.0;
    for (final modifier in _temporaryModifiers.values) {
      tempModifierMultiplier *= modifier.speedMultiplier;
    }

    // Calcula duração final do cooldown
    final finalCooldownMs =
        (_baseAttackSpeedMs *
                typeMultiplier *
                levelSpeedBonus *
                tempModifierMultiplier)
            .round();
    final cooldownDuration = Duration(milliseconds: finalCooldownMs);

    // Animação é 80% do cooldown
    final animationDuration = Duration(
      milliseconds: (finalCooldownMs * 0.8).round(),
    );

    return AttackDurations(
      cooldown: cooldownDuration,
      animation: animationDuration,
    );
  }

  /// Inicia o cooldown após um ataque
  void _startAttackCooldown(Duration cooldownDuration) {
    _canAttack = false;

    // Cancela timer anterior se existir
    _attackCooldownTimer?.cancel();

    // Cria novo timer para liberar próximo ataque
    _attackCooldownTimer = async.Timer(cooldownDuration, () {
      _canAttack = true;
      _attackCooldownTimer = null;
    });
  }

  /// Manipula ataque executado
  void _handleExecutedAttack(AttackExecutionInfo attackInfo) {
    _lastAttackInfo = attackInfo;
    _logExecutedAttack(attackInfo);
  }

  /// Manipula ataque bloqueado
  void _handleBlockedAttack(AttackType attackType) {
    final remainingCooldown = getRemainingCooldown();
    _logBlockedAttack(attackType, remainingCooldown);
    _onAttackBlockedCallback?.call(attackType.name, remainingCooldown);
  }

  /// Mapeia nome de ação string para AttackType
  AttackType _mapActionNameToType(String actionName) {
    switch (actionName.toLowerCase()) {
      case 'melee_attack':
      case 'melee':
      case 'attack':
        return AttackType.melee;
      case 'range_attack':
      case 'ranged':
      case 'range':
        return AttackType.ranged;
      case 'special_attack':
      case 'special':
        return AttackType.special;
      case 'combo_attack':
      case 'combo':
        return AttackType.combo;
      default:
        return AttackType.melee; // Padrão
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📝 LOGGING E DEBUG
  // ═══════════════════════════════════════════════════════════════════════════

  void _logSystemSetup() {
    if (_config.enableDebugLogging) {
      print(
        '⚔️ SynchronizedAttackSystem: System setup - base: ${_baseAttackSpeedMs}ms, bonus/level: ${(_speedBonusPerLevel * 100).toStringAsFixed(1)}%',
      );
    }
  }

  void _logExecutedAttack(AttackExecutionInfo info) {
    if (_config.enableDebugLogging) {
      print(
        '⚔️ Attack EXECUTED: ${info.type.name} - cooldown: ${info.cooldownDuration.inMilliseconds}ms, animation: ${info.animationDuration.inMilliseconds}ms',
      );
    }
  }

  void _logBlockedAttack(AttackType attackType, Duration remainingCooldown) {
    if (_config.enableDebugLogging) {
      print(
        '🚫 Attack BLOCKED: ${attackType.name} - remaining: ${remainingCooldown.inMilliseconds}ms',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🗑️ CLEANUP
  // ═══════════════════════════════════════════════════════════════════════════

  /// Cleanup completo do sistema integrado
  void disposeSynchronizedAttackSystem() {
    if (_systemInitialized) {
      _attackCooldownTimer?.cancel();
      _attackCooldownTimer = null;
      _temporaryModifiers.clear();
      _onAttackExecutedCallback = null;
      _onAttackBlockedCallback = null;
      _onAnimationSyncCallback = null;
      disposePickaxe();
      _systemInitialized = false;

      if (_config.enableDebugLogging) {
        print('🗑️ SynchronizedAttackSystem: Disposed successfully');
      }
    }
  }
}
