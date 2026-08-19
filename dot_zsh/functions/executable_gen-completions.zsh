#!/usr/bin/env sh
unalias gen-comp 2>/dev/null

local -A _completions=(
  cheat    "cheat --completion zsh"
  typst    "typst completions zsh"
  taskbeep "taskbeep completions zsh"
  rustup   "rustup completions zsh"
  just     "just --completions zsh"
  fnm      "fnm completions --shell zsh"
  bat      "bat --completion zsh"
  chezmoi  "chezmoi completion zsh"
  # oven-sh/bun/issues/10897
  bun      "bun completions"
)


function gen-comp() {
  local COMP_DIR="$HOME/.zsh/completions"
  mkdir -p "$COMP_DIR"
  echo "Generating completions..."
  for cmd gen_cmd in "${(@kv)_completions}"; do
    command -v "$cmd" >/dev/null \
      && eval "$gen_cmd" > "$COMP_DIR/_${cmd}" \
      && echo "  ✓ $cmd"
  done
  echo "Done."
  autoload -U compinit && compinit
}
