import 'dart:io';
import 'dart:convert';

void main() async {
  print('🔍 Analisando assets do projeto...\n');

  final projectDir = Directory.current;
  final assetsUsed = <String>{};
  final assetsPhysical = <String>{};

  // 1. Encontrar todos os assets físicos
  print('📁 Escaneando assets físicos...');
  await _scanPhysicalAssets(projectDir, assetsPhysical);
  print('   Encontrados: ${assetsPhysical.length} arquivos\n');

  // 2. Escanear arquivos .dart em busca de referências
  print('🔎 Escaneando arquivos .dart...');
  await _scanDartFiles(projectDir, assetsUsed);

  // 3. Escanear arquivos .json
  print('🔎 Escaneando arquivos .json...');
  await _scanJsonFiles(projectDir, assetsUsed);

  // 4. Escanear mapas do Tiled
  print('🔎 Escaneando mapas Tiled...');
  await _scanTiledMaps(projectDir, assetsUsed);

  print('\n📊 RELATÓRIO DE ASSETS\n');
  print('=' * 80);

  // Assets usados
  final sortedUsed = assetsUsed.toList()..sort();
  print('\n✅ ASSETS UTILIZADOS NO CÓDIGO (${sortedUsed.length}):');
  print('-' * 80);
  
  final categorized = <String, List<String>>{};
  for (final asset in sortedUsed) {
    final category = _categorizeAsset(asset);
    categorized.putIfAbsent(category, () => []).add(asset);
  }

  for (final category in categorized.keys.toList()..sort()) {
    print('\n  # $category:');
    for (final asset in categorized[category]!) {
      print('    - $asset');
    }
  }

  // Assets não usados
  final unused = assetsPhysical.difference(assetsUsed);
  if (unused.isNotEmpty) {
    final sortedUnused = unused.toList()..sort();
    print('\n\n⚠️  ASSETS FÍSICOS NÃO REFERENCIADOS (${sortedUnused.length}):');
    print('-' * 80);
    for (final asset in sortedUnused) {
      print('    - $asset');
    }
  }

  // Gerar pubspec.yaml
  print('\n\n📝 NOVA SEÇÃO PARA pubspec.yaml:');
  print('=' * 80);
  _generatePubspecSection(categorized);

  print('\n\n✅ Análise completa!');
}

Future<void> _scanPhysicalAssets(Directory dir, Set<String> assets) async {
  final assetsDir = Directory('${dir.path}/assets');
  if (!await assetsDir.exists()) return;

  await for (final entity in assetsDir.list(recursive: true)) {
    if (entity is File) {
      final relativePath = entity.path.replaceFirst('${dir.path}/', '');
      // Ignorar arquivos de sistema
      if (!relativePath.contains('.DS_Store') && 
          !relativePath.endsWith('.gitkeep')) {
        assets.add(relativePath);
      }
    }
  }
}

Future<void> _scanDartFiles(Directory dir, Set<String> assetsUsed) async {
  final libDir = Directory('${dir.path}/lib');
  if (!await libDir.exists()) return;

  final patterns = [
    RegExp(r'''Sprite\.load\s*\(\s*['"]([^'"]+)['"]'''),
    RegExp(r'''SpriteAnimation\.load\s*\(\s*['"]([^'"]+)['"]'''),
    RegExp(r'''Image\.asset\s*\(\s*['"]([^'"]+)['"]'''),
    RegExp(r'''AssetImage\s*\(\s*['"]([^'"]+)['"]'''),
    RegExp(r'''rootBundle\.loadString\s*\(\s*['"]([^'"]+)['"]'''),
    RegExp(r'''rootBundle\.load\s*\(\s*['"]([^'"]+)['"]'''),
    RegExp(r'''Flame\.images\.load\s*\(\s*['"]([^'"]+)['"]'''),
    RegExp(r'''['"]assets/([^'"]+)['"]'''), // Referências diretas
  ];

  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = await entity.readAsString();
      
      for (final pattern in patterns) {
        final matches = pattern.allMatches(content);
        for (final match in matches) {
          var asset = match.group(1)!;
          // Normalizar caminho
          if (!asset.startsWith('assets/')) {
            asset = 'assets/images/$asset';
          }
          assetsUsed.add(asset);
        }
      }
    }
  }
}

