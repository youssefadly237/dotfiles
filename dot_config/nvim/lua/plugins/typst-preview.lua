local function get_local_ip()
  local output = vim.fn.system("ip route get 1.1.1.1")

  if vim.v.shell_error ~= 0 then
    return "127.0.0.1"
  end

  return output:match("src%s+(%S+)") or "127.0.0.1"
end

return {
  {
    "chomosuke/typst-preview.nvim",
    lazy = false,
    version = "1.*",
    opts = {
      debug = true,
      host = get_local_ip(),
      port = 11612,

      dependencies_bin = {
        tinymist = "tinymist",
      },
      extra_args = { "--refresh-style", "on-type" },
    },
  },
}
