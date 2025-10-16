# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal Neovim configuration built with Lua, using the lazy.nvim plugin manager. The configuration is structured as a single comprehensive setup with modular organization.

## Architecture

### Core Structure

```
lua/
├── common/          # Shared utilities and assets
│   ├── ui/          # Icons and palette definitions
│   ├── snippets/    # LuaSnip snippets organized by filetype
│   ├── local_config.lua      # Local configuration loader
│   ├── keymap.lua            # Keymap utility wrapper
│   └── diagnostics-utils.lua # Custom diagnostic navigation
├── omareloui/       # Main configuration
│   ├── config/      # Core settings (options, keymaps, autocmds, theme)
│   ├── plugins/     # General plugin configurations
│   └── lsp/         # LSP-related configurations
│       ├── init.lua     # LSP setup using vim.lsp.enable()
│       └── plugins/     # LSP-adjacent plugins (conform, nvim-lint, blink.cmp, mason)
└── init.lua         # Entry point, requires omareloui.init
```

### Key Architectural Patterns

**Local Configuration System**: User-specific settings are externalized to `~/.config/nvim-local/localconfig.lua` (template at `localconfig.lua.example`). The `common/local_config.lua` module provides a `get(key, default)` function for retrieving nested values using dot notation (e.g., `"lsp.servers.gopls"`).

**Plugin Organization**: Plugins are split into two import groups:
- `omareloui.plugins`: General plugins (telescope, treesitter, oil, lualine, etc.)
- `omareloui.lsp.plugins`: LSP-related plugins (mason, conform, nvim-lint, blink.cmp, fidget)

**LSP Configuration**: Uses Neovim's native `vim.lsp.enable()` (available since 0.11) with per-server configuration via `vim.lsp.config()`. Server configurations, formatters, and linters are defined in `localconfig.lua`. The `LspAttach` autocmd in `lua/omareloui/lsp/init.lua` sets up keymaps and language-specific behaviors (ts_ls organize imports, gopls format on save).

**Keymap Utility**: `common/keymap.lua` provides `set(lhs, rhs, desc, opts)` which wraps `vim.keymap.set` with a description-first API for consistency.

**Diagnostic Navigation**: `common/diagnostics-utils.lua` provides custom `jump_next()` and `jump_prev()` functions that wrap to the first/last diagnostic and auto-open floats.

**Shared Assets**: Icons (`common/ui/icons.lua`) and color palette (`common/ui/palette.lua`) are centralized for consistency across plugins.

## Prerequisites

- `gcc` - For compiling Treesitter parsers and native plugins
- `lazygit` - Git UI integration
- `ripgrep` - Fast text search for Telescope
- `diff` - Required by various diff utilities

## Setup

Initial setup requires creating the local configuration:

```bash
mkdir -p ~/.config/nvim-local
cp localconfig.lua.example ~/.config/nvim-local/localconfig.lua
```

Edit `~/.config/nvim-local/localconfig.lua` to:
- Configure LSP servers under `lsp.servers` (key = server name, value = server-specific config table)
- Define formatters under `lsp.formatters_by_ft`
- Define linters under `lsp.linters_by_ft`
- Enable/disable Mason with `lsp.mason.enabled` (if true, Mason auto-installs all servers/formatters/linters)

## Plugin Management

- **Install/Update**: Open Neovim, lazy.nvim auto-installs on first launch
- **Lazy UI**: `:Lazy` - Plugin manager interface
- **Mason UI**: `:Mason` - LSP server/tool manager (only if enabled in localconfig)

## LSP Configuration

### Adding a New Language Server

1. Add server configuration to `~/.config/nvim-local/localconfig.lua`:
   ```lua
   lsp = {
     servers = {
       rust_analyzer = {
         settings = {
           ["rust-analyzer"] = {
             checkOnSave = { command = "clippy" }
           }
         }
       }
     }
   }
   ```

2. If using Mason, it will auto-install on next launch. Otherwise, install manually.

3. For language-specific LSP behaviors, modify the `LspAttach` autocmd in `lua/omareloui/lsp/init.lua`.

### Custom Filetypes

Custom filetype associations are defined in `lua/omareloui/lsp/init.lua` using `vim.filetype.add()`:
- `.templ` → `templ`
- `.mdx` → `markdown`
- `.j2` → `jinja`
- `*.component.html`, `*.container.html` → `htmlangular`
- Hyprland configs → `hyprlang`

## Theme Configuration

Current theme: Catppuccin (Mocha flavor)
- Configured in `lua/omareloui/config/theme.lua` and `lua/omareloui/plugins/catppuccin.lua`
- Supports transparent background when not running in Neovide

## Common Patterns

**Conditional Plugin Loading**: Check local config before enabling:
```lua
enabled = require("common.local_config").get("lsp.mason.enabled", false)
```

**Consistent UI**: Border style is "rounded" throughout (LSP floats, lazy.nvim, mason UI).

**Snippet Loading**: LuaSnip loads custom snippets from `lua/common/snippets/` organized by filetype.

## Notable Plugins

- **Telescope**: Fuzzy finder (files, grep, buffers, diagnostics)
- **Oil.nvim**: File explorer as a buffer
- **Treesitter**: Syntax highlighting and textobjects
- **Blink.cmp**: Completion engine with LuaSnip integration
- **Conform.nvim**: Formatting with formatters_by_ft from localconfig
- **nvim-lint**: Linting with linters_by_ft from localconfig
- **Gitsigns**: Git decorations and hunk operations
- **Harpoon**: Quick file navigation
- **Which-key**: Keymap popup
- **UFO**: Code folding with Treesitter/LSP integration
- **Zellij-nav**: Seamless navigation between Neovim and Zellij panes
