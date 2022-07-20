# cmp-dap

nvim-cmp source for nvim-dap REPL and nvim-dap-ui buffers

## Setup

```lua
require("cmp").setup.filetype({ "dap-repl", "dapui_watches" }, {
  sources = {
    { name = "dap" },
  },
})
```
