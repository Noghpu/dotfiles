return {
  {
    "nvim-treesitter/nvim-treesitter",

    opts = function(_, opts)
      local treesitter = require("nvim-treesitter.install")
      treesitter.prefer_git = false
      opts.textobjects.move.goto_next_start["]j"] = { query = "@code_cell.inner" }
      opts.textobjects.move.goto_previous_start["[j"] = { query = "@code_cell.inner" }
      opts.textobjects.move.goto_next_start["<leader>jj"] = { query = "@code_cell.inner" }
      opts.textobjects.move.goto_previous_start["<leader>jk"] = { query = "@code_cell.inner" }

      if opts.textobjects.select == nil then
        opts.textobjects.select = { keymaps = {} }
      end
      opts.textobjects.select.keymaps["ij"] = { query = "@code_cell.inner", desc = "In Code Block" }
      opts.textobjects.select.keymaps["aj"] = { query = "@code_cell.outer", desc = "Around Code Block" }
      opts.textobjects.select.enable = true
      opts.textobjects.select.lookahead = true

      if opts.textobjects.swap == nil then
        opts.textobjects.swap = { swap_next = {}, swap_previous = {} }
      end
      opts.textobjects.swap.swap_next["<leader>sbl"] = { query = "@code_cell.outer", desc = "Swap Block" }
      opts.textobjects.swap.swap_previous["<leader>sbh"] = { query = "@code_cell.outer", desc = "Around Code Block" }
      opts.textobjects.swap.enable = true
    end,
  },
}
