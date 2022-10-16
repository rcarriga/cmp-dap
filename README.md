# cmp-dap

nvim-cmp source for nvim-dap REPL and nvim-dap-ui buffers

## Setup

You must be using an adapter that supports completion requests.
The following should print `true` when you are in an active debug session

```
:lua= require("dap").session().capabilities.supportsCompletionsRequest
```

```lua
require("cmp").setup({
  enabled = function()
    return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt"
        or require("cmp_dap").is_dap_buffer()
  end
})

require("cmp").setup.filetype({ "dap-repl", "dapui_watches", "dapui_hover" }, {
  sources = {
    { name = "dap" },
  },
})
```
