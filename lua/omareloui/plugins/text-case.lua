return {
  "johmsalas/text-case.nvim",
  config = function()
    local textcase = require "textcase"
    local opts = {}
    textcase.setup(opts)

    local set = require("common.keymap").set

    local function cb(fn, arg)
      return function()
        return fn(arg)
      end
    end

    set("<leader>ss", ":'<,'>Subs/\\<<C-r><C-w>\\>//<Left>", "Replace highlighted word", { mode = { "v" } })
    set("<leader>ss", ":Subs/\\<<C-r><C-w>\\>//gI<Left><Left><Left>", "Replace highlighted word")

    set("gau", cb(textcase.current_word, "to_upper_case"), "Convert current word to upper case")
    set("gal", cb(textcase.current_word, "to_lower_case"), "Convert current word to lower case")
    set("gas", cb(textcase.current_word, "to_snake_case"), "Convert current word to snake case")
    set("gad", cb(textcase.current_word, "to_dash_case"), "Convert current word to dash case")
    set("gan", cb(textcase.current_word, "to_constant_case"), "Convert current word to constant case")
    set("gao", cb(textcase.current_word, "to_dot_case"), "Convert current word to dot case")
    set("ga,", cb(textcase.current_word, "to_comma_case"), "Convert current word to comma case")
    set("gaa", cb(textcase.current_word, "to_phrase_case"), "Convert current word to phrase case")
    set("gac", cb(textcase.current_word, "to_camel_case"), "Convert current word to camel case")
    set("gap", cb(textcase.current_word, "to_pascal_case"), "Convert current word to pascal case")
    set("gat", cb(textcase.current_word, "to_title_case"), "Convert current word to title case")
    set("gaf", cb(textcase.current_word, "to_path_case"), "Convert current word to path case")

    set("gaU", cb(textcase.lsp_rename, "to_upper_case"), "LSP rename to upper case")
    set("gaL", cb(textcase.lsp_rename, "to_lower_case"), "LSP rename to lower case")
    set("gaS", cb(textcase.lsp_rename, "to_snake_case"), "LSP rename to snake case")
    set("gaD", cb(textcase.lsp_rename, "to_dash_case"), "LSP rename to dash case")
    set("gaN", cb(textcase.lsp_rename, "to_constant_case"), "LSP rename to constant case")
    set("gaO", cb(textcase.lsp_rename, "to_dot_case"), "LSP rename to dot case")
    set("ga<", cb(textcase.lsp_rename, "to_comma_case"), "LSP rename to comma case")
    set("gaA", cb(textcase.lsp_rename, "to_phrase_case"), "LSP rename to phrase case")
    set("gaC", cb(textcase.lsp_rename, "to_camel_case"), "LSP rename to camel case")
    set("gaP", cb(textcase.lsp_rename, "to_pascal_case"), "LSP rename to pascal case")
    set("gaT", cb(textcase.lsp_rename, "to_title_case"), "LSP rename to title case")
    set("gaF", cb(textcase.lsp_rename, "to_path_case"), "LSP rename to path case")

    set("geu", cb(textcase.operator, "to_upper_case"), "Operator to upper case")
    set("gel", cb(textcase.operator, "to_lower_case"), "Operator to lower case")
    set("ges", cb(textcase.operator, "to_snake_case"), "Operator to snake case")
    set("ged", cb(textcase.operator, "to_dash_case"), "Operator to dash case")
    set("gen", cb(textcase.operator, "to_constant_case"), "Operator to constant case")
    set("geo", cb(textcase.operator, "to_dot_case"), "Operator to dot case")
    set("ge,", cb(textcase.operator, "to_comma_case"), "Operator to comma case")
    set("gea", cb(textcase.operator, "to_phrase_case"), "Operator to phrase case")
    set("gec", cb(textcase.operator, "to_camel_case"), "Operator to camel case")
    set("gep", cb(textcase.operator, "to_pascal_case"), "Operator to pascal case")
    set("get", cb(textcase.operator, "to_title_case"), "Operator to title case")
    set("gef", cb(textcase.operator, "to_path_case"), "Operator to path case")
  end,
}
