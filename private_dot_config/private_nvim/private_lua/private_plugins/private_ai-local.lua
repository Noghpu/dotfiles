return {
  {
    "milanglacier/minuet-ai.nvim",
    event = "InsertEnter",
    cmd = "Minuet",
    opts = {
      provider = "openai_fim_compatible",
      n_completions = 1,
      context_window = 8192,
      request_timeout = 3,
      throttle = 400,
      debounce = 120,
      provider_options = {
        openai_fim_compatible = {
          api_key = "APPDATA",
          name = "Ollama",
          end_point = "http://10.2.118.173:11434/v1/completions",
          model = "qwen2.5-coder:7b",
          stream = true,
          optional = {
            max_tokens = 128,
            top_p = 0.9,
            temperature = 0.2,
            stop = { "\n\n" },
          },
        },
      },
      presets = {
        code9b = {
          provider = "openai_fim_compatible",
          context_window = 8192,
          provider_options = {
            openai_fim_compatible = {
              api_key = "APPDATA",
              name = "Ollama coder 7B",
              end_point = "http://10.2.118.173:11434/v1/completions",
              model = "qwen2.5-coder:7b",
              stream = true,
              optional = {
                max_tokens = 128,
                top_p = 0.9,
                temperature = 0.2,
                stop = { "\n\n" },
              },
            },
          },
        },
        moe = {
          provider = "openai_fim_compatible",
          context_window = 8192,
          provider_options = {
            openai_fim_compatible = {
              api_key = "APPDATA",
              name = "Ollama coder 7B",
              end_point = "http://10.2.118.173:11434/v1/completions",
              model = "qwen2.5-coder:7b",
              stream = true,
              optional = {
                max_tokens = 128,
                top_p = 0.9,
                temperature = 0.2,
                stop = { "\n\n" },
              },
            },
          },
        },
      },
    },
  },
  {
    "olimorris/codecompanion.nvim",
    cmd = {
      "CodeCompanion",
      "CodeCompanionActions",
      "CodeCompanionChat",
      "CodeCompanionCLI",
      "CodeCompanionCmd",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      strategies = {
        chat = { adapter = "local_moe" },
        inline = { adapter = "local_moe" },
        cmd = { adapter = "local_moe" },
      },
      adapters = {
        http = {
          local_moe = function()
            return require("codecompanion.adapters").extend("ollama", {
              env = {
                url = "http://10.2.118.173:11434",
              },
              schema = {
                model = { default = "qwen3.5:27b" },
                think = { default = false },
                temperature = { default = 0.7 },
                num_ctx = { default = 262144 },
                num_predict = { default = 32768 },
                top_k = { default = 20 },
                top_p = { default = 0.8 },
                min_p = { default = 0 },
                repeat_penalty = { default = 1.1 },
              },
            })
          end,
          local_dense27b = function()
            return require("codecompanion.adapters").extend("ollama", {
              env = {
                url = "http://10.2.118.173:11434",
              },
              schema = {
                model = { default = "qwen3.5:27b" },
                think = { default = false },
                temperature = { default = 0.7 },
                num_ctx = { default = 262144 },
                num_predict = { default = 32768 },
                top_k = { default = 20 },
                top_p = { default = 0.8 },
                min_p = { default = 0 },
                repeat_penalty = { default = 1.1 },
              },
            })
          end,
          local_code9b = function()
            return require("codecompanion.adapters").extend("openai_compatible", {
              env = {
                url = "http://10.2.118.173:11434/v1",
                api_key = "APPDATA",
              },
              schema = {
                model = { default = "qwen2.5-coder:7b" },
                temperature = { default = 0.2 },
                max_tokens = { default = 1024 },
              },
            })
          end,
        },
      },
    },
  },
}
