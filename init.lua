vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = false -- Perhaps we will install one in the future
vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false

vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

vim.o.breakindent = true
vim.o.undofile = true

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.o.inccommand = 'split'
vim.o.cursorline = true

vim.o.scrolloff = 15 -- This is a fun setting to play with

vim.o.confirm = true

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup({
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        panel = {
          enabled = true,
          auto_refresh = false,
          keymap = {
            jump_prev = '[[',
            jump_next = ']]',
            accept = '<CR>',
            refresh = 'gr',
            open = '<M-CR>',
          },
          layout = {
            position = 'bottom',
            ratio = 0.4,
          },
        },
        suggestion = {
          enabled = true,
          auto_trigger = true,
          debounce = 75,
          keymap = {
            accept = false, -- We'll handle this manually
            accept_word = false,
            accept_line = false,
            next = '<M-]>',
            prev = '<M-[>',
            dismiss = '<C-]>',
          },
        },
        filetypes = {
          yaml = false,
          markdown = false,
          help = false,
          gitcommit = false,
          gitrebase = false,
          hgcommit = false,
          svn = false,
          cvs = false,
          ['.'] = false,
        },
        copilot_node_command = 'node',
        server_opts_overrides = {},
      }
    end,
  },

  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'main',
    dependencies = {
      { 'zbirenbaum/copilot.lua' }, -- or github/copilot.vim
      { 'nvim-lua/plenary.nvim' }, -- for curl, log wrapper
    },
    build = 'make tiktoken', -- Only on MacOS or Linux
    opts = {
      debug = false, -- Enable debugging
      -- See Configuration section for rest
    },
    config = function(_, opts)
      local chat = require 'CopilotChat'
      local select = require 'CopilotChat.select'

      chat.setup(opts)

      -- Setup keymaps
      vim.keymap.set('n', '<leader>cc', '<cmd>CopilotChat<CR>', { desc = '[C]opilot [C]hat' })
      vim.keymap.set('v', '<leader>cc', '<cmd>CopilotChat<CR>', { desc = '[C]opilot [C]hat' })

      -- Quick chat with your buffer
      vim.keymap.set('n', '<leader>cb', function()
        local input = vim.fn.input 'Quick Chat: '
        if input ~= '' then
          require('CopilotChat').ask(input, { selection = select.buffer })
        end
      end, { desc = '[C]opilot Chat [B]uffer' })

      -- Chat with selection
      vim.keymap.set('v', '<leader>cs', function()
        local input = vim.fn.input 'Quick Chat: '
        if input ~= '' then
          require('CopilotChat').ask(input, { selection = select.visual })
        end
      end, { desc = '[C]opilot Chat [S]election' })

      -- Predefined prompts
      vim.keymap.set('n', '<leader>ce', '<cmd>CopilotChatExplain<CR>', { desc = '[C]opilot Chat [E]xplain' })
      vim.keymap.set('v', '<leader>ce', '<cmd>CopilotChatExplain<CR>', { desc = '[C]opilot Chat [E]xplain' })

      vim.keymap.set('n', '<leader>cr', '<cmd>CopilotChatReview<CR>', { desc = '[C]opilot Chat [R]eview' })
      vim.keymap.set('v', '<leader>cr', '<cmd>CopilotChatReview<CR>', { desc = '[C]opilot Chat [R]eview' })

      vim.keymap.set('n', '<leader>cf', '<cmd>CopilotChatFix<CR>', { desc = '[C]opilot Chat [F]ix' })
      vim.keymap.set('v', '<leader>cf', '<cmd>CopilotChatFix<CR>', { desc = '[C]opilot Chat [F]ix' })

      vim.keymap.set('n', '<leader>co', '<cmd>CopilotChatOptimize<CR>', { desc = '[C]opilot Chat [O]ptimize' })
      vim.keymap.set('v', '<leader>co', '<cmd>CopilotChatOptimize<CR>', { desc = '[C]opilot Chat [O]ptimize' })

      vim.keymap.set('n', '<leader>cd', '<cmd>CopilotChatDocs<CR>', { desc = '[C]opilot Chat [D]ocs' })
      vim.keymap.set('v', '<leader>cd', '<cmd>CopilotChatDocs<CR>', { desc = '[C]opilot Chat [D]ocs' })

      vim.keymap.set('n', '<leader>ct', '<cmd>CopilotChatTests<CR>', { desc = '[C]opilot Chat [T]ests' })
      vim.keymap.set('v', '<leader>ct', '<cmd>CopilotChatTests<CR>', { desc = '[C]opilot Chat [T]ests' })

      -- Toggle chat
      vim.keymap.set('n', '<leader>cq', '<cmd>CopilotChatToggle<CR>', { desc = '[C]opilot Chat [Q]uick toggle' })
    end,
  },

  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  {
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      vim.keymap.set('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    'neovim/nvim-lspconfig',
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end
          --NOTE:  LSP mapping, using Telescope
          map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
          map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
          map('grr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
          map('gri', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
          map('grd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
          map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          map('gO', require('telescope.builtin').lsp_document_symbols, 'Open Document Symbols')
          map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Open Workspace Symbols')
          map('grt', require('telescope.builtin').lsp_type_definitions, '[G]oto [T]ype Definition')

          local function client_supports_method(client, method, bufnr)
            if vim.fn.has 'nvim-0.11' == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
            map('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
        virtual_text = {
          source = 'if_many',
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      }

      local capabilities = require('blink.cmp').get_lsp_capabilities()

      local servers = {
        clangd = {},
        pyright = {},
        ts_ls = {},
        html = {
          settings = {
            html = {
              format = {
                indentInnerHtml = true,
                indentHandlebars = true,
                wrapAttributes = 'auto',
                wrapLineLength = 120,
                unformatted = 'wbr',
                contentUnformatted = 'pre,code,textarea',
                endWithNewline = true,
                preserveNewLines = true,
                maxPreserveNewLines = 2,
              },
            },
          },
        },
        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
            },
          },
        },
      }

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua',
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        ensure_installed = {},
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        javascript = { 'prettier' },
        html = { 'prettier' }, -- Add HTML formatting
        css = { 'prettier' },
        json = { 'prettier' },
      },
    },
  },

  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {},
        opts = {},
      },
      'folke/lazydev.nvim',
    },
    opts = {
      keymap = {
        preset = 'default',
      },
      appearance = {
        nerd_font_variant = 'mono',
      },
      completion = {
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
    },
  },

  {
    'folke/tokyonight.nvim',
    priority = 1000,
    config = function()
      require('tokyonight').setup {
        styles = {
          comments = { italic = false },
        },
      }
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },

  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }

      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc' },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = {
        enable = false, -- Disable treesitter indenting
      },
    },
  },

  require 'kickstart.plugins.debug',
  require 'kickstart.plugins.gitsigns',
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- Smart Tab functionality for Copilot
local function smart_tab()
  local copilot = require 'copilot.suggestion'

  -- If Copilot suggestion is visible, accept it
  if copilot.is_visible() then
    copilot.accept()
    return
  end

  -- Check if blink.cmp completion menu is visible
  local blink_cmp = require 'blink.cmp'
  if blink_cmp.is_visible() then
    blink_cmp.select_next()
    return
  end

  -- Check if we're in a snippet and can jump
  local luasnip_ok, luasnip = pcall(require, 'luasnip')
  if luasnip_ok then
    if luasnip.expandable() then
      luasnip.expand()
      return
    elseif luasnip.jumpable(1) then
      luasnip.jump(1)
      return
    end
  end

  -- Default to normal tab behavior
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)
end

