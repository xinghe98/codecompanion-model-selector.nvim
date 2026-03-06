# codecompanion-model-selector.nvim

A [CodeCompanion.nvim](https://github.com/olimorris/codecompanion.nvim) extension
for dynamically switching adapters and models.

## ✨ Features

- 🔌 **Two-step adapter → model selection** via `vim.ui.select`
- 🤖 **Direct model selection** for a specific adapter
- 📊 **Lualine component** showing active adapter/model
- ⚡ **Auto-open new chat** session after switching (configurable)
- 🎨 **Fully customizable** icons and prompts
- 🧩 **Native CodeCompanion extension** — configure alongside spinner, etc.

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
          models = {
            openrouter = {
              default = "minimax/minimax-m2.5",
              choices = {
                "minimax/minimax-m2.5",
                "claude-3.5-sonnet",
                "claude-3.7-sonnet",
              },
            },
            deepseek = {
              default = "deepseek-chat",
              choices = { "deepseek-chat", "deepseek-reasoner" },
            },
          },
        },
      },
      -- other extensions ...
      spinner = { opts = { style = "fidget" } },
    },
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

### CodeCompanion Adapter Integration

Use `get_current_model()` in your adapter definitions:

```lua
local ms = require("cc_model_selector")

adapters = {
  yunwu = function()
    return require("codecompanion.adapters").extend("openai_compatible", {
      schema = {
        model = {
          default = ms.get_current_model("yunwu"),
          choices = ms.config.models.yunwu.choices,
        },
      },
    })
  end,
}
```

## ⚙️ Configuration

All options go under `extensions.model_selector.opts` in your CodeCompanion config:

```lua
{
  -- Adapter model definitions (required)
  models = {},

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
