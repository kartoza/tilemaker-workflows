-- Luacheck configuration for Tilemaker Lua scripts
-- Tilemaker provides these as global functions/variables to processing scripts

-- Allow setting these globals (tilemaker callbacks and user-defined globals)
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

  -- User-defined globals used across functions in process.lua
  "preferred_language",
  "preferred_language_attribute",
  "default_language_attribute",
  "additional_languages",
  "Set",
  "ZRES5", "ZRES6", "ZRES7", "ZRES8", "ZRES9", "ZRES10", "ZRES11", "ZRES12", "ZRES13",
  "BUILDING_FLOOR_HEIGHT",
  "aerodromeValues",
  "pavedValues", "unpavedValues",
  "capitalLevel", "calcRank",
  "majorRoadValues", "mainRoadValues", "midRoadValues", "minorRoadValues",
  "trackValues", "pathValues", "linkValues", "constructionValues",
  "aerowayBuildings", "landuseKeys", "landcoverKeys",
  "poiTags", "poiClasses", "poiSubClasses", "poiClassRanks",
  "waterClasses", "waterwayClasses",
  "write_to_transportation_layer",
  "WritePOI", "SetNameAttributes", "SetEleAttributes", "SetBrunnelAttributes",
  "SetMinZoomByArea", "SetBuildingHeightAttributes", "SetZOrder", "GetPOIRank",
  "split",
  "splitHighway", "subclassKey", "iname", "i",
  "highway", "service",
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
  "LayerAsCentroid",
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

  -- Tilemaker utility
  "way",
}

-- Allow long lines in data tables
max_line_length = false

-- Ignore pre-existing code style warnings in upstream-derived process.lua
-- 211 = unused variable, 212 = unused argument, 213 = unused loop variable
-- 311 = value assigned but unused, 431 = variable shadowing
-- 532 = value overwritten before use, 581 = negation of == (style preference)
-- 61 = inconsistent indentation
ignore = { "21", "31", "4", "5" }

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
