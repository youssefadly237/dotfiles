unalias where-was-i 2>/dev/null

where-was-i() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "where-was-i: not a git repository" >&2
        return 1
    fi

    local current=$(git branch --show-current)
    local parent

    if [[ -z "$current" ]]; then
        current="detached@$(git rev-parse --short HEAD)"
        parent=$(git branch --contains HEAD | grep -v '\*' | head -n1 | tr -d ' ')
    else
        parent=$(git show-branch | sed "s/].*//" | grep "\*" | grep -v "$current" | head -n1 | sed "s/^.*\[//" | sed "s/[~^].*//")
    fi

    read behind ahead < <(git rev-list --left-right --count "$parent"...HEAD)
    echo "$current vs $parent: $behind behind, $ahead ahead"
}
