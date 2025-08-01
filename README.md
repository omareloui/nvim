# Neovim Config

## Prerequisites

- `gcc`
  For windows: `choco install mingw`
- `lazygit` <https://github.com/jesseduffield/lazygit>
  For windows: `winget install -e --id=JesseDuffield.lazygit`.
- `ripgrep` <https://github.com/BurntSushi/ripgrep>
  For windows: `winget install BurntSushi.ripgrep.MSVC`.
- `diff`
  For windows install from <https://gnuwin32.sourceforge.net/packages/diffutils.htm>.

## Setup

1. Clone the repository:

```bash
git clone git@github.com:omareloui/nvim --depth 1 ~/.config/nvim
# or for windows:
git clone git@github.com:omareloui/nvim --depth 1 ~/AppData/Local/nvim
```

Make sure to have to have the `localconfig.lua` in the right place.

```bash
cd ~/.config/nvim
mkdir -p ~/.config/nvim-local
cp localconfig.lua.example ~/.config/nvim-local/localconfig.lua
```

After that, you can edit `~/.config/nvim-local/localconfig.lua` to customize
your Neovim setup.
