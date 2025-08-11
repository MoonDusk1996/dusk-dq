#!/usr/bin/env bash
# Caminho para o repositório clonado localmente
REPO_DIR="$HOME/.local/share/daily-quote-sync"
CACHE_FILE="$REPO_DIR/daily_quote.txt"

# Clona se não existir
if [ ! -d "$REPO_DIR/.git" ]; then
    git clone git@github.com:MoonDusk1996/dusk-dq.git "$REPO_DIR"
fi

cd "$REPO_DIR" || exit 1

# Atualiza repo
git pull --rebase

# Verifica se já é a frase de hoje
if [ -f "$CACHE_FILE" ] && grep -q "$(date +%Y-%m-%d)" "$CACHE_FILE"; then
    echo "Frase já atualizada hoje."
else
    # Gera nova frase
    QUOTE=$(curl -s https://zenquotes.io/api/random | jq -r '.[0] | "\(.q) — \(.a)"' | trans -b :pt)

    # Salva com data no início
    echo "$(date +%Y-%m-%d) $QUOTE" > "$CACHE_FILE"

    # Commit e push
    git add daily_quote.txt
    git commit -m "Citação diária $(date +%Y-%m-%d)"
    git push
fi

# Exporta para ambiente
echo "export DAILY_QUOTE=\"$(cut -d' ' -f2- "$CACHE_FILE")\"" > "$HOME/.cache/daily_quote.env"

