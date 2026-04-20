" Tilemaker Workflows — Neovim project shortcuts
" All shortcuts under <leader>p (Project)

lua << EOF
local ok, wk = pcall(require, "which-key")
if ok then
  wk.add({
    { "<leader>p",  group = "Project (Tilemaker)" },

    -- Data & Processing
    { "<leader>pd", "<cmd>split | terminal ./get_data.sh<cr>",               desc = "Download geodata" },
    { "<leader>pm", "<cmd>split | terminal ./process_malta.sh<cr>",          desc = "Process Malta" },
    { "<leader>pp", "<cmd>split | terminal ./process_planet.sh<cr>",         desc = "Process planet" },
    { "<leader>pc", "<cmd>split | terminal nix run .#coastline<cr>",         desc = "Process coastline" },

    -- Serving & Editing
    { "<leader>ps", "<cmd>split | terminal ./run_server.sh<cr>",             desc = "Start tile server" },
    { "<leader>pe", "<cmd>split | terminal ./run_maputnik_editor.sh<cr>",    desc = "Maputnik editor" },

    -- Quality
    { "<leader>pl", "<cmd>split | terminal nix run .#lint<cr>",              desc = "Run linters" },
    { "<leader>pf", "<cmd>!nix fmt<cr>",                                     desc = "Format nix files" },
    { "<leader>pt", "<cmd>split | terminal pre-commit run --all-files<cr>",  desc = "Pre-commit checks" },

    -- Documentation
    { "<leader>pr", "<cmd>edit README.md<cr>",                               desc = "Open README" },
    { "<leader>pS", "<cmd>edit SPECIFICATION.md<cr>",                        desc = "Open Specification" },
    { "<leader>pP", "<cmd>edit PACKAGES.md<cr>",                             desc = "Open Packages" },

    -- Git
    { "<leader>pg", "<cmd>split | terminal git status<cr>",                  desc = "Git status" },
  })
else
  -- Fallback keymaps without which-key
  vim.keymap.set("n", "<leader>pd", "<cmd>split | terminal ./get_data.sh<cr>",            { desc = "Download geodata" })
  vim.keymap.set("n", "<leader>pm", "<cmd>split | terminal ./process_malta.sh<cr>",       { desc = "Process Malta" })
  vim.keymap.set("n", "<leader>pp", "<cmd>split | terminal ./process_planet.sh<cr>",      { desc = "Process planet" })
  vim.keymap.set("n", "<leader>ps", "<cmd>split | terminal ./run_server.sh<cr>",          { desc = "Start tile server" })
  vim.keymap.set("n", "<leader>pe", "<cmd>split | terminal ./run_maputnik_editor.sh<cr>", { desc = "Maputnik editor" })
  vim.keymap.set("n", "<leader>pl", "<cmd>split | terminal nix run .#lint<cr>",           { desc = "Run linters" })
  vim.keymap.set("n", "<leader>pf", "<cmd>!nix fmt<cr>",                                  { desc = "Format nix files" })
  vim.keymap.set("n", "<leader>pt", "<cmd>split | terminal pre-commit run --all-files<cr>", { desc = "Pre-commit checks" })
end
EOF
