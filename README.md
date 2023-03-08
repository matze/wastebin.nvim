# wastebin.nvim

A [wastebin](https://github.com/matze/wastebin) plugin to paste the current
buffer or selection.

## 📦 Installation

Use your preferred package manage, for example
[Lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
return {
  {
    "matze/wastebin.nvim",
    config = true,
  }
}
```

## ⚙️ Configuration

Either set the wastebin URL as `WASTEBIN_URL` environment variable or pass it to
the setup function

```lua
require("wastebin").setup({
  url = "https://foo.bar.com",
})
```

The plugin comes with the following defaults:

```lua
{
  url = vim.env.WASTEBIN_URL,
  -- Shell command to POST the content
  post_cmd = "curl -s -H 'Content-Type: application/json' --data-binary @- ",
  -- Shell command to open URLs
  open_cmd = "xdg-open",
}
```

## ⌨️ Commands

To paste the entire buffer or a selection call
```vim
:WastePaste
```
and
```vim
:'<,'>WastePaste
```
respectively.
