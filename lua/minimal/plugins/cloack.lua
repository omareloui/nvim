return {
  "laytan/cloak.nvim",
  event = { "BufReadPost", "BufWritePost", "BufNewFile" },
  config = {
    enabled = true,
    cloak_character = "*",
    highlight_group = "Comment",
    patterns = {
      {
        file_pattern = {
          ".env*",
          "wrangler.toml",
          ".dev.vars",
        },
        cloak_pattern = { "=.+" },
      },
    },
  },
}
