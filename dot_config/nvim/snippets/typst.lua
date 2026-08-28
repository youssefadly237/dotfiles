local ls = require("luasnip")
local s, i = ls.snippet, ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

return {
  s(
    "fdef", -- footer definition
    fmt("#footnote[{term} ({origin}): {explanation} @{citation}]", {
      term = i(1, "Term"),
      origin = i(2, "origin"),
      explanation = i(3, "explanation"),
      citation = i(4, "citation"),
    })
  ),
}
