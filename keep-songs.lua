-- Keep each song (a level-2 heading and everything up to the next one)
-- in one column/page instead of splitting it.
--   typst (PDF): wrap the song in an unbreakable block
--   docx: give every paragraph but the song's last the "Keep With Next" style

local function is_song_heading(b)
  return b.t == "Header" and b.level == 2 and b.identifier:match("^song%-%d+$")
end

local function keep_docx(blocks)
  -- All but the last paragraph keep with the next one, so Word moves the
  -- whole song when it doesn't fit.
  local last
  for i, b in ipairs(blocks) do
    if b.t == "Para" then last = i end
  end
  for i, b in ipairs(blocks) do
    if b.t == "Para" and i ~= last then
      blocks[i] = pandoc.Div(b, { ["custom-style"] = "Keep With Next" })
    end
  end
  return blocks
end

local function wrap(song)
  if FORMAT == "typst" then
    local out = { pandoc.RawBlock("typst", "#block(breakable: false)[") }
    for _, b in ipairs(song) do table.insert(out, b) end
    table.insert(out, pandoc.RawBlock("typst", "]"))
    return out
  elseif FORMAT == "docx" then
    return keep_docx(song)
  end
  return song
end

function Pandoc(doc)
  local out, song = {}, nil
  local function flush()
    if song then
      for _, b in ipairs(wrap(song)) do table.insert(out, b) end
      song = nil
    end
  end
  for _, b in ipairs(doc.blocks) do
    if is_song_heading(b) then
      flush()
      song = { b }
    elseif song then
      table.insert(song, b)
    else
      table.insert(out, b)
    end
  end
  flush()
  doc.blocks = out
  return doc
end
