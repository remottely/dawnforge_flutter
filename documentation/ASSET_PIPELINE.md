# Pipeline de Assets

Notas de trabalho para preparar spritesheets. Requer [ImageMagick](https://imagemagick.org) (`magick`).

> Movido do `README.md` na reorganização de documentação. São receitas testadas — mantenha aqui e adicione novas conforme aparecerem.

---

## Convenção de nomes

```
<entidade>_<ação>_<direção>_<largura>x<altura>_<nFrames>.png
```

Exemplos: `player_walk_south_48x48_6.png`, `goblin_enemy_idle_left_6.png`, `torch_decoration_6.png`

Direções suportadas nas animações direcionais: `right`, `left`, `up`, `down`, `right_up`, `right_down`, `left_up`, `left_down`.

---

## Receitas

### Espelhar horizontalmente (gerar variante `left` a partir da `right`)

Corta em frames, espelha cada um, reconcatena — necessário porque espelhar a folha inteira inverteria a **ordem** dos frames.

```bash
magick player_attack_east_4.png -crop 32x32 +repage -flop +append player_attack_west_4.png
```

Com frames de 96x64:

```bash
cd "assets/images/SunnysideWorld/Sprites/CHARACTERS/ANIMATION/BASE CHARACTER/PNG/WITH_FX"
magick spr_doing_till_strip8.png  -crop 96x64 +repage -flop +append spr_doing_till_left_strip8.png
magick spr_sword_strip10.png      -crop 96x64 +repage -flop +append spr_sword_left_strip10.png
```

### Padding de frame (32x32 → 48x48, centralizado, fundo transparente)

```bash
magick player_walk_south_6.png -crop 32x32 \
  -gravity center -background transparent -extent 48x48 \
  +append player_walk_south_48x48_6.png
```

### Fatiar um atlas em linhas (uma animação por linha)

```bash
magick Player.png -crop 192x32 +repage +adjoin row_%02d.png
```

### Fatiar em frames individuais

```bash
magick Player.png -crop 32x32 +repage frame_%03d.png
```

### Atlas com linhas de comprimento irregular

Caso real: `Player.png` 192x320, frames 32x32 → 10 linhas × 6 colunas, mas as 4 últimas linhas só têm 4 frames válidos.

```bash
# 1. fatia em linhas
magick Player.png -crop 192x32 +repage +adjoin row_%02d.png

# 2. corta as linhas curtas para 4 frames (128px)
for r in 06 07 08 09; do
  magick "row_${r}.png" -crop 128x32+0+0 +repage "row_${r}.png"
done
```

Alternativa (fatiar tudo e remover os frames vazios):

```bash
magick Player.png -crop 32x32 +repage frame_%03d.png && \
rm frame_006.png frame_007.png frame_013.png frame_014.png frame_015.png \
   frame_020.png frame_021.png frame_022.png frame_023.png frame_027.png \
   frame_028.png frame_029.png frame_030.png frame_031.png frame_034.png \
   frame_035.png frame_036.png frame_037.png frame_038.png frame_039.png
```

### Fatiar ações em 96x48

```bash
cd assets/images/new/Player
magick Player*Actions.png -crop 96x48 +repage -scene 1 Player_Actions_row%d.png
```

---

## Registro no `pubspec.yaml`

- **Sempre registre arquivos individuais**, nunca pastas. Registro por pasta infla o bundle e já causou regressões de build.
- Mantenha os assets agrupados sob os comentários de seção existentes (`# === TILED - Maps ===` etc.).
- Ao remover um asset do disco, remova a linha correspondente — asset ausente registrado é erro em runtime, não em build.

## Pendências

- [ ] Uniformizar a cor de fundo de todos os mapas com a cor do chão do mapa.
