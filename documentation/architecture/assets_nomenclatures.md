# Estrutura de Nomenclatura Modular para Stardew Valley Clone

## 📋 Convenção de Nomenclatura

```
{category}_{part}_{action}_{variant}_{frames}

Exemplo: char_body_walk_nohand_8f
```

## 🎯 Estrutura Completa

### **1. Categorias (Prefixos)**

```
char_   → Character (player/NPC)
item_   → Items (tools, weapons)
obj_    → Objects (furniture, decorations)
tile_   → Tiles (ground, walls)
fx_     → Effects (particles, animations)
ui_     → Interface elements
icon_   → Icons
crop_   → Crops/plants
anim_   → Animated objects
```

### **2. Partes do Personagem (Body Parts)**

```
body_      → Corpo principal (torso + legs)
head_      → Cabeça
hair_      → Cabelo
hand_l_    → Mão esquerda
hand_r_    → Mão direita
hands_     → Ambas as mãos juntas
arm_l_     → Braço esquerdo
arm_r_     → Braço direito
```

### **3. Ações (Actions)**

```
idle_      → Parado
walk_      → Andando
run_       → Correndo
attack_    → Atacando
use_       → Usando ferramenta
carry_     → Carregando
fish_      → Pescando
water_     → Regando
hoe_       → Usando enxada
axe_       → Usando machado
pick_      → Usando picareta
```

### **4. Variantes (Variants)**

```
nohand_    → Sem mãos (body solto)
full_      → Completo (tudo junto)
front_     → Vista frontal
back_      → Vista traseira
side_      → Vista lateral
equipped_  → Com equipamento
bare_      → Sem equipamento
```

### **5. Frames e Direções**

```
_8f        → 8 frames
_4f        → 4 frames
_n         → Norte (cima)
_s         → Sul (baixo)
_e         → Leste (direita)
_w         → Oeste (esquerda)
_ne, _nw, _se, _sw  → Diagonais
```

---

## 🎨 Exemplos Práticos para Darkness Dungeon

### **Sistema Modular (Componível)**

```
📁 characters/player/modular/

Body (sem mãos):
  char_body_idle_nohand_4f.png
  char_body_walk_nohand_8f.png
  char_body_run_nohand_8f.png

Mãos (equipamentos separados):
  char_hand_l_sword_idle_4f.png
  char_hand_l_sword_attack_6f.png
  char_hand_r_shield_idle_4f.png
  char_hand_r_shield_block_3f.png
  char_hand_r_bow_idle_4f.png
  char_hand_r_bow_shoot_8f.png

Cabeça/Cabelo:
  char_head_male_front_4f.png
  char_hair_short_blonde_4f.png
```

### **Sistema Completo (Pré-composto)**

```
📁 characters/player/full/

char_knight_idle_full_4f.png
char_knight_walk_full_8f.png
char_knight_run_full_8f.png
char_knight_attack_full_10f.png
char_farmer_walk_full_8f.png
char_farmer_hoe_full_6f.png
```

---

## 🗂️ Estrutura de Pastas Completa

