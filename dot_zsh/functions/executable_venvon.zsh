# ~/.zsh/functions/venvon.zsh
unalias venvon 2>/dev/null
venvon() {
    local -a venvs display_names
    local choice

    setopt local_options null_glob

    for dir in */ .*/; do
        [[ -d "$dir" ]] || continue
        [[ "$dir" == "./" || "$dir" == "../" ]] && continue
        dir="${dir%/}"

        # Check if it's a valid venv (has bin/activate or Scripts/activate)
        if [[ -f "$dir/bin/activate" ]] || [[ -f "$dir/Scripts/activate" ]]; then
            # Skip if this is the currently active venv
            local dir_realpath=$(realpath "$dir" 2>/dev/null)
            local current_venv_realpath=$(realpath "$VIRTUAL_ENV" 2>/dev/null)
            [[ -n "$VIRTUAL_ENV" && "$dir_realpath" == "$current_venv_realpath" ]] && continue

            venvs+=("$dir")
            display_names+=("$dir")
        fi
    done

    # Add poetry venv if available and not already listed
    if command -v poetry >/dev/null 2>&1; then
        local poetry_venv
        if poetry_venv=$(poetry env info --path 2>/dev/null) && [[ -f "$poetry_venv/bin/activate" ]]; then
            # Check if this poetry venv is different from local ones and not currently active
            local is_duplicate=0
            local poetry_venv_realpath=$(realpath "$poetry_venv" 2>/dev/null)
            local current_venv_realpath=$(realpath "$VIRTUAL_ENV" 2>/dev/null)

            # Skip if it's the currently active venv
            [[ -n "$VIRTUAL_ENV" && "$poetry_venv_realpath" == "$current_venv_realpath" ]] && is_duplicate=1

            # Check against local venvs
            for existing in "${venvs[@]}"; do
                [[ "$(realpath "$existing" 2>/dev/null)" == "$poetry_venv_realpath" ]] && is_duplicate=1 && break
            done
            if ((!is_duplicate)); then
                venvs+=("$poetry_venv")
                display_names+=("$(basename "$poetry_venv") (poetry)")
            fi
        fi
    fi

    # Add deactivate option if a venv is currently active
    if [[ -n "$VIRTUAL_ENV" ]]; then
        venvs+=("__deactivate__")
        display_names+=("🔌 Deactivate current venv")
    fi

    # Check if we found any venvs
    if [[ ${#venvs[@]} -eq 0 ]]; then
        echo "❌ No virtual environments found"
        return 1
    fi

    # If only one venv, use it directly
    if [[ ${#venvs[@]} -eq 1 ]]; then
        choice="${venvs[1]}"
    else
        # Multiple venvs - let user choose
        if command -v gum >/dev/null 2>&1; then
            local selected_display
            selected_display=$(printf '%s\n' "${display_names[@]}" | gum choose --height=8)
            # Find the corresponding venv path
            for i in {1..${#display_names[@]}}; do
                if [[ "${display_names[$i]}" == "$selected_display" ]]; then
                    choice="${venvs[$i]}"
                    break
                fi
            done
        else
            echo "Choose a virtual environment:"
            select choice in "${venvs[@]}"; do
                [[ -n "$choice" ]] && break
                echo "Invalid selection, try again."
            done
        fi
    fi

    # Handle the choice
    if [[ -z "$choice" ]]; then
        echo "❌ No environment selected"
        return 1
    elif [[ "$choice" == "__deactivate__" ]]; then
        # Deactivate current venv
        if command -v deactivate >/dev/null 2>&1; then
            deactivate
            echo "✅ Deactivated virtual environment"
        else
            echo "❌ No active virtual environment to deactivate"
            return 1
        fi
        return 0
    fi

    # Activate the chosen venv
    # Check for activate script (Unix or Windows style)
    local activate_script
    if [[ -f "$choice/bin/activate" ]]; then
        activate_script="$choice/bin/activate"
    elif [[ -f "$choice/Scripts/activate" ]]; then
        activate_script="$choice/Scripts/activate"
    else
        echo "❌ Cannot activate: no activate script found in $choice"
        return 1
    fi

    # Show current venv if one is active
    if [[ -n "$VIRTUAL_ENV" ]]; then
        echo "🔄 Switching from $(basename "$VIRTUAL_ENV") to $(basename "$choice")"
    fi

    source "$activate_script"
    echo "✅ Activated $(basename "$choice")"
}
