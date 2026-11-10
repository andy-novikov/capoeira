-- ::: {.columns} ... ::: lays its content out in two columns (typst/PDF only).
function Div(d)
  if d.classes:includes("columns") and FORMAT == "typst" then
    local blocks = { pandoc.RawBlock("typst", "#columns(2)[") }
    for _, b in ipairs(d.content) do table.insert(blocks, b) end
    table.insert(blocks, pandoc.RawBlock("typst", "]"))
    return blocks
  end
end

-- A heading with {.colbreak} starts a new column (typst/PDF only).
function Header(h)
  if h.classes:includes("colbreak") and FORMAT == "typst" then
    return { pandoc.RawBlock("typst", "#colbreak()"), h }
  end
end
