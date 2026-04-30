if vim.g.loaded_wastebin then
  return
end
vim.g.loaded_wastebin = true

vim.api.nvim_create_user_command("WastePaste", function(opts)
  require("wastebin").paste({ range = opts.range })
end, {
  range = true,
  desc = "Paste buffer or visual selection to wastebin",
})
