-- ~/.config/nvim/init.lua

--------------------------------------------------------------------------------
-- CORE OPTIONS
--------------------------------------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = 'unnamedplus'
vim.opt.undofile = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.autoread = true

vim.g.mapleader = ' '
vim.g.maplocalleader = ','

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.opt.foldlevel = 99 -- start with all folds open

-- TMUX COMPATIBILITY
vim.opt.termguicolors = true

-- Auto-reload files changed externally (for Claude Code edits)
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold' }, {
  command = 'checktime',
})

-- Reload config (options only - plugins require restart)
vim.keymap.set('n', '<leader>R', function()
  -- Re-source just the options portion by re-running this file
  -- but lazy.nvim will skip setup if already loaded
  dofile(vim.env.MYVIMRC)
  vim.notify('Config reloaded (restart nvim for plugin changes)', vim.log.levels.INFO)
end, { desc = 'Reload config' })

-- Python uses 4-space indent
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'python',
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end,
})

--------------------------------------------------------------------------------
-- BOOTSTRAP LAZY.NVIM
--------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

--------------------------------------------------------------------------------
-- PLUGINS
--------------------------------------------------------------------------------
-- Only setup lazy once (allows config reload for options)
if not package.loaded['lazy'] then
  require('lazy').setup {
  -----------------------------
  -- Colorschemes
  -----------------------------
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1002,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    lazy = false,
    priority = 1001,
    config = function()
      vim.cmd.colorscheme 'catppuccin-mocha'
    end,
  },

  -----------------------------
  -- AI: Claude Code Integration (uses your subscription, no API key needed)
  -----------------------------
  {
    'coder/claudecode.nvim',
    dependencies = {
      'folke/snacks.nvim', -- Enhanced terminal support
    },
    config = true,
    keys = {
      { '<leader>a', nil, desc = 'AI/Claude Code' },
      { '<leader>ac', '<cmd>ClaudeCode<cr>', desc = 'Toggle Claude' },
      { '<leader>af', '<cmd>ClaudeCodeFocus<cr>', desc = 'Focus Claude' },
      { '<leader>ar', '<cmd>ClaudeCode --resume<cr>', desc = 'Resume Claude' },
      { '<leader>aC', '<cmd>ClaudeCode --continue<cr>', desc = 'Continue Claude' },
      { '<leader>am', '<cmd>ClaudeCodeSelectModel<cr>', desc = 'Select model' },
      { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', desc = 'Add current buffer' },
      { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = 'Send selection' },
      { '<leader>aa', '<cmd>ClaudeCodeDiffAccept<cr>', desc = 'Accept diff' },
      { '<leader>ad', '<cmd>ClaudeCodeDiffDeny<cr>', desc = 'Deny diff' },
    },
    opts = {
      -- Terminal settings
      terminal = {
        autostart = true,
        provider = 'none',
        split_side = 'right',
        split_width_percentage = 0.4,
      },
    },
  },

  -- Snacks.nvim (enhances claudecode terminal + other goodies)
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      terminal = { enabled = true },
    },
  },

  -----------------------------
  -- Telescope (fuzzy finder)
  -----------------------------
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = {
      { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find files' },
      { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = 'Grep' },
      { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Buffers' },
      { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = 'Help' },
      { '<leader>fs', '<cmd>Telescope lsp_document_symbols<cr>', desc = 'Symbols' },
      { '<leader>fr', '<cmd>Telescope lsp_references<cr>', desc = 'References' },
      { '<leader>fd', '<cmd>Telescope diagnostics<cr>', desc = 'Diagnostics' },
    },
  },

  -----------------------------
  -- Which-key (keyboard helper)
  -----------------------------
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
      local wk = require 'which-key'
      wk.setup()
      wk.add {
        { '<leader>f', group = 'find' },
        { '<leader>c', group = 'code' },
        { '<leader>a', group = 'ai' },
        { '<leader>t', group = 'test' },
      }
    end,
  },

  -----------------------------
  -- Neo-tree (file explorer)
  -----------------------------
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    keys = {
      { '<leader>e', '<cmd>Neotree toggle<cr>', desc = 'File tree' },
    },
  },

  -----------------------------
  -- Oil (quick file management)
  -----------------------------
  {
    'stevearc/oil.nvim',
    opts = {},
    keys = {
      { '-', '<cmd>Oil<cr>', desc = 'Open parent directory' },
    },
  },

  -----------------------------
  -- Clojure
  -----------------------------
  {
    'Olical/conjure',
    ft = { 'clojure', 'edn' },
    config = function()
      vim.g['conjure#log#hud#width'] = 0.42
      vim.g['conjure#log#hud#height'] = 0.3
      vim.g['conjure#log#hud#anchor'] = 'SE'
      vim.g['conjure#highlight#enabled'] = true
      vim.g['conjure#filetypes'] = { 'clojure', 'edn' }
    end,
  },

  {
    'julienvincent/nvim-paredit',
    ft = { 'clojure', 'edn' },
    opts = {},
  },

  -----------------------------
  -- LSP (Mason for auto-install)
  -----------------------------
  {
    'williamboman/mason.nvim',
    build = ':MasonUpdate',
    opts = {},
  },

  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    opts = {
      ensure_installed = {
        'clojure_lsp',
        'pyright',
        'ts_ls',
        'eslint',
        'lua_ls',
      },
    },
  },

  -----------------------------
  -- Formatting
  -----------------------------
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>cF',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        desc = 'Format buffer (conform)',
      },
    },
    opts = {
      formatters_by_ft = {
        python = { 'black', 'isort' },
        typescript = { 'prettier' },
        typescriptreact = { 'prettier' },
        javascript = { 'prettier' },
        javascriptreact = { 'prettier' },
        json = { 'prettier' },
        clojure = { 'cljfmt' },
        lua = { 'stylua' },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      },
    },
  },

  -----------------------------
  -- Treesitter
  -----------------------------
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = {
          'clojure',
          'python',
          'typescript',
          'tsx',
          'javascript',
          'json',
          'lua',
          'html',
          'css',
          'markdown',
          'markdown_inline',
        },
        highlight = { enable = true },
        indent = { enable = true },
      }
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      require('nvim-treesitter.configs').setup {
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@class.outer',
              ['ic'] = '@class.inner',
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
            },
          },
          move = {
            enable = true,
            goto_next_start = {
              [']m'] = '@function.outer',
              [']]'] = '@class.outer',
            },
            goto_prev_start = {
              ['[m'] = '@function.outer',
              ['[['] = '@class.outer',
            },
          },
        },
      }
    end,
  },

  -----------------------------
  -- Completion
  -----------------------------
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'PaterJason/cmp-conjure',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        sources = {
          { name = 'conjure' },
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm { select = false },
          ['<Tab>'] = cmp.mapping.select_next_item(),
          ['<S-Tab>'] = cmp.mapping.select_prev_item(),
        },
      }
    end,
  },

  -----------------------------
  -- Testing
  -----------------------------
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-neotest/neotest-python',
      'nvim-neotest/nvim-nio',
    },
    keys = {
      {
        '<leader>tt',
        function()
          require('neotest').run.run()
        end,
        desc = 'Run nearest test',
      },
      {
        '<leader>tf',
        function()
          require('neotest').run.run(vim.fn.expand '%')
        end,
        desc = 'Run file tests',
      },
      {
        '<leader>to',
        function()
          require('neotest').output.open { enter = true }
        end,
        desc = 'Test output',
      },
      {
        '<leader>ts',
        function()
          require('neotest').summary.toggle()
        end,
        desc = 'Test summary',
      },
    },
    config = function()
      require('neotest').setup {
        adapters = {
          require 'neotest-python' {
            dap = { justMyCode = false },
            runner = 'pytest',
          },
        },
      }
    end,
  },

  -----------------------------
  -- Harpoon (quick file switching)
  -----------------------------
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'
      harpoon:setup()

      vim.keymap.set('n', '<leader>ha', function()
        harpoon:list():add()
      end, { desc = 'Harpoon add' })
      vim.keymap.set('n', '<C-e>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = 'Harpoon menu' })
      vim.keymap.set('n', '<C-1>', function()
        harpoon:list():select(1)
      end, { desc = 'Harpoon file 1' })
      vim.keymap.set('n', '<C-2>', function()
        harpoon:list():select(2)
      end, { desc = 'Harpoon file 2' })
      vim.keymap.set('n', '<C-3>', function()
        harpoon:list():select(3)
      end, { desc = 'Harpoon file 3' })
      vim.keymap.set('n', '<C-4>', function()
        harpoon:list():select(4)
      end, { desc = 'Harpoon file 4' })
    end,
  },

  -----------------------------
  -- Quality of life
  -----------------------------
  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },
  { 'numToStr/Comment.nvim', opts = {} },
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
      },
    },
  },

  -- Better UI components
  { 'stevearc/dressing.nvim', opts = {} },

  -- Icons
  { 'echasnovski/mini.icons', version = false, opts = {} },
  }
