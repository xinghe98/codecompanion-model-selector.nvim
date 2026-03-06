# codecompanion-model-selector.nvim

A [CodeCompanion.nvim](https://github.com/olimorris/codecompanion.nvim) extension
for dynamically switching adapters and models.

## ✨ Features

- 🔌 **Two-step adapter → model selection** via `vim.ui.select`
- 🤖 **Direct model selection** for a specific adapter
- 📊 **Lualine component** showing active adapter/model
- ⚡ **Auto-open new chat** session after switching (configurable)
- 🎨 **Fully customizable** icons and prompts
- 🧩 **Zero-config adapters** — define adapters once, plugin auto-registers them with CodeCompanion

## 📦 Installation

### [lazy.nvim](https://github.com/folke/lazy.nvim)

Add the plugin as a dependency of codecompanion.nvim:

```lua
{
  "olimorris/codecompanion.nvim",
  dependencies = {
    -- ... other deps
    "your-username/codecompanion-model-selector.nvim",
  },
  opts = {
    extensions = {
      model_selector = {
        opts = {
          default_adapter = "yunwu",
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
                "claude-3.5-sonnet",
                "claude-3.7-sonnet",
              },
            },
            deepseek = {
              base = "deepseek",
              env = {
                api_key = "cmd:echo $DEEPSEEK_KEY",
              },
              default = "deepseek-chat",
              choices = { "deepseek-chat", "deepseek-reasoner" },
            },
          },
        },
      },
    },
    -- No need to define `adapters` — model_selector auto-registers them!
  },
}
```

For **local development**, use the `dir` option:

```lua
{ dir = "~/Documents/codecompanion-model-selector.nvim" },
```

## 🚀 Usage

### Commands

| Command                     | Description                                      |
| --------------------------- | ------------------------------------------------ |
| `:CCSelectModel`            | Open adapter selector, then model selector       |
| `:CCSelectModel <adapter>`  | Directly open model selector for given adapter    |

### Lua API

```lua
local ms = require("cc_model_selector")

-- Two-step selection (adapter → model)
ms.select_adapter_and_model()

-- Direct model selection
ms.select_model("openrouter")

-- Get current model for an adapter
local model = ms.get_current_model("yunwu")

-- Active adapter name
local adapter = ms.active_adapter

-- Current model map { adapter_name = model_name }
local current = ms.current
```

### Keymap Example

```lua
vim.keymap.set("n", "<leader>as", function()
  require("cc_model_selector").select_adapter_and_model()
end, { desc = "Switch AI Model" })
```

### Lualine Integration

```lua
local comp_ai_model = require("cc_model_selector").get_lualine_component()

-- Or with custom options:
local comp_ai_model = require("cc_model_selector").get_lualine_component({
  icon = "🤖",
  color = { fg = "#a9b665", gui = "bold" },
})
```

## ⚙️ Configuration

All options go under `extensions.model_selector.opts` in your CodeCompanion config:

```lua
{
  -- Adapter definitions (required)
  -- Each adapter includes connection info + model choices
  adapters = {
    my_adapter = {
      base = "openai_compatible",   -- Base adapter to extend
      env = {                       -- Connection / environment config
        url = "https://api.example.com",
        api_key = "cmd:echo $MY_KEY",
        chat_url = "/v1/chat/completions",
      },
      schema = {                    -- Optional extra schema overrides
        temperature = { default = 0.0 },
      },
      default = "model-name",      -- Default model
      choices = {                   -- Available model choices
        "model-name",
        "model-name-2",
      },
    },
  },

  -- Default active adapter
  default_adapter = nil,

  -- Open a new CodeCompanion chat after switching model
  open_chat_on_switch = true,

  -- UI icons/text customization
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

## 📄 License

MIT
