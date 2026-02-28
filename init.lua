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

-- Auto-save files on insert leave or text change
vim.api.nvim_create_autocmd({ 'InsertLeave', 'TextChanged' }, {
  pattern = '*',
  callback = function()
    if vim.bo.modified and vim.fn.expand '%' ~= '' and vim.bo.buftype == '' then
      vim.cmd 'silent! write'
    end
  end,
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
      lazy = true,
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
        terminal = {
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
      dependencies = { 'nvim-lua/plenary.nvim' },
      keys = {
        { '<leader>ff', '<cmd>Telescope find_files<cr>', desc = 'Find files' },
        { '<leader>fg', '<cmd>Telescope live_grep<cr>', desc = 'Grep' },
        { '<leader>fb', '<cmd>Telescope buffers<cr>', desc = 'Buffers' },
        { '<leader>fh', '<cmd>Telescope help_tags<cr>', desc = 'Help' },
        { '<leader>fs', '<cmd>Telescope lsp_document_symbols<cr>', desc = 'Symbols' },
        { '<leader>fr', '<cmd>Telescope lsp_references<cr>', desc = 'References' },
        { '<leader>fd', '<cmd>Telescope diagnostics<cr>', desc = 'Diagnostics' },
        { '<leader>fz', '<cmd>Telescope spell_suggest<cr>', desc = 'Spell suggest' },
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
          { '<leader>r', group = 'repl' },
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
    -- Java
    -----------------------------
    {
      'mfussenegger/nvim-jdtls',
      ft = 'java',
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
          'jdtls',
        },
        handlers = {
          -- Skip jdtls - nvim-jdtls handles it via FileType autocmd
          jdtls = function() end,
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
          -- java uses LSP formatting via jdtls (lsp_fallback = true)
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
      lazy = false,
      build = ':TSUpdate',
      config = function()
        require('nvim-treesitter').install {
          'clojure', 'python', 'typescript', 'tsx', 'javascript',
          'json', 'lua', 'html', 'css', 'markdown', 'markdown_inline', 'java', 'bash',
        }
        vim.api.nvim_create_autocmd('FileType', {
          callback = function()
            if pcall(vim.treesitter.start) then
              vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end
          end,
        })
      end,
    },

    {
      'MeanderingProgrammer/treesitter-modules.nvim',
      lazy = false,
      dependencies = { 'nvim-treesitter/nvim-treesitter' },
      opts = {
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<leader>v',
            node_incremental = '<leader>v',
            node_decremental = '<leader>V',
            scope_incremental = false,
          },
        },
      },
    },

    {
      'nvim-treesitter/nvim-treesitter-textobjects',
      lazy = false,
      dependencies = { 'nvim-treesitter/nvim-treesitter' },
      config = function()
        require('nvim-treesitter-textobjects').setup {
          select = { lookahead = true },
          move = { set_jumps = true },
        }
        local select_fn = require('nvim-treesitter-textobjects.select').select_textobject
        local move = require('nvim-treesitter-textobjects.move')
        vim.keymap.set({ 'x', 'o' }, 'af', function() select_fn('@function.outer', 'textobjects') end)
        vim.keymap.set({ 'x', 'o' }, 'if', function() select_fn('@function.inner', 'textobjects') end)
        vim.keymap.set({ 'x', 'o' }, 'ac', function() select_fn('@class.outer', 'textobjects') end)
        vim.keymap.set({ 'x', 'o' }, 'ic', function() select_fn('@class.inner', 'textobjects') end)
        vim.keymap.set({ 'x', 'o' }, 'aa', function() select_fn('@parameter.outer', 'textobjects') end)
        vim.keymap.set({ 'x', 'o' }, 'ia', function() select_fn('@parameter.inner', 'textobjects') end)
        vim.keymap.set({ 'n', 'x', 'o' }, ']m', function() move.goto_next_start('@function.outer', 'textobjects') end)
        vim.keymap.set({ 'n', 'x', 'o' }, ']]', function() move.goto_next_start('@class.outer', 'textobjects') end)
        vim.keymap.set({ 'n', 'x', 'o' }, '[m', function() move.goto_previous_start('@function.outer', 'textobjects') end)
        vim.keymap.set({ 'n', 'x', 'o' }, '[[', function() move.goto_previous_start('@class.outer', 'textobjects') end)
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
        'rcasia/neotest-java',
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
            local ok, err = pcall(require('neotest').summary.toggle)
            if not ok and not err:match('Invalid window') then
              error(err)
            end
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
            require 'neotest-java' {},
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
        vim.keymap.set('n', '<leader>1', function()
          harpoon:list():select(1)
        end, { desc = 'Harpoon file 1' })
        vim.keymap.set('n', '<leader>2', function()
          harpoon:list():select(2)
        end, { desc = 'Harpoon file 2' })
        vim.keymap.set('n', '<leader>3', function()
          harpoon:list():select(3)
        end, { desc = 'Harpoon file 3' })
        vim.keymap.set('n', '<leader>4', function()
          harpoon:list():select(4)
        end, { desc = 'Harpoon file 4' })
      end,
    },

    -----------------------------
    -- Git (lazygit.nvim)
    -----------------------------
    {
      'kdheepak/lazygit.nvim',
      keys = {
        { '<leader>gg', '<cmd>LazyGit<cr>', desc = 'LazyGit' },
      },
    },

    -----------------------------
    -- REPL (iron.nvim)
    -----------------------------
    {
      'Vigemus/iron.nvim',
      keys = {
        { '<leader>rs', '<cmd>IronRepl<cr>', desc = 'Start REPL' },
        { '<leader>rr', '<cmd>IronRestart<cr>', desc = 'Restart REPL' },
        { '<leader>rf', '<cmd>IronFocus<cr>', desc = 'Focus REPL' },
        { '<leader>rh', '<cmd>IronHide<cr>', desc = 'Hide REPL' },
        -- Start specific REPLs (useful from markdown)
        { '<leader>r1', '<cmd>IronRepl java<cr>', desc = 'Start jshell' },
        { '<leader>r2', '<cmd>IronRepl python<cr>', desc = 'Start python' },
        { '<leader>r3', '<cmd>IronRepl bash<cr>', desc = 'Start bash' },
        { '<leader>r4', '<cmd>IronRepl typescript<cr>', desc = 'Start ts-node' },
        { '<leader>r5', '<cmd>IronRepl ki<cr>', desc = 'Start ki' },
      },
      config = function()
        require('iron.core').setup {
          config = {
            repl_definition = {
              python = {
                command = vim.uv.fs_stat('uv.lock') and { 'uv', 'run', 'python3' } or { 'python3' },
              },
              sh = { command = { 'bash' } },
              bash = { command = { 'bash' } },
              java = { command = { 'jshell' } },
              typescript = { command = { 'npx', 'ts-node' } },
              javascript = { command = { 'node' } },
              lua = { command = { 'lua' } },
              kotlin = { command = { 'ki' } },
              ki = { command = { 'ki' } },
            },
            repl_open_cmd = 'vertical botright 50 split',
          },
          keymaps = {
            send_motion = '<leader>rc',
            visual_send = '<leader>rv',
            send_line = '<leader>rl',
            send_until_cursor = '<leader>ru',
            send_file = '<leader>rF',
            cr = '<leader>r<cr>',
            interrupt = '<leader>ri',
            exit = '<leader>rq',
            clear = '<leader>rL',
          },
          ignore_blank_lines = true,
        }

        -- Map code block languages to REPL filetypes
        local lang_to_ft = {
          java = 'java',
          python = 'python',
          py = 'python',
          bash = 'bash',
          sh = 'bash',
          shell = 'bash',
          typescript = 'typescript',
          ts = 'typescript',
          javascript = 'javascript',
          js = 'javascript',
          lua = 'lua',
          kotlin = 'kotlin',
          kt = 'kotlin',
          ki = 'ki',
        }

        -- Get code block info at cursor using treesitter
        local function get_code_block_at_cursor()
          local node = vim.treesitter.get_node()
          -- Walk up to find fenced_code_block
          while node and node:type() ~= 'fenced_code_block' do
            node = node:parent()
          end
          if not node then
            return nil, nil
          end

          local lang = nil
          local code_lines = {}

          for child in node:iter_children() do
            if child:type() == 'info_string' then
              lang = vim.treesitter.get_node_text(child, 0):match '%S+'
            elseif child:type() == 'code_fence_content' then
              local text = vim.treesitter.get_node_text(child, 0)
              for line in text:gmatch '[^\n]+' do
                table.insert(code_lines, line)
              end
            end
          end

          return lang, code_lines
        end

        -- Send code block at cursor to appropriate REPL
        local function send_code_block()
          local lang, lines = get_code_block_at_cursor()
          if not lang then
            vim.notify('Not in a code block', vim.log.levels.WARN)
            return
          end
          local ft = lang_to_ft[lang:lower()]
          if not ft then
            vim.notify('No REPL configured for: ' .. lang, vim.log.levels.WARN)
            return
          end
          require('iron.core').send(ft, lines)
        end

        vim.keymap.set('n', '<leader>rb', send_code_block, { desc = 'Send code block to REPL' })
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

    -----------------------------
    -- Statusline (agnoster/powerline style)
    -----------------------------
    {
      'nvim-lualine/lualine.nvim',
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      opts = {
        options = {
          theme = 'catppuccin',
          component_separators = { left = '', right = '' },
          section_separators = { left = '', right = '' },
          globalstatus = true,
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = { { 'filename', path = 1 } },
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
      },
    },

    -----------------------------
    -- Markdown preview
    -----------------------------
    {
      'iamcco/markdown-preview.nvim',
      build = 'cd app && npm install',
      ft = 'markdown',
      keys = {
        { '<leader>mp', '<cmd>MarkdownPreviewToggle<cr>', desc = 'Markdown preview' },
      },
      config = function()
        vim.g.mkdp_port = '9999'
        vim.g.mkdp_open_to_the_world = 1
        vim.g.mkdp_open_ip = 'barry'
        vim.g.mkdp_browser = 'none'
        vim.g.mkdp_echo_preview_url = 1
      end,
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

-- Java (nvim-jdtls handles its own startup)
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  callback = function()
    local jdtls_path = vim.fn.stdpath 'data' .. '/mason/packages/jdtls'
    local config = {
      cmd = {
        'java',
        '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        '-Dosgi.bundles.defaultStartLevel=4',
        '-Declipse.product=org.eclipse.jdt.ls.core.product',
        '-Dlog.protocol=true',
        '-Dlog.level=ALL',
        '-Xmx1g',
        '--add-modules=ALL-SYSTEM',
        '--add-opens',
        'java.base/java.util=ALL-UNNAMED',
        '--add-opens',
        'java.base/java.lang=ALL-UNNAMED',
        '-jar',
        vim.fn.glob(jdtls_path .. '/plugins/org.eclipse.equinox.launcher_*.jar'),
        '-configuration',
        jdtls_path .. '/config_linux',
        '-data',
        vim.fn.stdpath 'cache' .. '/jdtls/' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t'),
      },
      root_dir = vim.fs.dirname(vim.fs.find({ 'gradlew', 'mvnw', '.git', 'pom.xml', 'build.gradle' }, { upward = true })[1]),
      capabilities = capabilities,
      settings = {
        java = {
          signatureHelp = { enabled = true },
          contentProvider = { preferred = 'fernflower' },
        },
      },
    }
    require('jdtls').start_or_attach(config)
  end,
})

-- Enable all LSPs
vim.lsp.enable 'lua_ls'
vim.lsp.enable 'marksman'
vim.lsp.enable 'clojure_lsp'
vim.lsp.enable 'pyright'
vim.lsp.enable 'ts_ls'
vim.lsp.enable 'eslint'
-- Disable default jdtls - nvim-jdtls handles it
vim.lsp.enable('jdtls', false)

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
    vim.opt_local.spell = true
    vim.opt_local.spelllang = 'en_gb'
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
-- JAVA (nvim-jdtls)
-- All standard LSP keymaps work (gd, gr, K, etc.)
-- <leader>cf     Format (via jdtls)
--
-- PYTHON (neotest)
-- <leader>tt     Run nearest test
-- <leader>tf     Run file tests
-- <leader>to     Test output
-- <leader>ts     Test summary
--
-- REPL (iron.nvim) - Python, Java, Kotlin, TypeScript, Bash, Lua
-- <leader>rs     Start REPL for current filetype
-- <leader>r1     Start jshell
-- <leader>r2     Start python
-- <leader>r3     Start bash
-- <leader>r4     Start ts-node
-- <leader>r5     Start ki
-- <leader>rr     Restart REPL
-- <leader>rf     Focus REPL
-- <leader>rh     Hide REPL
-- <leader>rv     Send visual selection (visual mode)
-- <leader>rl     Send current line
-- <leader>rc     Send motion (e.g., <leader>rcap for paragraph)
-- <leader>rF     Send entire file
-- <leader>ri     Interrupt REPL
-- <leader>rq     Exit/quit REPL
-- <leader>rL     Clear REPL
-- <leader>rb     Send code block to REPL (auto-detects language from fence)
--
-- GIT (lazygit.nvim)
-- <leader>gg     Open LazyGit
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
