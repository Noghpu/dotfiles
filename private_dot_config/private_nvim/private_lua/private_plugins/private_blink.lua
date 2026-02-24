return {
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "default",
        ["<Down>"] = {},
        ["<Up>"] = {},
        ["<Left>"] = {},
        ["<Right>"] = {},
      },
      completion = {
        ghost_text = { enabled = false },
        trigger = { prefetch_on_insert = false },
      },
      sources = {
        default = { "lsp", "buffer", "path", "snippets" },
      },
    },
  },
}
