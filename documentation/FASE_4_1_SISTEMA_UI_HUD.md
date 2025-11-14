# 🎯 FASE 4.1 - Sistema de UI e HUD

> **Objetivo:** Implementar interface de usuário completa (HUD, inventário, menus)
>
> **Prioridade:** 🔴 CRÍTICO (Jogabilidade)
>
> **Tempo Estimado:** 4-5 dias
>
> **Dependências:** Todas as fases anteriores (1.1-3.2)

---

## 📋 Estrutura Final

```
lib/gameplay/ui/
├── hud/
│   ├── hud_overlay.dart              ✅ Overlay principal do HUD
│   ├── health_bar.dart               ✅ Barra de HP
│   ├── stamina_bar.dart              ✅ Barra de stamina
│   ├── hotbar.dart                   ✅ Barra de atalhos
│   └── minimap.dart                  ✅ Minimapa
├── inventory/
│   ├── inventory_screen.dart         ✅ Tela de inventário
│   ├── inventory_grid.dart           ✅ Grid de slots
│   ├── item_tooltip.dart             ✅ Tooltip de item
│   └── equipment_panel.dart          ✅ Painel de equipamentos
├── menus/
│   ├── main_menu.dart                ✅ Menu principal
│   ├── pause_menu.dart               ✅ Menu de pausa
│   ├── settings_menu.dart            ✅ Menu de configurações
│   └── crafting_menu.dart            ✅ Menu de crafting
└── widgets/
    ├── custom_button.dart            ✅ Botão customizado
    ├── dialog_box.dart               ✅ Caixa de diálogo
    └── progress_bar.dart             ✅ Barra de progresso

assets/ui/
├── buttons/                          ✅ Sprites de botões
├── panels/                           ✅ Sprites de painéis
└── icons/                            ✅ Ícones
```

---

## 🚀 PROMPT 1: Criar HUD Overlay Principal

### Contexto

O HUD é a interface principal que mostra informações do player (HP, stamina, hotbar) durante o gameplay.

### Prompt para o Claude

````
Crie o HUD overlay principal:

ARQUIVO: lib/gameplay/ui/hud/hud_overlay.dart

REQUISITOS DO HUD:

1. Estrutura do Overlay:
   - Widget estático sobreposto ao jogo
   - Responsive (funciona em diferentes resoluções)
   - Não bloqueia input do jogo

2. Componentes Principais:
   - HealthBar (canto superior esquerdo)
   - StaminaBar (abaixo da health bar)
   - Hotbar (parte inferior central)
   - Minimap (canto superior direito)
   - Dia/Hora (canto superior direito)
   - Moedas (canto superior esquerdo)

3. Estado Reativo:
   - Atualizar quando player toma dano
   - Atualizar quando stamina muda
   - Atualizar quando hotbar muda

4. Animações:
   - Fade in/out
   - Shake ao tomar dano
   - Pulse ao coletar item

PADRÃO DE CÓDIGO:
```dart
class HUDOverlay extends StatefulWidget {
  final Player player;

  const HUDOverlay({
    super.key,
    required this.player,
  });

  @override
  State<HUDOverlay> createState() => _HUDOverlayState();
}

class _HUDOverlayState extends State<HUDOverlay> {
  @override
  void initState() {
    super.initState();

    // Escutar mudanças no player
    widget.player.addListener(_onPlayerChanged);
  }

  @override
  void dispose() {
    widget.player.removeListener(_onPlayerChanged);
    super.dispose();
  }

  void _onPlayerChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Canto superior esquerdo
        Positioned(
          top: 20,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HealthBar(
                current: widget.player.stats.currentHealth,
                max: widget.player.stats.maxHealth,
              ),
              SizedBox(height: 8),
              StaminaBar(
                current: widget.player.stamina.current,
                max: widget.player.stamina.max,
              ),
              SizedBox(height: 16),
              _buildCoinDisplay(),
            ],
          ),
        ),

        // Canto superior direito
        Positioned(
          top: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTimeDisplay(),
              SizedBox(height: 16),
              Minimap(),
            ],
          ),
        ),

        // Parte inferior central
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Hotbar(
              slots: widget.player.hotbarSlots,
              selectedIndex: widget.player.selectedHotbarIndex,
              onSlotSelected: _onHotbarSlotSelected,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCoinDisplay() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.monetization_on, color: Colors.amber, size: 20),
          SizedBox(width: 8),
          Text(
            '${widget.player.coins}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay() {
    final timeManager = TimeManager.instance;
    final worldManager = WorldStateManager.instance;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Day ${worldManager.currentDay}',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          Text(
            _formatTime(timeManager.currentTime),
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatTime(double timeInSeconds) {
    final hours = (timeInSeconds / 3600).floor();
    final minutes = ((timeInSeconds % 3600) / 60).floor();
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  void _onHotbarSlotSelected(int index) {
    // Selecionar slot da hotbar
    widget.player.selectHotbarSlot(index);
  }
}
````

CHECKLIST DE VALIDAÇÃO:
[ ] HUD renderiza corretamente
[ ] Componentes posicionados corretamente
[ ] Estado atualiza em tempo real
[ ] Responsive em diferentes resoluções
[ ] Não bloqueia input do jogo

### Critérios de Aceitação

- [ ] HUD funcional
- [ ] Todos os componentes visíveis
- [ ] Atualizações em tempo real
- [ ] Performance adequada (60 FPS)
- [ ] Design consistente

```

