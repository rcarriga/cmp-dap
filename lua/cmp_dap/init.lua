local api = vim.api
local dap_repl = require("dap.repl")
local dap = require("dap")
local cmp = require("cmp")

local kinds = cmp.lsp.CompletionItemKind

local kind_map = {
  method = kinds.Method,
  ["function"] = kinds.Function,
  constructor = kinds.Constructor,
  field = kinds.Field,
  variable = kinds.Variable,
  class = kinds.Class,
  interface = kinds.Interface,
  module = kinds.Module,
  property = kinds.Property,
  unit = kinds.Unit,
  value = kinds.Value,
  enum = kinds.Enum,
  keyword = kinds.Keyword,
  snippet = kinds.Snippet,
  text = kinds.Text,
  color = kinds.Color,
  file = kinds.File,
  reference = kinds.Reference,
  customcolor = kinds.Color,
}
local source = {}

function source.new()
  local self = setmetatable({}, { __index = source })
  return self
end

function source.is_dap_buffer(bufnr)
  local filetype = vim.api.nvim_buf_get_option(bufnr or 0, "filetype")
  if vim.startswith(filetype, "dapui_") then
    return true
  end
  if filetype == "dap-repl" then
    return true
  end

  return false
end

---Return this source is available in current context or not. (Optional)
---@return boolean
function source:is_available()
  local session = dap.session()
  if not session then
    return false
  end

  local supportsCompletionsRequest = ((session or {}).capabilities or {}).supportsCompletionsRequest
  if not supportsCompletionsRequest then
    return false
  end

  local bufnr = vim.api.nvim_get_current_buf()

  return self.is_dap_buffer(bufnr)
end

---Return the debug name of this source. (Optional)
---@return string
function source:get_debug_name()
  return "cmp-dap"
end

---Invoke completion. (Required)
---@param _ cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(_, callback)
  local session = assert(dap.session())

  local col = api.nvim_win_get_cursor(0)[2]
  local line = api.nvim_get_current_line()

  local offset = vim.startswith(line, "dap> ") and 5 or 0
  local typed = line:sub(offset + 1, col)

  ---@type lsp.CompletionItem[]
  local completions = {}
  local _add = function(val)
    table.insert(completions, { insertText = val, label = val, kind = kinds.Keyword })
  end

  -- REPL Commands (including custom commands)
  if vim.startswith(typed, ".") then
    for _, values in pairs(dap_repl.commands) do
      for _, directive in pairs(values) do
        if type(directive) == "string" and vim.startswith(directive, typed) then
          _add(directive)
        end
      end
    end
    for command, _ in pairs(dap_repl.commands.custom_commands or {}) do
      if vim.startswith(command, typed) then
        _add(command)
      end
    end
  end

  session:request("completions", {
    frameId = (session.current_frame or {}).id,
    text = typed,
    column = col + 1 - offset,
  }, function(err, response)
    if err then
      return
    end
    for _, item in pairs(response.targets) do
      if item.type then
        item.kind = kind_map[item.type]
      end
      item.insertText = item.text or item.label
      table.insert(completions, item)
    end

    callback(completions)
  end)
end

---Resolve completion item. (Optional)
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:resolve(completion_item, callback)
  callback(completion_item)
end

---Get trigger characters. (Optional)
---@return string[]
function source:get_trigger_characters()
  local session = require('dap').session()
  local trigger_characters = session.capabilities.completionTriggerCharacters or {}
  local contains_dot = false
  for _, trigger_character in ipairs(trigger_characters) do
      if trigger_character == '.' then
        contains_dot = true
      end
  end
  if not contains_dot then
    table.insert(trigger_characters, '.') -- always add '.' as nvim-dap adds custom commands starting with .
  end
  return trigger_characters
end

---Execute command after item was accepted.
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:execute(completion_item, callback)
  callback(completion_item)
end

return source
