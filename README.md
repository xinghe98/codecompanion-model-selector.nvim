# codecompanion-model-selector.nvim

A lightweight, elegant extension for [CodeCompanion.nvim](https://github.com/olimorris/codecompanion.nvim) that manages adapters and model switching dynamically.

**Say goodbye to `adapters.lua` boilerplate!** Configure your adapters, connection details, and model options in one single place. The plugin handles registering them with CodeCompanion automatically.

## ✨ Features

- 🧩 **Zero-config mapping**: Define adapters inside the extension config once. No need to write manual factory functions or `require` inside an `adapters.lua` file!
- 🔌 **Two-step modal selection**: Interactively pick an adapter, then choose its model intuitively.
- 🤖 **Quick switch**: Directly open the model selector for any specific active adapter.
- 📊 **Lualine component**: Real-time status bar component showing your active adapter and model.
- ⚡ **Auto-chat**: Automatically starts a new session right after switching to a new model.

---

## 📦 Installation & Setup

Add `codecompanion-model-selector.nvim` to your dependencies inside `lazy.nvim`, and then define your configuration entirely within CodeCompanion's `opts.extensions.model_selector.opts`.

### 🚨 Crucial Concept: No More `opts.adapters`
You **do not** need to set up `opts.adapters` manually in CodeCompanion anymore. Look at how seamlessly things are merged below.

```lua
return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    -- 1. Just add the plugin as a dependency
    "xinghe98/codecompanion-model-selector.nvim",
  },
  opts = {
    -- 2. ONLY define your adapters and models inside the extension section
    extensions = {
      model_selector = {
        opts = {
          default_adapter = "openrouter",
          
          -- Define all your adapters and connection details here down below
          adapters = {
            openrouter = {
              base = "openai_compatible",
              env = {
                url = "https://openrouter.ai/api/v1",
                api_key = "cmd:echo $OPENROUTER_KEY",
                chat_url = "/chat/completions",
              },
              default = "minimax/minimax-m2.5",
              choices = {
                "minimax/minimax-m2.5",
                "claude-3.7-sonnet",
              },
            },
            
            deepseek = {
              base = "deepseek",
              env = {
                api_key = "cmd:echo $DEEPSEEK_KEY",
              },
              default = "deepseek-chat",
              choices = {
                "deepseek-chat",
                "deepseek-reasoner",
              },
            },
          },
        },
      },
    },
    
    -- 3. DO NOT define `adapters = require(...)` down here. 
    -- ❌ adapters = require("plugins.codecompanion.adapters"), 
    -- The plugin handles that automatically for you!
  },
}
```

---

## ⚙️ Configuration Schema

All available options format for `extensions.model_selector.opts`:

```lua
{
  -- Default active adapter when neovim starts
  default_adapter = "openrouter",

  -- Main Adapters Block
  adapters = {
    my_adapter = {
      base = "openai_compatible",   -- Which underlying codecompanion adapter to extend
      env = {                       -- Connection API environment config
        url = "https://api.example.com/v1",
        api_key = "cmd:echo $MY_API_KEY",
        chat_url = "/chat/completions",
      },
      schema = {                    -- Optional CodeCompanion schema overrides 
        temperature = { default = 0.0 },
      },
      default = "model-name",       -- Default active model
      choices = {                   -- The models showing up in the selector prompt
        "model-name",
        "model-name-2",
      },
    },
  },

  -- Whether to open a new CodeCompanion chat after switching models
  open_chat_on_switch = true,

  -- UI icons/text customization (used in prompts and selections)
  icons = {
    active = "● ",          -- prefix for active model
    inactive = "  ",        -- prefix for inactive model
    adapter_active = " ★",  -- suffix for active adapter
    prompt_model = "🤖 Select %s Model:",
    prompt_adapter = "🔌 Select Adapter:",
    notify_success = "✅ [%s] → %s",
  },
}
```

---

## � Usage

### UI Commands & Keymaps

We recommend adding a keymap for the universal selector:

```lua
vim.keymap.set("n", "<leader>as", function()
  require("cc_model_selector").select_adapter_and_model()
end, { desc = "Switch AI Model" })
```

Other available Lua APIs:
```lua
local ms = require("cc_model_selector")

-- Directly open model selection for one specific adapter
ms.select_model("openrouter")

-- Read current model map
local current_model = ms.current["deepseek"]

-- Get currently active adapter string
local active_adapter = ms.active_adapter
```

Or you can use builtin Vim commands:
- `:CCSelectModel` - Launch the two-step menu
- `:CCSelectModel deepseek` - Directly jump to the `deepseek` model choices menu

### Lualine Integration

Display your currently active model effortlessly inside your lualine segment:

```lua
local comp_ai_model = require("cc_model_selector").get_lualine_component()

-- Or optionally, fully customize it:
local comp_ai_model = require("cc_model_selector").get_lualine_component({
  icon = "🤖",
  color = { fg = "#a9b665", gui = "bold" },
})

require('lualine').setup({
  sections = {
    lualine_y = { comp_ai_model },
  }
})
```

---

## �📄 License
MIT
