-- Turn the hand-kept index in songs.md (the #song-index div) into an index
-- with page numbers, and start the songs on a new page.
--   typst (PDF): typst's built-in outline, filled in at render time
--   docx: a Word TOC field; Word fills in the page numbers when it opens the file

local function page_break()
  if FORMAT == "typst" then
    return pandoc.RawBlock("typst", "#pagebreak()")
  elseif FORMAT == "docx" then
    return pandoc.RawBlock("openxml", '<w:p><w:r><w:br w:type="page"/></w:r></w:p>')
  end
end

local function xml_escape(text)
  return (text:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

-- Split the index paragraph on its line breaks into {text, anchor} entries.
local function entries(div)
  local result, current = {}, {}
  local function flush()
    if #current > 0 then
      local anchor
      for _, el in ipairs(current) do
        if el.t == "Link" then anchor = el.target:gsub("^#", "") end
      end
      table.insert(result, { text = pandoc.utils.stringify(current), anchor = anchor })
      current = {}
    end
  end
  for _, el in ipairs(div.content[1].content) do
    if el.t == "LineBreak" then flush() else table.insert(current, el) end
  end
  flush()
  return result
end

-- Word TOC field, pre-filled with linked titles so the index is never empty.
-- Word recomputes it with page numbers on open (updateFields in reference.docx);
-- other editors show the pre-filled titles.
local function docx_toc(div)
  local list = entries(div)
  local paras = {}
  for i, e in ipairs(list) do
    local p = '<w:p><w:pPr><w:pStyle w:val="TOC2"/></w:pPr>'
    if i == 1 then
      p = p .. '<w:r><w:fldChar w:fldCharType="begin" w:dirty="true"/></w:r>'
        .. '<w:r><w:instrText xml:space="preserve"> TOC \\o "2-2" \\h \\z \\u </w:instrText></w:r>'
        .. '<w:r><w:fldChar w:fldCharType="separate"/></w:r>'
    end
    p = p .. '<w:hyperlink w:anchor="' .. e.anchor .. '"><w:r><w:t xml:space="preserve">'
      .. xml_escape(e.text) .. '</w:t></w:r></w:hyperlink>'
    if i == #list then
      p = p .. '<w:r><w:fldChar w:fldCharType="end"/></w:r>'
    end
    table.insert(paras, p .. '</w:p>')
  end
  return pandoc.RawBlock("openxml", table.concat(paras, "\n"))
end

local function toc(div)
  if FORMAT == "typst" then
    return pandoc.RawBlock("typst", "#outline(title: none, depth: 2)")
  elseif FORMAT == "docx" then
    return docx_toc(div)
  end
end

function Header(h)
  -- Keep the "Index" heading itself out of the index.
  if h.identifier == "index" then
    if FORMAT == "typst" then
      return pandoc.RawBlock("typst", "#heading(level: 2, outlined: false)[Index]")
    elseif FORMAT == "docx" then
      return pandoc.Div(pandoc.Para(h.content), {["custom-style"] = "TOC Heading"})
    end
  end
end

function Div(d)
  if d.identifier == "song-index" and (FORMAT == "typst" or FORMAT == "docx") then
    return { toc(d), page_break() }
  end
end
