--- CodeCompanion Extension: model_selector
--- CodeCompanion 会从 runtimepath 中查找 codecompanion._extensions.<name>
--- 并调用 Extension.setup(opts)，opts 来自用户配置中的 model_selector.opts
---
---@class CodeCompanion.Extension

local Extension = {}

---@param opts CCModelSelectorConfig
function Extension.setup(opts)
  require("cc_model_selector").setup(opts)
end

--- 导出到 codecompanion.extensions.model_selector
Extension.exports = {
  select_model = function(adapter_name)
    require("cc_model_selector").select_model(adapter_name)
  end,
  select_adapter_and_model = function()
    require("cc_model_selector").select_adapter_and_model()
  end,
  get_current_model = function(adapter_name)
    return require("cc_model_selector").get_current_model(adapter_name)
  end,
  get_lualine_component = function(opts)
    return require("cc_model_selector").get_lualine_component(opts)
  end,
}

return Extension
