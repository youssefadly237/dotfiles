# dotfiles

I'm just saving some configs so I don't have to redo everything later.
Not perfect, but works for me.

These dotfiles utilizes [`twpayne/chezmoi`](https://github.com/twpayne/chezmoi)
go give em a star

---

## Includes

- [alacritty](./dot_config/alacritty/)
- [fuzzel](./dot_config/fuzzel/)
- [inkscape](./dot_config/inkscape/)
- [kitty](./dot_config/kitty/)
- [mako](./dot_config/mako/)
- [neomutt](./dot_config/neomutt/)
- [Neovim](./dot_config/nvim/README.md)
- [niri](./dot_config/niri/)
- [pipewire](./dot_config/pipewire/)
- [swaylock](./dot_config/swaylock/)
- [taskbeep](./dot_config/taskbeep/)
- [waybar](./dot_config/waybar/)
- [Xournal++](./dot_config/xournalpp/)
- [Starship](./dot_config/starship.toml)
- [tmux](./dot_tmux.conf)
- [zsh](./dot_zshrc)

## Installation

1. install [`chezmoi`](https://www.chezmoi.io/install/)
2. initialize with this repo

   ```bash
   chezmoi init https://github.com/youssefadly237/dotfiles.git
   ```

3. apply the parts you need or do full apply if you want
   - for a partial install (only single software (e.g. Xournal++))

     ```bash
     chezmoi apply ~/.config/xournalpp
     ```

   - for full install

     ```bash
     chezmoi apply
     ```

---

## License

MIT, it is just dotfiles
