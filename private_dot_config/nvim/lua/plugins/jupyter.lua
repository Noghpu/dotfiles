-- in lua/plugins/quarto.lua
return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0", -- use version <2.0.0 to avoid breaking changes
    dependencies = {
      -- "3rd/image.nvim",
    },
    lazy = true,
    ft = { "quarto", "markdown", ".ipynb" },
    build = ":UpdateRemotePlugins",
    init = function()
      -- vim.g.molten_image_provider = "image.nvim"
    end,
    keys = {
      {
        "<leader>ji",
        ":MoltenInit<CR>",
        mode = "n",
        desc = "Molten {I}nit Kernel",
        silent = true,
      },
      {
        "<leader>jh",
        ":MoltenHideOutput<CR>",
        mode = "n",
        desc = "Molten {H}ide Output",
        silent = true,
      },
      {
        "<leader>jo",
        ":noautocmd MoltenEnterOutput<CR>",
        mode = "n",
        desc = "Enter {O}utput",
        silent = true,
      },
      {
        "<leader>j",
        "",
        mode = "n",
        desc = "Jupyter",
        silent = true,
      },
    },
  },
  {
    -- send code from python/r/qmd documets to a terminal or REPL
    -- like ipython, R, bash
    "jpalardy/vim-slime",
    dev = false,
    lazy = true,
    ft = { "quarto" },
    init = function()
      vim.b["quarto_is_python_chunk"] = false
      Quarto_is_in_python_chunk = function()
        require("otter.tools.functions").is_otter_language_context("python")
      end

      vim.cmd([[
        let g:newline = has('win32') ? "\r" : "\n"
        let g:slime_dispatch_ipython_pause = 100
        function SlimeOverride_EscapeText_quarto(text)
          call v:lua.Quarto_is_in_python_chunk()
            if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk && !(exists('b:quarto_is_r_mode') && b:quarto_is_r_mode)
              return ["%cpaste -q", g:newline, g:slime_dispatch_ipython_pause, a:text, "--", g:newline]
            else if exists('b:quarto_is_r_mode') && b:quarto_is_r_mode && b:quarto_is_python_chunk
              return [a:text, g:newline]
            else
              return [a:text]
            end
          end
        endfunction
      ]])

      vim.g.slime_target = "neovim"
      vim.g.slime_no_mappings = true
      vim.g.slime_python_ipython = 1
    end,
    config = function()
      vim.g.slime_input_pid = false
      vim.g.slime_suggest_default = true
      vim.g.slime_menu_config = false
      vim.g.slime_neovim_ignore_unlisted = true
    end,
  },
  {
    "jmbuhr/otter.nvim",
    dev = false,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
    },
    lazy = true,
    ft = { "quarto" },
    opts = {
      buffers = {
        set_filetype = true,
      },
      handle_leading_whitespace = true,
    },
  },
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
    },
    dev = false,
    lazy = true,
    ft = { "quarto" },
    opts = {
      lspFeatures = {
        enabled = true,
        languages = { "r", "python", "julia" },
        diagnostics = {
          enabled = true,
          triggers = { "BufWritePost" },
        },
        completion = {
          enabled = true,
        },
      },
      codeRunner = {
        enabled = true,
        default_method = "slime",
      },
      keymap = {
        format = "<leader>jf",
      },
    },
  },
  { -- directly open ipynb files as quarto docuements
    -- and convert back behind the scenes
    "GCBallesteros/jupytext.nvim",
    lazy = false,
    ft = { "markdown", "quarto", "norg" },
    opts = {
      custom_language_formatting = {
        python = {
          extension = "qmd",
          style = "quarto",
          force_ft = "quarto",
        },
        r = {
          extension = "qmd",
          style = "quarto",
          force_ft = "quarto",
        },
      },
    },
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = true,
    ft = { "markdown", "quarto" },
    modes = nil,
    initial_state = false,
    debounce = 200,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
  },
}