end

--------------------------------------------------------------------------------
-- LSP CONFIGURATION (Neovim 0.11+ style)
--------------------------------------------------------------------------------
local capabilities = require('cmp_nvim_lsp').default_capabilities()

vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.git' },
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = {
        library = { vim.env.VIMRUNTIME },
        checkThirdParty = false,
      },
    },
  },
})

vim.lsp.config('marksman', {
  cmd = { 'marksman', 'server' },
  filetypes = { 'markdown' },
  root_markers = { '.git', '.marksman.toml' },
  capabilities = capabilities,
})

vim.lsp.config('clojure_lsp', {
  cmd = { 'clojure-lsp' },
  filetypes = { 'clojure', 'edn' },
  root_markers = { 'deps.edn', 'project.clj', '.git' },
  capabilities = capabilities,
})

vim.lsp.config('pyright', {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'requirements.txt', '.git' },
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = 'basic',
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
})

vim.lsp.config('ts_ls', {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  root_markers = { 'tsconfig.json', 'package.json', '.git' },
  capabilities = capabilities,
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
      },
    },
  },
})

vim.lsp.config('eslint', {
  cmd = { 'vscode-eslint-language-server', '--stdio' },
  filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  root_markers = { '.eslintrc', '.eslintrc.js', '.eslintrc.json', 'eslint.config.js' },
  capabilities = capabilities,
})

