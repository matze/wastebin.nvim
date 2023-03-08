local M = {}

local defaults = {
  url = vim.env.WASTEBIN_URL,
  post_cmd = "curl -s -H 'Content-Type: application/json' --data-binary @- ",
  open_cmd = "xdg-open",
}

local ft_to_ext = {
  cpp = "cpp",
  c = "c",
  css = "css",
  go = "go",
  html = "html",
  java = "java",
  javascript = "js",
  lua = "lua",
  markdown = "md",
  python = "py",
  rust = "rs",
  xml = "xml",
  yaml = "yaml",
}

local function get_visual_selection()
  local range_start = vim.fn.getpos("'<")
  local range_end = vim.fn.getpos("'>")
  local num_lines = math.abs(range_end[2] - range_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, range_start[2] - 1, range_end[2], false)
  lines[1] = string.sub(lines[1], range_start[3], -1)
  if num_lines == 1 then
    lines[num_lines] = string.sub(lines[num_lines], 1, range_end[3] - range_start[3] + 1)
  else
    lines[num_lines] = string.sub(lines[num_lines], 1, range_end[3])
  end
  return table.concat(lines, "\n")
end

local function get_buffer_text()
  local content = vim.api.nvim_buf_get_lines(0, 0, vim.api.nvim_buf_line_count(0), false)
  return table.concat(content, "\n")
end

M.setup = function(opts)
  M.config = vim.tbl_deep_extend("force", defaults, opts or {})

  vim.cmd([[
    command! -range -nargs=? WastePaste :lua require("wastebin")._internal_paste_cmd({ args = <q-args>, range = <range> })
  ]])
end

M._internal_paste_cmd = function(params)
  local text = ""

  if params.range > 0 then
    text = get_visual_selection()
  else
    text = get_buffer_text()
  end

  local job = vim.fn.jobstart(M.config.post_cmd .. M.config.url, {
    on_stdout = function(_, data)
      if #data[1] > 0 then
        response = vim.fn.json_decode(data[1])
        vim.fn.jobstart(M.config.open_cmd .. " " .. M.config.url .. response.path)
      end
    end,
  })

  local obj = vim.fn.json_encode({ text = text, extension = ft_to_ext[vim.bo.filetype] })
  vim.api.nvim_chan_send(job, obj)
  vim.fn.chanclose(job, "stdin")
end

return M
