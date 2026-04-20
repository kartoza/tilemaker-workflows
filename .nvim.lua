-- Tilemaker Workflows — Neovim project-local configuration

-- Lua LSP settings for tilemaker globals
local lspconfig_ok, lspconfig = pcall(require, "lspconfig")
if lspconfig_ok then
  local lua_ls = lspconfig.lua_ls
  if lua_ls then
    lua_ls.setup({
      settings = {
        Lua = {
          runtime = { version = "Lua 5.1" },
          diagnostics = {
            globals = {
              -- Tilemaker callback functions
              "init_function",
              "exit_function",
              "node_function",
              "way_function",
              "relation_scan_function",
              "attribute_function",
              -- Tilemaker global variables
              "node_keys",
              -- Tilemaker API functions
              "Find",
              "FindInRelation",
              "Holds",
              "Accept",
              "NextRelation",
              "Layer",
              "LayerMinZoom",
              "MinZoom",
              "Attribute",
              "AttributeNumeric",
              "AttributeBoolean",
              "ZOrder",
              "Id",
              "IsClosed",
              "Area",
              "Length",
              "Centroid",
            },
          },
          workspace = {
            checkThirdParty = false,
          },
        },
      },
    })
  end
end

-- File type associations
vim.filetype.add({
  extension = {
    lua = "lua",
  },
  filename = {
    [".luacheckrc"] = "lua",
  },
})

-- Project-specific editor settings
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4

-- Auto-format nix files on save (if nixfmt is available)
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.nix",
  callback = function()
    if vim.fn.executable("nixfmt") == 1 then
      vim.lsp.buf.format({ async = false })
    end
  end,
  group = vim.api.nvim_create_augroup("TilemakerNixFmt", { clear = true }),
})
