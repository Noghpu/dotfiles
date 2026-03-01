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
	-- Configure pyrefly, ty, and ruff LSPs
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				-- pyrefly type checker
				pyrefly = {
					init_options = {
						pyrefly = {
							displayTypeErrors = "force-on",
							disableLanguageServices = false,
							analysis = {
								diagnosticMode = "workspace",
								inlayHints = {
									callArgumentNames = "off",
									functionReturnTypes = true,
									pytestParameters = false,
									variableTypes = true,
								},
							},
						},
					},
				},
				-- ty type checker (disabled, :LspStart ty to activate)
				ty = {
					settings = {
						ty = {
							diagnosticMode = "workspace",
							inlayHints = {
								variableTypes = true,
								callArgumentNames = true,
							},
							configuration = {
								rules = {
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
				-- ruff linter/formatter LSP — mirrors ruff.toml as fallback
				ruff = {
					on_attach = function(client)
						client.server_capabilities.hoverProvider = false
					end,
					init_options = {
						settings = {
							configurationPreference = "filesystemFirst",
							lineLength = 88,
							targetVersion = "py313",
							lint = {
								preview = true,
								select = { "ALL" },
								ignore = {
									-- async: trio/anyio-only rules
									"ASYNC105",
									"ASYNC115",
									"ASYNC116",
									"ASYNC212",
									"ASYNC230",
									"ASYNC240",
									-- blanket exceptions
									"BLE001",
									-- complexity
									"C90",
									-- trailing commas (formatter handles)
									"COM812",
									"COM819",
									-- copyright
									"CPY001",
									-- docstrings
									"D",
									"D1",
									"D203",
									"D212",
									"D213",
									"D401",
									"DOC",
									-- indentation (formatter handles)
									"E111",
									"E114",
									"E117",
									-- lambda assignment
									"E731",
									-- exception message style
									"EM101",
									"EM102",
									"EM103",
									-- boolean traps
									"FBT001",
									"FBT002",
									"FBT003",
									-- fixmes/todos
									"FIX",
									-- f-string in logging
									"G004",
									-- implicit string concat (formatter handles)
									"ISC001",
									-- private import
									"PLC2701",
									-- too-many-* and magic numbers
									"PLR0",
									"PLR2004",
									-- return style
									"RET504",
									"RET505",
									"RET508",
									-- assert
									"S101",
									-- security: pickle, hashing, ciphers, xml, ssl, etc.
									"S301",
									"S303",
									"S304",
									"S305",
									"S308",
									"S313",
									"S314",
									"S315",
									"S316",
									"S317",
									"S318",
									"S319",
									"S323",
									"S324",
									"S404",
									"S501",
									"S502",
									"S506",
									"S507",
									"S601",
									"S603",
									"S608",
									"S610",
									"S611",
									"S701",
									"S702",
									"S704",
									-- suppressible-exception
									"SIM105",
									-- private member access
									"SLF001",
									-- todos
									"TD",
									-- raise-vanilla-args
									"TRY003",
									-- tab indentation
									"W191",
								},
								fixable = { "ALL" },
								unfixable = {},
								["extend-safe-fixes"] = {
									"F401",
									"TCH",
									"UP",
									"B006",
									"EM",
									"RUF013",
									"TID252",
									"PLR6201",
									"RUF038",
									"ERA001",
									"ARG005",
								},
								["per-file-ignores"] = {
									["tests/*"] = { "S101", "ARG", "ANN", "TID252" },
									["__init__.py"] = { "F401" },
								},
								["flake8-tidy-imports"] = {
									["ban-relative-imports"] = "all",
								},
								["flake8-comprehensions"] = {
									["allow-dict-calls-with-keyword-arguments"] = true,
								},
							},
						},
					},
				},
			},
			setup = {
				ty = function(server, sopts)
					vim.lsp.config(server, sopts)
					return true -- skip auto-enable, use :LspStart ty
				end,
			},
		},
	},
	-- Ensure mason installs the tools
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = {
				"pyrefly",
				"ty",
				"ruff",
			},
		},
	},
}
