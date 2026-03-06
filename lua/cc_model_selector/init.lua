---@class CCModelSelector
---@field config CCModelSelectorConfig
---@field active_adapter string
---@field current table<string, string>
local M = {}

---@class CCModelSelectorIcons
---@field active? string Model active indicator
---@field inactive? string Model inactive indicator
---@field adapter_active? string Adapter active indicator
---@field prompt_model? string Model selection prompt (%s = adapter name)
---@field prompt_adapter? string Adapter selection prompt
---@field notify_success? string Notification format (%s = adapter, %s = model)

---@class CCModelSelectorAdapterConfig
---@field base string Base adapter to extend (e.g. "openai_compatible", "deepseek")
---@field env? table Environment / connection config (url, api_key, chat_url, ...)
---@field schema? table Extra schema overrides (temperature, etc.)
---@field default string Default model name
---@field choices string[] Available model choices

---@class CCModelSelectorConfig
---@field adapters table<string, CCModelSelectorAdapterConfig>
---@field default_adapter? string
---@field open_chat_on_switch? boolean
---@field icons? CCModelSelectorIcons
local defaults = {
  adapters = {},
  default_adapter = nil,
  open_chat_on_switch = true,
  icons = {
    active = "● ",
    inactive = "  ",
    adapter_active = " ★",
    prompt_model = "🤖 Select %s Model:",
    prompt_adapter = "🔌 Select Adapter:",
    notify_success = "✅ [%s] → %s",
  },
}

M.config = vim.deepcopy(defaults)
M.active_adapter = ""
M.current = {}

--- 初始化插件（由 CodeCompanion extension 入口调用）
---@param opts? CCModelSelectorConfig
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})

  -- 初始化每个 adapter 的当前模型为 default
  M.current = {}
  for name, adapter_cfg in pairs(M.config.adapters) do
    M.current[name] = adapter_cfg.default
  end

  -- 设置默认活跃 adapter
  M.active_adapter = M.config.default_adapter or next(M.config.adapters) or ""

  -- 向 CodeCompanion config 注入 adapters
  M._register_adapters()

  -- 注册用户命令
  vim.api.nvim_create_user_command("CCSelectModel", function(cmd_opts)
    if cmd_opts.args and cmd_opts.args ~= "" then
      M.select_model(cmd_opts.args)
    else
      M.select_adapter_and_model()
    end
  end, {
    nargs = "?",
    complete = function()
      return vim.tbl_keys(M.config.adapters)
    end,
    desc = "Select CodeCompanion adapter/model",
  })
end

--- 自动向 CodeCompanion 注册所有 adapter
function M._register_adapters()
  local ok, cc_config = pcall(require, "codecompanion.config")
  if not ok then
    return
  end

  for name, adapter_cfg in pairs(M.config.adapters) do
    -- 每个 adapter 注册为一个 factory function（惰性执行）
    cc_config.adapters.http[name] = function()
      local schema = vim.tbl_deep_extend("force", {
        model = {
          default = M.get_current_model(name),
          choices = adapter_cfg.choices or {},
        },
      }, adapter_cfg.schema or {})

      return require("codecompanion.adapters").extend(adapter_cfg.base, {
        env = adapter_cfg.env,
        schema = schema,
      })
    end
  end
end

--- 获取 adapter 当前使用的模型
---@param adapter_name string
---@return string
function M.get_current_model(adapter_name)
  return M.current[adapter_name]
    or (M.config.adapters[adapter_name] and M.config.adapters[adapter_name].default)
    or ""
end

--- 弹出 vim.ui.select 浮窗切换模型
---@param adapter_name string
function M.select_model(adapter_name)
  local adapter_cfg = M.config.adapters[adapter_name]
  if not adapter_cfg then
    vim.notify("Unknown adapter: " .. adapter_name, vim.log.levels.ERROR)
    return
  end

  local icons = M.config.icons or {}

  -- 构建带有当前选中标记的显示列表
  local display_items = {}
  for _, model in ipairs(adapter_cfg.choices) do
    local prefix = (model == M.current[adapter_name])
        and (icons.active or "● ")
      or (icons.inactive or "  ")
    table.insert(display_items, prefix .. model)
  end

  vim.ui.select(display_items, {
    prompt = string.format(icons.prompt_model or "🤖 Select %s Model:", adapter_name),
  }, function(choice, idx)
    if choice and idx then
      local new_model = adapter_cfg.choices[idx]
      M.current[adapter_name] = new_model
      M.active_adapter = adapter_name

      -- 使用 CodeCompanion 命令接口开启新会话
      if M.config.open_chat_on_switch then
        vim.cmd("CodeCompanionChat adapter=" .. adapter_name .. " model=" .. new_model)
      end

      vim.notify(string.format(icons.notify_success or "✅ [%s] → %s", adapter_name, new_model))
    end
  end)
end

--- 弹出 adapter 选择器，先选 adapter 再选模型
function M.select_adapter_and_model()
  local adapter_names = vim.tbl_keys(M.config.adapters)
  table.sort(adapter_names)

  local icons = M.config.icons or {}

  local display_items = {}
  for _, name in ipairs(adapter_names) do
    local active = (name == M.active_adapter) and (icons.adapter_active or " ★") or ""
    table.insert(display_items, name .. "  [" .. M.current[name] .. "]" .. active)
  end

  vim.ui.select(display_items, {
    prompt = icons.prompt_adapter or "🔌 Select Adapter:",
  }, function(_, idx)
    if idx then
      M.select_model(adapter_names[idx])
    end
  end)
end

--- 返回一个可直接用于 lualine 的 component table
---@param opts? { icon?: string, color?: table }
---@return table lualine_component
function M.get_lualine_component(opts)
  opts = opts or {}
  return {
    function()
      if not M.active_adapter or M.active_adapter == "" then
        return ""
      end
      local adapter = M.active_adapter
      local model = M.current[adapter] or "?"
      local short = model:match("[^/]+$") or model
      return adapter .. "(" .. short .. ")"
    end,
    icon = opts.icon or "🤖",
    color = opts.color or { gui = "bold" },
  }
end

return M
