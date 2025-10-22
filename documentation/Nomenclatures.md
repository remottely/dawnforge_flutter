# Nomenclatures Guide

Este documento define padrões de nomenclatura para métodos, propriedades e variáveis no projeto, visando clareza, consistência e fácil manutenção.

## Prefixos

- **build**: Utilizado para métodos que constroem ou configuram objetos, geralmente a partir de parâmetros ou lógica interna.
  - Exemplo: `buildDirectionalAnimation`, `buildLightingConfig`
- **create**: Indica criação de uma nova instância de objeto, especialmente quando cada chamada retorna um novo objeto.
  - Exemplo: `createHitbox`, `createProjectile`
- **load**: Usado para métodos que carregam recursos externos (assets, arquivos, dados assíncronos). Normalmente retorna um `Future`.
  - Exemplo: `loadSpriteSheet`, `loadAnimation`, `loadAudio`

## Sufixos

- **Sprite**: Refere-se a imagens ou objetos gráficos estáticos individuais usados em renderização.
  - Exemplo: `barrelSprite`, `lifePotionSprite`
- **Animation**: Refere-se a uma sequência de sprites (sprite sheet) ou frames que compõem uma animação.
  - Exemplo: `runAnimation`, `idleAnimation`, `attackAnimation`

## Recomendações Gerais

- Use prefixos para indicar claramente a ação do método (criar, construir, carregar).
- Use sufixos para indicar o tipo de recurso ou objeto retornado.
- Evite redundância de contexto: dentro de classes específicas, não repita o nome do contexto no nome da propriedade.
- Prefira nomes descritivos e objetivos, facilitando a leitura e manutenção do código.

---
