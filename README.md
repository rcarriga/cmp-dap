# cmp-dap

nvim-cmp source for nvim-dap REPL and nvim-dap-ui buffers

## Setup

```lua
require'cmp'.setup {
  -- nvim-cmp by defaults disables autocomplete for prompt buffers
  enabled = function ()
    return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt"
      or require("cmp_dap").is_dap_buffer()
  end,
  sources = {
    { name = 'dap' }
  }
}
```