---

## 🚀 PROMPT 2: Criar Componentes de Barras

### Contexto
Criar componentes reutilizáveis para barras de HP, stamina e outras métricas.

### Prompt para o Claude

```

Crie componentes de barras:

ARQUIVO 1: lib/gameplay/ui/hud/health_bar.dart

```dart
class HealthBar extends StatelessWidget {
  final int current;
  final int max;
  final double width;
  final double height;

  const HealthBar({
    super.key,
    required this.current,
    required this.max,
    this.width = 200,
    this.height = 24,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (current / max).clamp(0.0, 1.0);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Stack(
        children: [
          // Barra de fundo (vazio)
          Container(
            decoration: BoxDecoration(
              color: Colors.red.shade900,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Barra de preenchimento (HP atual)
          FractionallySizedBox(
            widthFactor: percent,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getHealthColors(percent),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Texto
          Center(
            child: Text(
              '$current / $max',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(color: Colors.black, blurRadius: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getHealthColors(double percent) {
    if (percent > 0.5) {
      return [Colors.green.shade600, Colors.green.shade400];
    } else if (percent > 0.25) {
      return [Colors.orange.shade600, Colors.orange.shade400];
    } else {
      return [Colors.red.shade600, Colors.red.shade400];
    }
  }
}
```

ARQUIVO 2: lib/gameplay/ui/hud/stamina_bar.dart

```dart
class StaminaBar extends StatelessWidget {
  final double current;
  final double max;
  final double width;
  final double height;

  const StaminaBar({
    super.key,
    required this.current,
    required this.max,
    this.width = 200,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (current / max).clamp(0.0, 1.0);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Stack(
        children: [
          // Barra de fundo
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade900,
              borderRadius: BorderRadius.circular(6),
            ),
          ),

          // Barra de preenchimento
          FractionallySizedBox(
            widthFactor: percent,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.yellow.shade600, Colors.yellow.shade400],
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

ARQUIVO 3: lib/gameplay/ui/widgets/progress_bar.dart (genérico)

```dart
class ProgressBar extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final Color color;
  final Color backgroundColor;
  final double width;
  final double height;
  final String? label;

  const ProgressBar({
    super.key,
    required this.progress,
    this.color = Colors.blue,
    this.backgroundColor = Colors.grey,
    this.width = 100,
    this.height = 20,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(color: Colors.white24),
      ),
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
          if (label != null)
            Center(
              child: Text(
                label!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] Barras renderizam corretamente
[ ] Cores mudam baseado em porcentagem
[ ] Texto legível
[ ] Animações suaves
[ ] Componente genérico reutilizável

### Critérios de Aceitação

- [ ] Barras funcionais
- [ ] Visual polido
- [ ] Feedback visual claro
- [ ] Código reutilizável

```

---

## 🚀 PROMPT 3: Criar Hotbar

### Contexto
A hotbar é a barra de atalhos na parte inferior da tela onde o player pode equipar itens rapidamente.

### Prompt para o Claude

```

Crie a hotbar:

ARQUIVO: lib/gameplay/ui/hud/hotbar.dart

REQUISITOS:

1. Estrutura:

   - 8-10 slots horizontais
   - Slot selecionado destacado
   - Mostrar ícone do item em cada slot
   - Mostrar quantidade (se stackable)

2. Interação:

   - Clicar em slot para selecionar
   - Números 1-9 no teclado para atalho
   - Scroll do mouse para mudar seleção
   - Drag & drop para trocar itens

3. Visual:
   - Slots com borda
   - Slot selecionado com highlight
   - Ícones dos itens centralizados
   - Quantidade no canto inferior direito

PADRÃO DE CÓDIGO:

```dart
class Hotbar extends StatefulWidget {
  final List<InventorySlot> slots;
  final int selectedIndex;
  final Function(int) onSlotSelected;

  const Hotbar({
    super.key,
    required this.slots,
    required this.selectedIndex,
    required this.onSlotSelected,
  });

  @override
  State<Hotbar> createState() => _HotbarState();
}

class _HotbarState extends State<Hotbar> {
  static const int _kHotbarSize = 8;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          _kHotbarSize,
          (index) => _buildHotbarSlot(index),
        ),
      ),
    );
  }

  Widget _buildHotbarSlot(int index) {
    final slot = index < widget.slots.length ? widget.slots[index] : null;
    final isSelected = index == widget.selectedIndex;

    return GestureDetector(
      onTap: () => widget.onSlotSelected(index),
      child: Container(
        width: 56,
        height: 56,
        margin: EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected
            ? Colors.amber.withOpacity(0.3)
            : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.white24,
            width: isSelected ? 3 : 2,
          ),
        ),
        child: Stack(
          children: [
            // Ícone do item
            if (slot != null && slot.item != null)
              Center(
                child: Image.asset(
                  slot.item!.iconPath,
                  width: 40,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),

            // Quantidade
            if (slot != null && slot.quantity > 1)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${slot.quantity}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Número do slot
            Positioned(
              top: 2,
              left: 4,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] Hotbar renderiza 8 slots
[ ] Slot selecionado destacado
[ ] Ícones e quantidades visíveis
[ ] Clique seleciona slot
[ ] Números de atalho funcionam

### Critérios de Aceitação

- [ ] Hotbar funcional
- [ ] Interação suave
- [ ] Visual claro
- [ ] Performance boa

```

---

## 🚀 PROMPT 4: Criar Tela de Inventário

### Contexto
Tela completa de inventário com grid de slots, painel de equipamentos e tooltip de itens.

### Prompt para o Claude

```

Crie a tela de inventário:

ARQUIVO: lib/gameplay/ui/inventory/inventory_screen.dart

REQUISITOS:

1. Layout:

   - Grid de slots de inventário (6x5 = 30 slots)
   - Painel de equipamentos (lado direito)
   - Informações do player (topo)
   - Botões de ação (ordenar, fechar)

2. Interação:

   - Clicar em item mostra tooltip
   - Arrastar item para mover
   - Clicar com botão direito usa item
   - ESC para fechar

3. Painel de Equipamentos:

   - Slot de arma
   - Slot de escudo
   - Slots de armadura (cabeça, peito, pernas, botas)
   - Slots de acessórios

4. Tooltip:
   - Nome do item
   - Descrição
   - Stats (dano, defesa, etc)
   - Valor de venda

PADRÃO DE CÓDIGO:

```dart
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  InventorySlot? _hoveredSlot;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Center(
        child: Container(
          width: 900,
          height: 600,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24, width: 2),
          ),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildInventoryGrid(),
                    ),
                    Expanded(
                      flex: 1,
                      child: _buildEquipmentPanel(),
                    ),
                  ],
                ),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Inventory',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              _buildHeaderStat(Icons.inventory, 'Weight', '15/50'),
              SizedBox(width: 16),
              _buildHeaderStat(Icons.monetization_on, 'Gold', '1250'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.amber, size: 20),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.white70, fontSize: 10),
            ),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInventoryGrid() {
    final inventoryManager = InventoryManager.instance;
    final slots = inventoryManager.getAllSlots();

    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: inventoryManager.maxSlots,
        itemBuilder: (context, index) {
          final slot = slots[index];
          return _buildInventorySlot(slot);
        },
      ),
    );
  }

  Widget _buildInventorySlot(InventorySlot slot) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredSlot = slot),
      onExit: (_) => setState(() => _hoveredSlot = null),
      child: GestureDetector(
        onTap: () => _onSlotTapped(slot),
        onSecondaryTap: () => _onSlotRightClicked(slot),
        child: Container(
          decoration: BoxDecoration(
            color: slot.isEmpty ? Colors.grey.shade800 : Colors.grey.shade700,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hoveredSlot == slot ? Colors.amber : Colors.white24,
              width: 2,
            ),
          ),
          child: slot.isEmpty
            ? SizedBox.shrink()
            : Stack(
                children: [
                  Center(
                    child: Image.asset(
                      slot.item!.iconPath,
                      width: 48,
                      height: 48,
                    ),
                  ),
                  if (slot.quantity > 1)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: _buildQuantityBadge(slot.quantity),
                    ),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildQuantityBadge(int quantity) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$quantity',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEquipmentPanel() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(left: BorderSide(color: Colors.white24)),
      ),
      child: Column(
        children: [
          Text(
            'Equipment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          EquipmentPanel(),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomButton(
            label: 'Sort',
            onPressed: _sortInventory,
          ),
          CustomButton(
            label: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _onSlotTapped(InventorySlot slot) {
    // Implementar...
  }

  void _onSlotRightClicked(InventorySlot slot) {
    // Implementar...
  }

  void _sortInventory() {
    InventoryManager.instance.sortByType();
    setState(() {});
  }
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] Grid de inventário renderiza
[ ] Painel de equipamentos funciona
[ ] Tooltip aparece ao hover
[ ] Drag & drop funciona
[ ] Botões de ação funcionam

### Critérios de Aceitação

- [ ] Inventário funcional
- [ ] Layout responsivo
- [ ] Interação intuitiva
- [ ] Performance adequada

```

---

## 🚀 PROMPT 5: Criar Menus (Main, Pause, Settings)

### Contexto
Criar menus principais para navegação do jogo.

### Prompt para o Claude

```

Crie os menus principais:

ARQUIVO 1: lib/gameplay/ui/menus/main_menu.dart
BOTÕES:

- New Game
- Continue (se há save)
- Settings
- Exit

ARQUIVO 2: lib/gameplay/ui/menus/pause_menu.dart
BOTÕES:

- Resume
- Save Game
- Settings
- Exit to Main Menu

ARQUIVO 3: lib/gameplay/ui/menus/settings_menu.dart
OPÇÕES:

- Volume (música, SFX)
- Graphics (fullscreen, resolution)
- Controls (rebind keys)
- Language

PADRÃO DE CÓDIGO:

```dart
class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/ui/main_menu_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Darkness Dungeon',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                ),
              ),
              SizedBox(height: 60),
              CustomButton(
                label: 'New Game',
                width: 250,
                onPressed: () => _startNewGame(context),
              ),
              SizedBox(height: 16),
              CustomButton(
                label: 'Continue',
                width: 250,
                enabled: _hasSaveGame(),
                onPressed: () => _loadGame(context),
              ),
              SizedBox(height: 16),
              CustomButton(
                label: 'Settings',
                width: 250,
                onPressed: () => _openSettings(context),
              ),
              SizedBox(height: 16),
              CustomButton(
                label: 'Exit',
                width: 250,
                onPressed: () => SystemNavigator.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _hasSaveGame() {
    return SaveManager.instance.hasSave();
  }

  void _startNewGame(BuildContext context) {
    // Implementar...
  }

  void _loadGame(BuildContext context) {
    // Implementar...
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SettingsMenu()),
    );
  }
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] Main menu renderiza
[ ] Pause menu sobrepõe jogo
[ ] Settings salvam preferências
[ ] Navegação funciona
[ ] Continue desabilitado se sem save

### Critérios de Aceitação

- [ ] Menus funcionais
- [ ] Navegação intuitiva
- [ ] Settings persistem
- [ ] Visual polido

```

---

## 🚀 PROMPT 6: Criar Widgets Reutilizáveis

### Contexto
Criar componentes UI reutilizáveis (botões, diálogos, etc).

### Prompt para o Claude

```

Crie widgets reutilizáveis:

ARQUIVO 1: lib/gameplay/ui/widgets/custom_button.dart
ARQUIVO 2: lib/gameplay/ui/widgets/dialog_box.dart
ARQUIVO 3: lib/gameplay/ui/widgets/item_tooltip.dart

PADRÃO DE CÓDIGO (CustomButton):

```dart
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double width;
  final bool enabled;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = 200,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: enabled
            ? LinearGradient(colors: [Colors.blue.shade700, Colors.blue.shade500])
            : LinearGradient(colors: [Colors.grey.shade700, Colors.grey.shade500]),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: enabled ? Colors.white : Colors.white54,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
```

CHECKLIST DE VALIDAÇÃO:
[ ] Widgets funcionam standalone
[ ] Reutilizáveis em múltiplos contextos
[ ] Customizáveis via parâmetros
[ ] Código limpo

### Critérios de Aceitação

- [ ] Widgets funcionais
- [ ] Reutilizáveis
- [ ] Bem documentados

```

---

## 📊 Checklist de Conclusão da Fase 4.1

### Arquivos Criados
- [ ] HUD Overlay completo
- [ ] Health/Stamina/Progress bars
- [ ] Hotbar
- [ ] Inventory Screen
- [ ] Equipment Panel
- [ ] Main/Pause/Settings menus
- [ ] Widgets reutilizáveis

### Funcionalidades Validadas
- [ ] HUD atualiza em tempo real
- [ ] Inventário funcional
- [ ] Menus navegáveis
- [ ] Performance >= 60 FPS

### Próximos Passos
✅ **MVP COMPLETO!** Sistema de UI finaliza a estrutura básica do jogo.

---

**Status:** 📄 Pronto para execução
**Última atualização:** 14/11/2025
```
