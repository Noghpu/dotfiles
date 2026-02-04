return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        quarto = { "injected" },
        python = { "ruff_format", "ruff_fix", "ruff_organize_imports" },
      },
      formatters = {
        injected = {
          options = {
            ignore_errors = false,
            lang_to_ext = {
              bash = "sh",
              c_sharp = "cs",
              elixir = "exs",
              javascript = "js",
              julia = "jl",
              latex = "tex",
              markdown = "md",
              quarto = "wmd",
              python = "py",
              ruby = "rb",
              rust = "rs",
              teal = "tl",
              r = "r",
              typescript = "ts",
            },
          },
        },
      },
    },
  },
}
