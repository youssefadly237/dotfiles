-- Filetype detection for muttrc files
vim.filetype.add({
  pattern = {
    [".*%.muttrc"] = "muttrc",
  },
})
