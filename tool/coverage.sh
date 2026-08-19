#!/usr/bin/env bash
#
# Cobertura de testes com resumo por camada e gate global.
#
#   ./tool/coverage.sh            # roda testes, imprime resumo, aplica o gate
#   ./tool/coverage.sh --html     # + relatório HTML (requer `lcov`)
#   ./tool/coverage.sh --no-gate  # só reporta, não falha
#
# O gate global é uma CATRACA, não a meta final: ele trava a regressão no nível
# já conquistado. Ao subir a cobertura, suba `GLOBAL_THRESHOLD` junto — no mesmo
# commit. A meta de longo prazo (80%) e o porquê deste desenho estão em
# documentation/TESTING.md.
#
# Camadas puramente de render (views, componentes Bonfire, overlays) são
# excluídas por exigirem game loop. Nada além disso é excluído: inflar o número
# escondendo código testável derrota o propósito da métrica.

set -euo pipefail

cd "$(dirname "$0")/.."

GLOBAL_THRESHOLD=20
WANT_HTML=false
APPLY_GATE=true

for arg in "$@"; do
  case "$arg" in
    --html)    WANT_HTML=true ;;
    --no-gate) APPLY_GATE=false ;;
    *) echo "opção desconhecida: $arg" >&2; exit 2 ;;
  esac
done

LCOV_FILE="coverage/lcov.info"

echo "▶ Rodando testes com cobertura..."
flutter test --coverage >/dev/null

if [[ ! -f "$LCOV_FILE" ]]; then
  echo "✗ $LCOV_FILE não foi gerado." >&2
  exit 1
fi

# --- Exclusões: código que exige o game loop do Bonfire ou a árvore de widgets.
EXCLUDE_PATTERNS=(
  '_view\.dart$'
  '_overlay\.dart$'
  '/components/'
  '/widgets/'
  '/overlay/'
  '/design_system'
  '/shared/framework/player/'   # cadeia legada — removida na Fase 3.2
  'main\.dart$'
)

echo "▶ Calculando cobertura..."

awk -v excludes="$(IFS='|'; echo "${EXCLUDE_PATTERNS[*]}")" '
  BEGIN { n = split(excludes, ex, "|") }

  /^SF:/ {
    file = substr($0, 4)
    skip = 0
    for (i = 1; i <= n; i++) {
      if (file ~ ex[i]) { skip = 1; break }
    }
    hit = 0; total = 0
    next
  }

  /^DA:/ {
    if (skip) next
    split(substr($0, 4), parts, ",")
    total++
    if (parts[2] + 0 > 0) hit++
    next
  }

  /^end_of_record/ {
    if (skip) next

    layer = "outros"
    if (file ~ /\/features\/world\/entities\//)          layer = "world/entities"
    else if (file ~ /\/features\/farm\/usecases\//)      layer = "farm/usecases"
    else if (file ~ /\/features\/farm\//)                layer = "farm/resto"
    else if (file ~ /\/features\/inventory\/usecases\//) layer = "inventory/usecases"
    else if (file ~ /\/features\/inventory\//)           layer = "inventory/resto"
    else if (file ~ /\/features\/time\//)                layer = "time"
    else if (file ~ /\/features\/market\//)              layer = "market"
    else if (file ~ /\/systems\/save\//)                 layer = "systems/save"
    else if (file ~ /\/systems\/world\//)                layer = "systems/world"
    else if (file ~ /\/systems\//)                       layer = "systems/resto"
    else if (file ~ /\/database\//)                      layer = "database"
    else if (file ~ /\/modules\//)                       layer = "modules"
    else if (file ~ /\/shared\//)                        layer = "shared"
    else if (file ~ /\/core\//)                          layer = "core"

    layerHit[layer]  += hit
    layerTotal[layer] += total
    allHit  += hit
    allTotal += total
    next
  }

  END {
    # Ordena as camadas por cobertura crescente: o que precisa de atenção
    # primeiro aparece no topo.
    for (l in layerTotal) {
      if (layerTotal[l] == 0) continue
      rows[++count] = sprintf("%9.1f|%-22s %8d %8d %7.1f%%", \
        layerHit[l] * 100.0 / layerTotal[l], l, layerHit[l], layerTotal[l], \
        layerHit[l] * 100.0 / layerTotal[l])
    }
    for (i = 1; i < count; i++)
      for (j = i + 1; j <= count; j++)
        if ((rows[i] + 0) > (rows[j] + 0)) { t = rows[i]; rows[i] = rows[j]; rows[j] = t }

    printf "\n%-22s %8s %8s %8s\n", "CAMADA", "COBERTO", "TOTAL", "%"
    printf "%-22s %8s %8s %8s\n", "----------------------", "--------", "--------", "--------"
    for (i = 1; i <= count; i++) {
      sub(/^[^|]*\|/, "", rows[i])
      print rows[i]
    }
    printf "%-22s %8s %8s %8s\n", "----------------------", "--------", "--------", "--------"

    pct = (allTotal > 0) ? allHit * 100.0 / allTotal : 0
    printf "%-22s %8d %8d %7.1f%%\n", "GLOBAL", allHit, allTotal, pct
    printf "%.2f\n", pct > "coverage/.global_pct"
  }
' "$LCOV_FILE"

GLOBAL_PCT=$(cat coverage/.global_pct 2>/dev/null || echo 0)

if [[ "$WANT_HTML" == true ]]; then
  if command -v genhtml >/dev/null 2>&1; then
    echo
    echo "▶ Gerando HTML em coverage/html/ ..."
    genhtml "$LCOV_FILE" -o coverage/html --quiet
    echo "  → coverage/html/index.html"
  else
    echo '⚠ genhtml não encontrado. Instale com: brew install lcov' >&2
  fi
fi

echo
if [[ "$APPLY_GATE" == true ]]; then
  if awk -v p="$GLOBAL_PCT" -v t="$GLOBAL_THRESHOLD" 'BEGIN { exit !(p < t) }'; then
    echo "✗ Cobertura global ${GLOBAL_PCT}% abaixo da catraca de ${GLOBAL_THRESHOLD}%."
    exit 1
  fi
  echo "✓ Cobertura global ${GLOBAL_PCT}% (catraca: ${GLOBAL_THRESHOLD}%, meta: 80%)."
else
  echo "· Cobertura global ${GLOBAL_PCT}% (gate desativado)."
fi
