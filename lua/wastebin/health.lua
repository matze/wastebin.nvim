local M = {}

function M.check()
  vim.health.start("wastebin")

  local config = require("wastebin").config

  if config.url and config.url ~= "" then
    vim.health.ok("URL configured: " .. config.url)
  else
    vim.health.warn("URL not configured. Set WASTEBIN_URL or pass `url` to setup().")
  end

  local function check_executable(label, argv)
    local bin = argv and argv[1]
    if not bin then
      vim.health.error(("`%s` is empty"):format(label))
      return
    end
    if vim.fn.executable(bin) == 1 then
      vim.health.ok(("`%s` binary `%s` found in PATH"):format(label, bin))
    else
      vim.health.error(("`%s` binary `%s` not found in PATH"):format(label, bin))
    end
  end

  check_executable("post_cmd", config.post_cmd)
  check_executable("open_cmd", config.open_cmd)
end

return M
