---@class wastebin.Config
---@field url? string Base URL of the wastebin instance.
---@field post_cmd string[] Argv list used to POST the paste; URL is appended.
---@field open_cmd string[] Argv list used to open the result URL; URL is appended.
---@field ask boolean Whether to prompt for confirmation before sending.

---@class wastebin.Module
---@field config wastebin.Config
local M = {}

---@type wastebin.Config
local defaults = {
  url = vim.env.WASTEBIN_URL,
  post_cmd = { "curl", "-s", "-H", "Content-Type: application/json", "--data-binary", "@-" },
  open_cmd = { "open" },
  ask = true,
}

local ft_to_ext = {
  ada = "ada",
  c = "c",
  clojure = "clj",
  cmake = "CMakeLists.txt",
  cmakecache = "CMakeCache.txt",
  cpp = "cpp",
  cs = "cs",
  css = "css",
  dart = "dart",
  elm = "elm",
  go = "go",
  groovy = "groovy",
  html = "html",
  java = "java",
  javascript = "js",
  jq = "jq",
  kotlin = "kt",
  lisp = "lisp",
  lua = "lua",
  make = "make",
  markdown = "md",
  ninja = "ninja",
  nix = "nix",
  pascal = "pas",
  perl = "pl",
  php = "php",
  proto = "proto",
  python = "py",
  rust = "rs",
  scalar = "scalar",
  swift = "swift",
  tcl = "tcl",
  tex = "tex",
  toml = "toml",
  xml = "xml",
  yaml = "yaml",
  zig = "zig",
}

local function strip_trailing_slash(s)
  return (s:gsub("/+$", ""))
end

---@param config wastebin.Config
---@return wastebin.Config
local function normalize(config)
  if config.url then
    config.url = strip_trailing_slash(config.url)
  end
  return config
end

M.config = normalize(vim.deepcopy(defaults))

local function get_visual_selection()
  local lines = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = vim.fn.visualmode() })
  return table.concat(lines, "\n")
end

local function get_buffer_text()
  local content = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
  return table.concat(content, "\n")
end

---@return string?
local function get_extension()
  local ext = ft_to_ext[vim.bo.filetype]
  if ext then
    return ext
  end
  local file_ext = vim.fn.expand("%:e")
  if file_ext ~= "" then
    return file_ext
  end
  return nil
end

---@param params { range: integer }
local function send(params)
  local text = params.range > 0 and get_visual_selection() or get_buffer_text()

  local body = vim.json.encode({
    text = text,
    extension = get_extension(),
  })

  local post = vim.list_extend(vim.deepcopy(M.config.post_cmd), { M.config.url })

  vim.system(post, { stdin = body, text = true }, function(out)
    if out.code ~= 0 then
      vim.schedule(function()
        vim.notify("wastebin: POST failed: " .. (out.stderr or ""), vim.log.levels.ERROR)
      end)
      return
    end

    local ok, response = pcall(vim.json.decode, out.stdout or "")
    if not ok or type(response) ~= "table" or type(response.path) ~= "string" then
      vim.schedule(function()
        vim.notify("wastebin: unexpected response: " .. (out.stdout or ""), vim.log.levels.ERROR)
      end)
      return
    end

    local open = vim.list_extend(vim.deepcopy(M.config.open_cmd), { M.config.url .. response.path })
    vim.system(open, { detach = true })
  end)
end

---Paste the current buffer or visual selection to the configured URL.
---@param params { range: integer } `range` is non-zero when a visual selection should be sent.
function M.paste(params)
  if M.config.url == nil then
    vim.notify("wastebin: no URL configured (set WASTEBIN_URL or pass `url` to setup())", vim.log.levels.ERROR)
    return
  end

  if not M.config.ask then
    return send(params)
  end

  vim.ui.select({ "yes", "no" }, {
    prompt = "Really paste to " .. M.config.url .. "?",
  }, function(choice)
    if choice == "yes" then
      send(params)
    end
  end)
end

---Merge user options into the default configuration.
---@param opts? wastebin.Config
function M.setup(opts)
  M.config = normalize(vim.tbl_deep_extend("force", defaults, opts or {}))
end

return M
