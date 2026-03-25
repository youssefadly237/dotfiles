# Text to Speech converter using Coqui TTS XTTS-v2
unalias bak 2>/dev/null
unalias unbak 2>/dev/null
unalias mkcd 2>/dev/null

bak() {
  cp "$1" "$1.bak"
}

unbak() {
  if [[ "$1" == *.bak ]]; then
    mv "$1" "${1%.bak}"
  else
    mv "$1.bak" "$1"
  fi
}

mkcd() {
  mkdir -p "$1" && cd "$1"
}
