# ADR-0002 — Catálogo de conteúdo em constantes Dart em vez de JSON

- **Status:** aceito
- **Data:** 2025 (retroativo — commits `1.104.44+1` … `1.104.49+1`)

## Contexto

O catálogo de conteúdo do jogo (itens, sementes, ferramentas, armas, materiais, plantações) vivia em JSON nos assets:

```yaml
- assets/database/crops_database.json
- assets/database/items/weapons.json
- assets/database/items/tools.json
```

Problemas concretos observados:

- Erro de digitação em id só aparecia **jogando**, no ponto exato onde o item era usado.
- Carregar exigia `rootBundle` → binding do Flutter inicializado → **todo teste que tocasse o catálogo precisava de `TestWidgetsFlutterBinding` e de mock de asset**. Foi uma das causas dos testes antigos terem virado bloco comentado.
- Sem autocomplete, sem refactor-rename, sem "find usages".
- Parse em runtime, no boot, sem ganho nenhum: os dados **nunca** mudam sem recompilar.

## Decisão

Catálogo em **constantes Dart tipadas** sob `lib/game/database/`, em arquivos `*_database_def.dart`:

```dart
final class SmallBurgCropEntityDatabaseDef {
  SmallBurgCropEntityDatabaseDef._();

  static const Map<HandItemId, CropEntity> cropEntityList = {
    HandItemId.carrot: CropEntity(
      id: HandItemId.carrot,
      daysToMature: 4,
      harvestItemId: HandItemId.carrot_loot_item,
      // …
    ),
  };
}
```

Os `*FactoryService` passam a copiar desses mapas em vez de fazer parse de JSON.

**Não reverter para JSON.**

## Consequências

**Positivas.**
- Id inexistente é **erro de compilação**, não bug de runtime.
- Catálogo testável sem binding do Flutter, sem mock de asset, sem `async`.
- Autocomplete e rename funcionam no catálogo inteiro.
- Zero IO e zero parse no boot.
- Permite **testes de invariante** (`02-fase-2 §2.6`): "todo crop tem `harvestItemId` válido", "todo `daysToMature > 0`". Uma suíte que valida o conteúdo do jogo em milissegundos.

**Negativas — aceitas.**
- Mudar balanceamento exige recompilar. Irrelevante para dev solo: já se está com o projeto aberto.
- Sem edição por não-programador. Não há não-programador no projeto.
- Sem hot-reload de dados. Aceito.

**Se um dia houver modding ou um designer não-programador**, a inversão é direta: os `*FactoryService` já são a fronteira: basta uma implementação que leia JSON e preencha os mesmos mapas. Não fazer isso agora é YAGNI, não descuido.

## Alternativas consideradas

- **Manter JSON com schema validado no build.** Resolveria a validação, mas mantém o custo de IO e a fricção de teste.
- **Geração de código a partir de JSON** (`build_runner`). Daria o melhor dos dois, ao custo de uma etapa de build, uma dependência e código gerado no repo. Desproporcional ao tamanho do catálogo.
- **Constantes Dart.** ✅ Escolhida.