Future<void> _scanJsonFiles(Directory dir, Set<String> assetsUsed) async {
  final assetsDir = Directory('${dir.path}/assets');
  if (!await assetsDir.exists()) return;

  await for (final entity in assetsDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.json')) {
      try {
        final content = await entity.readAsString();
        final json = jsonDecode(content);
        _extractAssetsFromJson(json, assetsUsed);
      } catch (e) {
        // Ignorar JSON inválido
      }
    }
  }
}

void _extractAssetsFromJson(dynamic json, Set<String> assetsUsed) {
  if (json is Map) {
    json.forEach((key, value) {
      if (value is String) {
        // Procurar por caminhos de assets
        if (value.contains('assets/') || 
            value.endsWith('.png') || 
            value.endsWith('.jpg') ||
            value.endsWith('.json') ||
            value.endsWith('.mp3')) {
          if (value.startsWith('assets/')) {
            assetsUsed.add(value);
          }
        }
      } else if (value is Map || value is List) {
        _extractAssetsFromJson(value, assetsUsed);
      }
    });
  } else if (json is List) {
    for (final item in json) {
      _extractAssetsFromJson(item, assetsUsed);
    }
  }
}

Future<void> _scanTiledMaps(Directory dir, Set<String> assetsUsed) async {
  final tiledDir = Directory('${dir.path}/assets/images/tiled');
  if (!await tiledDir.exists()) return;

  await for (final entity in tiledDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.json')) {
      try {
        final content = await entity.readAsString();
        final json = jsonDecode(content);
        
        // Extrair tilesets
        if (json is Map && json.containsKey('tilesets')) {
          for (final tileset in json['tilesets'] as List) {
            if (tileset is Map && tileset.containsKey('image')) {
              final imagePath = tileset['image'] as String;
              // Converter caminho relativo para absoluto
              final normalized = 'assets/images/tiled/${imagePath.replaceAll('../', '')}';
              assetsUsed.add(normalized);
            }
          }
        }
      } catch (e) {
        // Ignorar
      }
    }
  }
}

String _categorizeAsset(String asset) {
  if (asset.contains('/l10n/')) return 'Localization';
  if (asset.contains('/fonts/')) return 'Fonts';
  if (asset.contains('/music/')) return 'Music';
  if (asset.contains('/sfx/')) return 'Sound Effects';
  if (asset.contains('/audio/')) return 'Audio';
  if (asset.contains('/player/')) return 'Player Characters';
  if (asset.contains('/enemies/')) return 'Enemies';
  if (asset.contains('/npcs/')) return 'NPCs';
  if (asset.contains('/decorations/')) return 'Decorations';
  if (asset.contains('/crops/')) return 'Farm - Crops';
  if (asset.contains('/farm/')) return 'Farm System';
  if (asset.contains('/soil/')) return 'Farm - Soil';
  if (asset.contains('/tiled/')) return 'Tiled Maps & Tilesets';
  if (asset.contains('/joystick/')) return 'UI - Joystick';
  if (asset.contains('/hud/')) return 'UI - HUD';
  if (asset.contains('/ui/')) return 'UI';
  if (asset.contains('/items/')) return 'Items & Inventory';
  if (asset.contains('/weapons/')) return 'Weapons';
  if (asset.endsWith('.json')) return 'Data Files (JSON)';
  return 'Other';
}

void _generatePubspecSection(Map<String, List<String>> categorized) {
  print('flutter:');
  print('  uses-material-design: true');
  print('');
  print('  assets:');
  
  for (final category in categorized.keys.toList()..sort()) {
    print('    # $category');
    for (final asset in categorized[category]!) {
      print('    - $asset');
    }
    print('');
  }
  
  print('  fonts:');
  print('    - family: Normal');
  print('      fonts:');
  print('        - asset: assets/fonts/font_pixel.ttf');
}