```
assets/images/
│
├── characters/
│   ├── player/
│   │   ├── modular/
│   │   │   ├── body/
│   │   │   │   ├── char_body_idle_nohand_4f.png
│   │   │   │   ├── char_body_walk_nohand_8f.png
│   │   │   │   └── char_body_run_nohand_8f.png
│   │   │   │
│   │   │   ├── hands/
│   │   │   │   ├── weapons/
│   │   │   │   │   ├── char_hand_l_sword_idle_4f.png
│   │   │   │   │   ├── char_hand_l_sword_attack_6f.png
│   │   │   │   │   ├── char_hand_r_bow_idle_4f.png
│   │   │   │   │   └── char_hand_r_bow_shoot_8f.png
│   │   │   │   │
│   │   │   │   └── tools/
│   │   │   │       ├── char_hand_r_hoe_idle_4f.png
│   │   │   │       ├── char_hand_r_hoe_use_6f.png
│   │   │   │       ├── char_hand_r_water_idle_4f.png
│   │   │   │       └── char_hand_r_water_use_5f.png
│   │   │   │
│   │   │   └── head/
│   │   │       ├── char_head_male_4f.png
│   │   │       └── char_hair_short_4f.png
│   │   │
│   │   └── full/
│   │       ├── knight/
│   │       │   ├── char_knight_idle_full_4f.png
│   │       │   ├── char_knight_walk_full_8f.png
│   │       │   └── char_knight_attack_full_10f.png
│   │       │
│   │       └── farmer/
│   │           ├── char_farmer_idle_full_4f.png
│   │           ├── char_farmer_walk_full_8f.png
│   │           └── char_farmer_hoe_full_6f.png
│   │
│   └── npcs/
│       ├── char_merchant_idle_full_4f.png
│       └── char_villager_walk_full_8f.png
│
├── items/
│   ├── tools/
│   │   ├── item_hoe_icon.png
│   │   ├── item_axe_icon.png
│   │   └── item_water_icon.png
│   │
│   └── weapons/
│       ├── item_sword_iron_icon.png
│       └── item_bow_wood_icon.png
│
├── crops/
│   ├── crop_wheat_growth_5f.png
│   ├── crop_corn_growth_6f.png
│   └── crop_tomato_growth_4f.png
│
├── fx/
│   ├── fx_dust_walk_4f.png
│   ├── fx_slash_attack_6f.png
│   └── fx_sparkle_harvest_8f.png
│
└── ui/
    ├── ui_inventory_panel.png
    ├── ui_button_normal.png
    └── ui_cursor_hand.png
```

---

## 📝 Tabela de Conversão (Seu Nome → Novo Nome)

| Arquivo Antigo                     | Arquivo Novo                  |
| ---------------------------------- | ----------------------------- |
| `spr_walking_without_hands_strip8` | `char_body_walk_nohand_8f`    |
| `spr_idle_strip4`                  | `char_body_idle_nohand_4f`    |
| `spr_running_strip6`               | `char_body_run_nohand_6f`     |
| `hand_left_sword_attack`           | `char_hand_l_sword_attack_6f` |
| `hand_right_shield_block`          | `char_hand_r_shield_block_3f` |
| `knight_full_animations`           | `char_knight_walk_full_8f`    |

---

## 🔧 Script de Renomeação Automática

```bash
#!/bin/bash
# rename_sprites.sh

# Body animations
mv spr_walking_without_hands_strip8.png char_body_walk_nohand_8f.png
mv spr_idle_strip4.png char_body_idle_nohand_4f.png
mv spr_running_strip6.png char_body_run_nohand_6f.png

# Hand animations - weapons
mv hand_left_sword_attack_strip6.png char_hand_l_sword_attack_6f.png
mv hand_left_sword_idle_strip4.png char_hand_l_sword_idle_4f.png
mv hand_right_shield_block_strip3.png char_hand_r_shield_block_3f.png
mv hand_right_shield_idle_strip4.png char_hand_r_shield_idle_4f.png

# Hand animations - tools
mv hand_right_hoe_use_strip6.png char_hand_r_hoe_use_6f.png
mv hand_right_water_use_strip5.png char_hand_r_water_use_5f.png

# Full character animations
mv knight_walk_full_strip8.png char_knight_walk_full_8f.png
mv farmer_walk_full_strip8.png char_farmer_walk_full_8f.png

echo "✓ Renomeação concluída!"
```

---

## 🎯 Vantagens desta Nomenclatura

✅ **Modular**: Fácil encontrar partes específicas
✅ **Escalável**: Adicione novos tipos sem conflitos
✅ **Consistente**: Padrão claro para toda equipe
✅ **Legível**: Nome descreve exatamente o conteúdo
✅ **Organizado**: Estrutura de pastas intuitiva
✅ **Searchable**: Fácil buscar por categoria/ação

---

## 💡 Dicas Extras

1. **Use snake_case** (underscores) - mais legível que camelCase em nomes de arquivo
2. **Sempre inclua número de frames** - facilita carregar animações
3. **Agrupe por funcionalidade** - não por tipo de arquivo
4. **Mantenha nomes curtos** mas descritivos
5. **Documente exceções** - se quebrar padrão, explique por quê

---

Quer que eu crie um script mais completo que renomeie automaticamente todos os seus arquivos atuais? Ou prefere ajuda com a organização de alguma categoria específica? 🎨✨
