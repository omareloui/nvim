return {
  "tadaa/vimade",
  opts = {
    recipe = { "minimalist", { animate = true } },
    ncmode = "windows",
    fadelevel = 0.6,
    blocklist = {
      my_rule = {
        buf_opts = {
          ft = { "oil", "qf" },
        },
      },
    },
  },
}
