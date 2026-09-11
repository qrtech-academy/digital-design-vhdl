-- vhdlbook.lua - the one piece of the design that TeX macros cannot do cleanly.
--
-- \code{...} typesets VHDL exactly as it is written in the lectures. \detokenize gets most of the
-- way, but leaves two artifacts: it doubles every #, and it puts a space after every control
-- word. VHDL rarely meets either, but the shell lines and the Boolean algebra the lectures quote
-- beside it do, so both are undone here. A line break is allowed after a comma and after the dot
-- in a selected name, so ieee.std_logic_1164.all or a long port list can break rather than run
-- into the margin.

local catcode_other = -2

function vhdlbook_code(s)
  s = s:gsub("#+", "#")
  s = s:gsub("(\\%a+) ", "%1")
  -- \%, \{ and \} are how a literal percent sign or an unbalanced brace has to be written inside
  -- a TeX argument, \# is how a # has to be written in a heading or a caption, and \\ is a
  -- lone backslash.
  s = s:gsub("\\([%%{}#\\])", "%1")
  -- A break is allowed after a comma with no space behind it, and after a dot with a letter
  -- behind it; a comma followed by a space needs nothing, because the space is a breakpoint
  -- already, and a dot between digits is part of a number. Each tex.sprint is read as a line of
  -- its own and TeX skips the spaces a line starts with, so no chunk may begin with one.
  local start = 1
  while true do
    local i = s:find(",[^ ]", start)
    local k = s:find("%.%a", start)
    if k and (not i or k < i) then i = k end
    if not i then break end
    tex.sprint(catcode_other, s:sub(start, i))
    -- Discouraged rather than free, so a line breaks at a space when it can.
    tex.sprint("\\penalty100 ")
    start = i + 1
  end
  tex.sprint(catcode_other, s:sub(start))
end
