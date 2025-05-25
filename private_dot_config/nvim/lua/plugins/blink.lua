return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "jmbuhr/otter.nvim",
    },
    -- version = "v0.9.*",
    opts = {
      keymap = {
        preset = "default",
        ["<DOWN>"] = {},
        ["<UP>"] = {},
        ["<LEFT>"] = {},
        ["<RIGHT>"] = {},
      },
      completion = {
        ghost_text = {
          enabled = false,
        },
      },
    },
  },
}
