# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Neovim configuration built with Lua, using the lazy.nvim plugin manager. The configuration supports two modes:
- **Full configuration** (`omareloui`): Feature-rich setup with extensive LSP, DAP, and plugin integrations
- **Minimal configuration** (`minimal`): Lightweight setup with essential features only

The active configuration is controlled in `init.lua` by requiring either `omareloui.config.lazy` or `minimal`.

## Architecture

### Configuration Structure

```
lua/
├── common/          # Shared code between configurations (icons, palette, snippets)
├── minimal/         # Minimal Neovim setup
│   ├── config/      # Options, keymaps, theme
│   ├── lsp/         # LSP configuration using vim.lsp.enable()
│   └── plugins/     # Essential plugins only
└── omareloui/       # Full-featured configuration
    ├── config/      # Core config (options, keymaps, autocmds, theme, snippets, UI)
    ├── plugins/     # Plugin configurations (general, lsp/, dap/)
    └── util/        # Utility modules (keymap, local_config, diagnostics-utils, etc.)
```

### Key Components

**Local Configuration System**: Configuration is externalized via
`~/.config/nvim-local/localconfig.lua` (see `localconfig.lua.example`). The
`lua/omareloui/util/local_config.lua` module loads this file and provides a
`get(key, default)` function for retrieving nested config values.

**Plugin Loading**:
- Full config uses lazy.nvim with three import groups: `omareloui.plugins`,
`omareloui.plugins.lsp`, and `omareloui.plugins.dap`
- Minimal config imports `minimal.plugins` and `minimal.lsp.plugins`
- Many plugins check `localconfig.get()` to determine if they should be enabled

**LSP Configuration**:
- Full config (`lua/omareloui/plugins/lsp/lspconfig.lua`): Uses nvim-lspconfig
with modular language server configs in `lua/omareloui/plugins/lsp/lang/*.lua`.
Each language file returns `{ enabled = true/false, setup = function(lspconfig,
on_attach, capabilities) }`.
- Minimal config (`lua/minimal/lsp/init.lua`): Uses Neovim's built-in
`vim.lsp.enable()` for simple LSP setup without external plugins

**Keymap Utility**: `lua/omareloui/util/keymap.lua` provides a `set(lhs, rhs,
desc, opts)` function that wraps `vim.keymap.set` with description-first API.

## Prerequisites

- `gcc` (for compiling Treesitter parsers and plugins)
- `lazygit` - Git UI integration
- `ripgrep` - Fast text search (used by Telescope)
- `diff` - Diff utilities

## Setup

Initial setup requires creating the local config:

```bash
mkdir -p ~/.config/nvim-local
cp localconfig.lua.example ~/.config/nvim-local/localconfig.lua
```

Edit `~/.config/nvim-local/localconfig.lua` to:
- Enable/disable Mason plugin and specify LSP servers/tools to install
- Configure system package paths (e.g., `vue_lsp`, `omnisharp_dll`)

## Plugin Management

- **Install/Update plugins**: Open Neovim, lazy.nvim will auto-install on first launch
- **Lazy UI**: `:Lazy` - Open plugin manager UI
- **Mason UI**: `:Mason` - Manage LSP servers, linters, formatters (only if enabled in localconfig)

## Working with LSP

### Adding a New Language Server (Full Config)

1. Create `lua/omareloui/plugins/lsp/lang/<language>.lua`:
   ```lua
   return {
     enabled = true,
     setup = function(lspconfig, on_attach, capabilities)
       lspconfig.<server_name>.setup {
         on_attach = on_attach,
         capabilities = capabilities,
         -- Additional config
       }
     end,
   }
   ```

2. Add `"<language>"` to `language_server_to_load` array in `lua/omareloui/plugins/lsp/lspconfig.lua`

3. If using Mason, add server to `ensure_installed` in `~/.config/nvim-local/localconfig.lua`

### Adding a New Language Server (Minimal Config)

Simply add the server name to the array in `vim.lsp.enable()` call in `lua/minimal/lsp/init.lua`.

## Common Patterns

**Conditional Plugin Loading**: Plugins often check local config:
```lua
enabled = localconfig.get("plugins.mason.enabled", false)
```

**Plugin Detection**: Use `require("omareloui.util.has_plugin")("plugin-name")` to check if a plugin is loaded before configuring integrations.

**UI Consistency**: Border style is set to "rounded" throughout (LSP windows, lazy.nvim UI, etc.)

**Filetype Extensions**: Custom filetypes are registered in `lspconfig.lua` and `minimal/lsp/init.lua` using `vim.filetype.add()` (e.g., `.templ`, `.j2`, Angular component templates).

## Theme Configuration

Current theme: Catppuccin (Mocha flavor)
- Full config: Set in `lua/omareloui/config/theme.lua` and configured in `lua/omareloui/plugins/themes.lua`
- Minimal config: Set in `lua/minimal/config/theme.lua`
- Supports transparent background when not running in Neovide

## Testing and Debugging

The full configuration includes DAP (Debug Adapter Protocol) support with configurations in `lua/omareloui/plugins/dap/`.
