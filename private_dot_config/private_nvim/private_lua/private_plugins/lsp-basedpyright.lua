return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      basedpyright = {
        settings = {
          basedpyright = {
            disableOrganizeImports = true,
            analysis = {
              typeCheckingMode = "strict",
            },
          },
        },
      },
      ruff = {
        settings = { logLevel = "debug" },
      },
    },
  },
}
