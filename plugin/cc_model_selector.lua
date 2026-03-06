-- Lazy-load guard: setup() must be called by the user
-- This file only provides the :CCSelectModel command as a fallback
-- if the user forgets to call setup() manually.
if vim.g.loaded_cc_model_selector then
  return
end
vim.g.loaded_cc_model_selector = true
