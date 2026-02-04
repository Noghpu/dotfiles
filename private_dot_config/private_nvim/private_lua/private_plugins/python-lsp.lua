return {
  -- Disable basedpyright (LazyVim's default when lazyvim_python_lsp is set)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = { enabled = false },
        pyright = { enabled = false },
      },
    },
  },
  -- Configure ty and ruff LSPs
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- ty type checker (strict settings)
        ty = {
          settings = {
            ty = {
              -- Enable workspace-wide diagnostics
              diagnosticMode = "workspace",
              -- Enable inlay hints
              inlayHints = {
                variableTypes = true,
                callArgumentNames = true,
              },
              -- Strict rule configuration
              configuration = {
                rules = {
                  -- Enable warning-level rules as errors for strictness
                  ["possibly-unresolved-reference"] = "error",
                  ["division-by-zero"] = "warn",
                  ["deprecated"] = "error",
                  ["ambiguous-protocol-member"] = "error",
                  ["ineffective-final"] = "error",
                },
              },
            },
          },
        },
        -- ruff as linter LSP (strict settings)
        ruff = {
          init_options = {
            settings = {
              lint = {
                select = {
                  -- Core Python errors (highly recommended)
                  "E", -- pycodestyle errors
                  "F", -- Pyflakes (undefined names, unused imports, etc.)
                  -- "W", -- pycodestyle warnings

                  -- Bug detection
                  "B", -- flake8-bugbear (common bugs and design problems)
                  "S", -- flake8-bandit (security issues)
                  "A", -- flake8-builtins (shadowing builtins)

                  -- Code quality
                  "C4", -- flake8-comprehensions (unnecessary comprehensions)
                  "C90", -- mccabe (complexity checker)
                  "N", -- pep8-naming (naming conventions)
                  "UP", -- pyupgrade (upgrade syntax for newer Python)
                  "RUF", -- Ruff-specific rules

                  -- Import organization
                  "I", -- isort (import sorting)
                  "ICN", -- flake8-import-conventions
                  "TID", -- flake8-tidy-imports

                  -- Type checking related
                  "ANN", -- flake8-annotations (type annotation presence)
                  "TCH", -- flake8-type-checking (TYPE_CHECKING blocks)

                  -- Documentation
                  -- "D", -- pydocstyle (docstring style)

                  -- Code style
                  -- "Q", -- flake8-quotes
                  -- "COM", -- flake8-commas (trailing commas)
                  -- "ISC", -- flake8-implicit-str-concat

                  -- Error handling
                  "EM", -- flake8-errmsg (exception messages)
                  "TRY", -- tryceratops (exception handling)
                  "RSE", -- flake8-raise

                  -- Logging
                  "LOG", -- flake8-logging
                  "G", -- flake8-logging-format

                  -- Testing
                  "PT", -- flake8-pytest-style

                  -- Simplification
                  "SIM", -- flake8-simplify
                  "PIE", -- flake8-pie (misc. lints)

                  -- Return statements
                  "RET", -- flake8-return

                  -- Unused code
                  "ARG", -- flake8-unused-arguments
                  "ERA", -- eradicate (commented-out code)

                  -- Pathlib
                  "PTH", -- flake8-use-pathlib

                  -- Async
                  "ASYNC", -- flake8-async

                  -- Slots
                  "SLOT", -- flake8-slots

                  -- Performance
                  "PERF", -- Perflint

                  -- Refactoring
                  "FURB", -- refurb (modernization)
                  "PL", -- Pylint rules (PLC, PLE, PLR, PLW)

                  -- Print statements (comment out if you use print for debugging)
                  -- "T20", -- flake8-print

                  -- Debugging (comment out during development)
                  -- "T10",  -- flake8-debugger (debugger statements)

                  -- Boolean trap (can be noisy)
                  -- "FBT",  -- flake8-boolean-trap

                  -- Magic values (can be noisy)
                  -- "PLR2004", -- magic-value-comparison

                  -- Blanket exceptions (can be noisy)
                  -- "BLE",  -- flake8-blind-except

                  -- Self usage (can be noisy)
                  -- "SLF",  -- flake8-self

                  -- Pandas specific (enable if using pandas)
                  -- "PD",   -- pandas-vet

                  -- NumPy specific (enable if using numpy)
                  -- "NPY",  -- NumPy-specific rules

                  -- Django specific (enable if using Django)
                  -- "DJ",   -- flake8-django

                  -- FastAPI specific (enable if using FastAPI)
                  -- "FAST", -- FastAPI rules

                  -- Airflow specific (enable if using Airflow)
                  -- "AIR",  -- Airflow rules
                },
                ignore = {
                  "D203", -- conflicts with D211 (blank line before class docstring)
                  "D213", -- conflicts with D212 (multi-line docstring summary)
                  -- "E501",  -- line too long (handled by formatter)
                  "W191", -- tab-indentation
                  "E111", -- indentation-with-invalid-multiple
                  "E114", -- indentation-with-invalid-multiple-comment
                  "E117", -- over-indented
                  "Q000", -- bad-quotes-inline-string
                  "Q001", -- bad-quotes-multiline-string
                  "Q002", -- bad-quotes-docstring
                  "Q003", -- avoidable-escaped-quote
                  "COM812", -- missing-trailing-comma
                  "COM819", -- prohibited-trailing-comma
                  "ISC001", -- single-line-implicit-string-concatenation
                },
              },
            },
          },
        },
      },
    },
  },
  -- Ensure mason installs the tools
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "ty",
        "ruff",
      },
    },
  },
}
