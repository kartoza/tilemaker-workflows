-- Luacheck configuration for Tilemaker Lua scripts
-- Tilemaker provides these as global functions/variables to processing scripts

globals = {
  -- Tilemaker callback functions (defined by user, called by tilemaker)
  "init_function",
  "exit_function",
  "node_function",
  "way_function",
  "relation_scan_function",
  "attribute_function",

  -- Tilemaker global variables
  "node_keys",
}

read_globals = {
  -- Tilemaker tag reading functions
  "Find",
  "FindInRelation",
  "Holds",
  "Accept",
  "NextRelation",

  -- Tilemaker output functions
  "Layer",
  "LayerMinZoom",
  "MinZoom",
  "Attribute",
  "AttributeNumeric",
  "AttributeBoolean",
  "ZOrder",

  -- Tilemaker geometry functions
  "Id",
  "IsClosed",
  "Area",
  "Length",
  "Centroid",
}

-- Allow long lines in data tables
max_line_length = 200

-- Neovim Lua files use the vim global
files[".nvim.lua"] = {
  globals = {
    vim = { fields = { "opt_local", "api", "fn", "lsp", "filetype", "keymap" } },
  },
  read_globals = { "vim" },
}

files[".exrc"] = {
  read_globals = { "vim" },
  globals = { "vim" },
}
