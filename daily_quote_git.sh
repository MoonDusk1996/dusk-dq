#!/usr/bin/env bash
REPO_DIR="$HOME/.local/share/daily-quote-sync"
CACHE_FILE="$REPO_DIR/daily_quote.txt"

if [ ! -d "$REPO_DIR/.git" ]; then
    git clone git@github.com:MoonDusk1996/dusk-dq.git "$REPO_DIR"
fi

cd "$REPO_DIR" || exit 1

git pull --rebase

if [ -f "$CACHE_FILE" ] && [ "$(stat -c %y "$CACHE_FILE" | cut -d' ' -f1)" = "$(date +%Y-%m-%d)" ]; then
    echo "Frase já atualizada hoje."
else
    QUOTE=$(curl -s https://zenquotes.io/api/random | jq -r '.[0] | "\(.q) — \(.a)"' | trans -b :pt)
    echo "$QUOTE" > "$CACHE_FILE"
    git add daily_quote.txt
    git commit -m "Citação diária $(date +%Y-%m-%d)"
    git push
fi

echo "export DAILY_QUOTE=\"$(cat "$CACHE_FILE")\"" > "$HOME/.cache/daily_quote.env"


