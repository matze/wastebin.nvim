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
  -- URL of wastebin service to POST pastes to
  url = vim.env.WASTEBIN_URL,
  -- argv list used to POST the content; the URL is appended automatically
  post_cmd = { "curl", "-s", "-H", "Content-Type: application/json", "--data-binary", "@-" },
  -- argv list used to open the resulting URL; the URL is appended automatically
  open_cmd = { "open" },
  -- Ask for confirmation
  ask = true,
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