local function smart_shift_tab()
  local blink_cmp = require 'blink.cmp'

  -- If completion menu is visible, select previous item
  if blink_cmp.is_visible() then
    blink_cmp.select_prev()
    return
  end

  -- If we can jump back in snippet
  local luasnip_ok, luasnip = pcall(require, 'luasnip')
  if luasnip_ok and luasnip.jumpable(-1) then
    luasnip.jump(-1)
    return
  end

  -- Default to normal shift-tab behavior
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<S-Tab>', true, false, true), 'n', false)
end

-- Set up the smart tab keymaps
vim.keymap.set('i', '<Tab>', smart_tab, { desc = 'Smart Tab: Copilot → Completion → Snippet → Normal' })
vim.keymap.set('i', '<S-Tab>', smart_shift_tab, { desc = 'Smart Shift-Tab: Completion ← Snippet ← Normal' })

-- Additional Copilot keymaps for better VS Code-like experience
vim.keymap.set('i', '<M-CR>', function()
  require('copilot.panel').open()
end, { desc = 'Open Copilot panel' })

vim.keymap.set('i', '<C-]>', function()
  require('copilot.suggestion').dismiss()
end, { desc = 'Dismiss Copilot suggestion' })

-- Toggle Copilot for current buffer
vim.keymap.set('n', '<leader>tc', function()
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype

  if vim.b[buf].copilot_disabled then
    vim.b[buf].copilot_disabled = false
    vim.cmd 'Copilot enable'
    print('Copilot enabled for ' .. ft)
  else
    vim.b[buf].copilot_disabled = true
    require('copilot.suggestion').dismiss()
    vim.cmd 'Copilot disable'
    print('Copilot disabled for ' .. ft)
  end
end, { desc = '[T]oggle [C]opilot for current buffer' })

-- Set global indentation settings - 4 spaces for everything
vim.o.tabstop = 4 -- Number of spaces a tab counts for
vim.o.shiftwidth = 4 -- Number of spaces for each step of (auto)indent
vim.o.softtabstop = 4 -- Number of spaces a tab counts for while editing
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.autoindent = true -- Copy indent from current line when starting new line
vim.o.smartindent = false -- Disable smart indenting
vim.o.cindent = false -- Disable C-style indenting
vim.o.indentexpr = '' -- Disable expression-based indenting

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
--
--
vim.o.wrap = false

vim.cmd [[
     highlight Normal guibg=NONE ctermbg=NONE
     highlight NonText guibg=NONE ctermbg=NONE
     highlight EndOfBuffer guibg=NONE ctermbg=NONE
 ]]
