return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "SmiteshP/nvim-navic" },
  config = function()
    local navic = require("nvim-navic")

    local function python_venv()
      local v = os.getenv("VIRTUAL_ENV")
      if not v then
        return ""
      end
      local parent = vim.fn.fnamemodify(v, ":h:t")
      local name = vim.fn.fnamemodify(v, ":t")
      return (" %s/%s"):format(parent, name)
    end

    local function node_version()
      local pkg = vim.fn.findfile("package.json", ".;")
      if pkg == "" then
        return ""
      end
      local handle = io.popen("node -v 2>/dev/null")
      if not handle then
        return ""
      end
      local ver = handle:read("*l")
      handle:close()
      if ver then
        return (" %s"):format(ver)
      end
      return ""
    end

    local function word_count()
      if vim.bo.filetype ~= "markdown" then
        return ""
      end
      local wc = vim.fn.wordcount().words or 0
      return ("󰉿 %d words"):format(wc)
    end

    require("lualine").setup({
      options = {
        section_separators = "",
        component_separators = "",
        globalstatus = true,
      },
      sections = {
        lualine_c = {
          {
            "filename",
            path = 1,
          },
          {
            function()
              return navic.get_location()
            end,
            cond = function()
              return navic.is_available()
            end,
          },
        },
        lualine_x = {
          python_venv,
          node_version,
          word_count,
          "encoding",
          "fileformat",
          "filetype",
        },
      },
    })
  end,
}
