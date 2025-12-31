/// Sistema de Overlay de Mensagens Centralizado
/// 
/// Este sistema permite mostrar mensagens importantes centralizadas na tela do jogo.
/// 
/// ## Como Usar
/// 
/// ```dart
/// import 'package:darkness_dungeon/gameplay/core/modules/overlay/overlay_message_def.dart';
/// 
/// // Mostrar mensagem de aviso (laranja)
/// OverlayMessageDef.showNoStamina();
/// 
/// // Mostrar mensagem de erro (vermelho)
/// OverlayMessageService.instance.showError('Você morreu!');
/// 
/// // Mostrar mensagem de informação (azul)
/// OverlayMessageService.instance.showInfo('Item adicionado ao inventário');
/// 
/// // Mostrar mensagem de sucesso (verde)
/// OverlayMessageService.instance.showSuccess('Missão completa!');
/// 
/// // Com duração customizada
/// OverlayMessageService.instance.showWarning(
///   'Mensagem importante',
///   duration: Duration(seconds: 3),
/// );
/// ```
/// 
/// ## Tipos de Mensagem
/// 
/// - **Warning** (Aviso): Laranja com ícone de alerta
/// - **Error** (Erro): Vermelho com ícone de erro
/// - **Info** (Info): Azul com ícone de informação
/// - **Success** (Sucesso): Verde com ícone de check
/// 
/// ## Personalização
/// 
/// Para personalizar cores, ícones ou animações, edite:
/// - Cores: `overlay_message_widget.dart` -> `_getBackgroundColor()`
/// - Ícones: `overlay_message_widget.dart` -> `_getIcon()`
/// - Duração padrão: `overlay_message_service.dart` -> `OverlayMessage.duration`
/// 
/// ## Integrado automaticamente em:
/// 
/// - ✅ Ações de Farm (dig, water, seed, harvest) quando sem stamina
/// - ✅ Ações de Combat (primary attack, ranged attack) quando sem stamina
/// 
/// ## Adicionar em novos locais:
/// 
/// Basta importar o service e chamar o método apropriado quando necessário:
/// 
/// ```dart
/// import 'package:darkness_dungeon/gameplay/core/modules/overlay/overlay_message_def.dart';
/// 
/// void tentarAbrirPorta() {
///   if (!playerTemChave) {
///     OverlayMessageService.instance.showWarning('Você precisa de uma chave!');
///     return;
///   }
///   // ... código para abrir porta
/// }
/// ```
library overlay_message_system;
