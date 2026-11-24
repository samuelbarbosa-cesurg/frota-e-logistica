#!/usr/bin/env bash
cd "$(dirname "$0")" || exit 1

PSQL="docker compose exec db psql -U frota -d frota_logistica"

uso() {
  echo "Uso: ./rodar.sh <comando>"
  echo ""
  echo "  up        sobe o banco"
  echo "  reset     apaga tudo e sobe um banco vazio"
  echo "  1 a 6     roda o script correspondente (ex.: ./rodar.sh 1)"
  echo "  tudo      reset + scripts 01 a 06 na ordem"
  echo "  psql      abre o psql interativo (sair com \\q)"
  echo "  status    mostra o estado do container"
}

subir() {
  docker compose up -d --wait
}

reset() {
  docker compose down -v && subir
}

rodar() {
  local n arq
  n=$(printf "%02d" "$((10#$1))")
  arq=$(ls scripts/${n}_*.sql 2>/dev/null | head -n1)
  if [ -z "$arq" ]; then
    echo "Script $n não encontrado em scripts/"
    return 1
  fi
  echo ">>> $arq"
  if [ "$n" = "01" ] || [ "$n" = "02" ]; then
    $PSQL -v ON_ERROR_STOP=1 -f "/$arq"
  else
    $PSQL -a -f "/$arq"
  fi
}

case "$1" in
  up) subir ;;
  reset) reset ;;
  status) docker compose ps ;;
  psql) $PSQL ;;
  tudo)
    reset || exit 1
    for i in 1 2 3 4 5 6; do
      rodar "$i" || break
    done
    ;;
  [0-9]|[0-9][0-9]) rodar "$1" ;;
  *) uso ;;
esac