vim.lsp.config('gradle_ls', {
  init_options = {
    settings = {
      gradleWrapperEnabled = true,
    },
  },
})

-- Enable all LSPs
vim.lsp.enable 'lua_ls'
vim.lsp.enable 'marksman'
vim.lsp.enable 'clojure_lsp'
vim.lsp.enable 'pyright'
vim.lsp.enable 'ts_ls'
vim.lsp.enable 'eslint'

-- LSP keymaps on attach
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(event)
    local opts = { buffer = event.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>cf', vim.lsp.buf.format, opts)
    vim.keymap.set('v', '<leader>cf', vim.lsp.buf.format, opts)

    -- ESLint auto-fix on save
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client.name == 'eslint' then
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = event.buf,
        command = 'EslintFixAll',
      })
    end
  end,
})

--------------------------------------------------------------------------------
-- Filetype-specific settings
--------------------------------------------------------------------------------
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'markdown',
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.textwidth = 80
  end,
})

--------------------------------------------------------------------------------
-- QUICK REFERENCE
--------------------------------------------------------------------------------
-- CLAUDE CODE (uses your subscription, no API key needed)
-- <leader>ac     Toggle Claude Code terminal
-- <leader>af     Focus Claude window
-- <leader>ar     Resume previous conversation
-- <leader>aC     Continue last conversation
-- <leader>am     Select model
-- <leader>ab     Add current buffer to context
-- <leader>as     Send visual selection to Claude
-- <leader>aa     Accept diff
-- <leader>ad     Deny diff
--
-- GENERAL
-- <leader>ff     Find files
-- <leader>fg     Live grep
-- <leader>fb     Buffers
-- <leader>e      File tree (neo-tree)
-- -              File browser (oil)
--
-- LSP (all languages)
-- gd             Go to definition
-- gD             Go to declaration
-- gi             Go to implementation
-- gt             Go to type definition
-- gr             References
-- K              Hover docs
-- <leader>rn     Rename
-- <leader>ca     Code action
-- [d / ]d        Prev/next diagnostic
-- <leader>cf     Format (LSP)
-- <leader>cF     Format (conform)
--
-- CLOJURE (Conjure) - localleader is ","
-- ,ee            Eval form
-- ,er            Eval root form
-- ,eb            Eval buffer
-- ,lv            Log vertical split
--
-- PYTHON (neotest)
-- <leader>tt     Run nearest test
-- <leader>tf     Run file tests
-- <leader>to     Test output
-- <leader>ts     Test summary
--
-- HARPOON
-- <leader>ha     Add file
-- <C-e>          Quick menu
-- <C-1/2/3/4>    Jump to file 1-4
--
-- TEXT OBJECTS
-- af/if          Function outer/inner
-- ac/ic          Class outer/inner
-- aa/ia          Argument outer/inner
--
-- COMPLETION (nvim-cmp)
-- <C-Space>      Trigger completion
-- <CR>           Confirm selection
-- <Tab>/<S-Tab>  Navigate completion menu
