# 🎵 Configuração de Música por Mapa no Tiled

## 📋 Como Configurar

### 1. **Criar Sensor de Transição no Tiled**

No Tiled, adicione um objeto retangular como sensor de transição entre mapas.

### 2. **Propriedades Obrigatórias**

Configure as seguintes propriedades customizadas no objeto:

```properties
# Propriedades OBRIGATÓRIAS:
nextMap = "dungeon1"                    # ID do próximo mapa
playerPosition = "5,10"                 # Posição X,Y onde o player aparece
playerDirection = "down"                # Direção inicial do player

# Propriedade NOVA - Música específica:
backgroundMusic = "battle_boss.mp3"     # Nome do arquivo de música
```

### 3. **Propriedade backgroundMusic**

- ✅ **Opcional**: Se não configurada, usa música padrão
- 🎵 **Formato**: Nome do arquivo de áudio (ex: "dungeon_theme.mp3")
- 📁 **Local**: Arquivo deve estar em `assets/audio/`
- 🔄 **Idempotente**: Sistema só troca música se for diferente da atual

## 🎯 Exemplos de Uso

### **Mapa Normal → Dungeon**

```properties
nextMap = "dungeon1"
playerPosition = "3,15"
playerDirection = "down"
backgroundMusic = "dark_dungeon.mp3"    # 🌚 Música sombria
```

### **Dungeon → Boss Arena**

```properties
nextMap = "boss_arena"
playerPosition = "8,8"
playerDirection = "up"
backgroundMusic = "battle_boss.mp3"     # ⚔️ Música épica de boss
```

### **Boss Arena → Victory Area**

```properties
nextMap = "victory_hall"
playerPosition = "5,5"
playerDirection = "down"
backgroundMusic = "victory_fanfare.mp3" # 🎉 Música de vitória
```

### **Sem Música (Usar Padrão)**

```properties
nextMap = "peaceful_area"
playerPosition = "2,2"
playerDirection = "right"
# backgroundMusic = não configurado = usa música padrão
```

## 🛠️ Funcionalidades

### **✅ Sistema Inteligente**

- 🎵 **Auto-detecção**: Música inicia automaticamente na transição
- 🔄 **Idempotente**: Não reinicia se já estiver tocando a música correta
- 🚫 **Sem Sobreposição**: Para música anterior antes de iniciar nova
- 📊 **State Tracking**: Sistema sabe qual música está tocando

### **🎮 Compatibilidade**

- ✅ Funciona com sistema de Game Over existente
- ✅ Música reinicia corretamente ao reiniciar jogo
- ✅ Suporte a música de boss (battle_boss.mp3)
- ✅ Fallback para música padrão se arquivo não existir

## 📂 Estrutura de Arquivos

```
assets/
└── audio/
    ├── ro1_death_hex.mp3      # Música padrão
    ├── battle_boss.mp3        # Música de boss
    ├── dark_dungeon.mp3       # Música de dungeon
    ├── victory_fanfare.mp3    # Música de vitória
    └── peaceful_theme.mp3     # Música de área pacífica
```

## 🎯 Resumo

Agora você pode configurar **música única para cada mapa** diretamente no **Tiled**, criando uma experiência sonora rica e imersiva! 🎵✨

### **Antes:**

- 🎵 Uma música para todo o jogo

### **Agora:**

- 🌍 **Map1**: Música de aventura
- 🏰 **Dungeon**: Música sombria
- ⚔️ **Boss**: Música épica
- 🎉 **Victory**: Música triunfante

**Código limpo, configuração visual, experiência incrível!** 🚀
