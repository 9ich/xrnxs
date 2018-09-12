--[[
Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
]]--

-- Reload the script whenever this file is saved. 
-- Additionally, execute the attached function.
_AUTO_RELOAD_DEBUG = function() end

-- Read from the manifest.xml file.
class "RenoiseScriptingTool" (renoise.Document.DocumentNode)
  function RenoiseScriptingTool:__init()    
    renoise.Document.DocumentNode.__init(self) 
    self:add_property("Name", "Untitled Tool")
    self:add_property("Id", "Unknown Id")
  end

local manifest = RenoiseScriptingTool()
local ok,err = manifest:load_from("manifest.xml")
local tool_name = manifest:property("Name").value
local tool_id = manifest:property("Id").value

--
-- The tool
--

function clamp(x, lo, hi) return math.max(lo, math.min(hi, x)) end


function add_volume(delta)
  local pattern_iter = renoise.song().pattern_iterator
  local pattern_index =  renoise.song().selected_pattern_index
  
  for pos,line in pattern_iter:lines_in_pattern(pattern_index) do
    for _,note_column in pairs(line.note_columns) do
      if note_column.is_selected and note_column.note_value < 119 and note_column.volume_value == 0xff then
        note_column.volume_value = 0x80
      end
      if note_column.is_selected and note_column.volume_value <= 0x80 then
        note_column.volume_value = clamp(note_column.volume_value + delta, 0, 0x80)
      end
    end
  end
end


function add_panning(delta)
  local pattern_iter = renoise.song().pattern_iterator
  local pattern_index =  renoise.song().selected_pattern_index
  
  for pos,line in pattern_iter:lines_in_pattern(pattern_index) do
    for _,note_column in pairs(line.note_columns) do
      if note_column.is_selected and note_column.note_value < 119 and note_column.panning_value == 0xff then
        note_column.panning_value = 0x40
      end
      if note_column.is_selected and note_column.panning_value <= 0x80 then
        note_column.panning_value = clamp(note_column.panning_value + delta, 0, 0x80)
      end
    end
  end
end


function add_delay(delta)
  local pattern_iter = renoise.song().pattern_iterator
  local pattern_index =  renoise.song().selected_pattern_index
  
  for pos,line in pattern_iter:lines_in_pattern(pattern_index) do
    for _,note_column in pairs(line.note_columns) do
      if note_column.is_selected and note_column.note_value < 119 then
        note_column.delay_value = clamp(note_column.delay_value + delta, 0, 0xFF)
      end
    end
  end
end


function add_effect(delta)
  local pattern_iter = renoise.song().pattern_iterator
  local pattern_index =  renoise.song().selected_pattern_index
  
  for pos,line in pattern_iter:lines_in_pattern(pattern_index) do
    for _,effect_column in pairs(line.effect_columns) do
      if effect_column.is_selected and not effect_column.is_empty then
        effect_column.amount_value = clamp(effect_column.amount_value + delta, 0, 0xFF)
      end
    end
  end
end


--
-- The keybinds
--
renoise.tool():add_keybinding({
  name = "Pattern Editor:Block Operations:Increase Volume",
  invoke = function() add_volume(1) end
})
renoise.tool():add_keybinding({
  name = "Pattern Editor:Block Operations:Decrease Volume",
  invoke = function() add_volume(-1) end
})
renoise.tool():add_keybinding({
  name = "Pattern Editor:Block Operations:Increase Panning",
  invoke = function() add_panning(1) end
})
renoise.tool():add_keybinding({
  name = "Pattern Editor:Block Operations:Decrease Panning",
  invoke = function() add_panning(-1) end
})
renoise.tool():add_keybinding({
  name = "Pattern Editor:Block Operations:Increase Delay",
  invoke = function() add_delay(1) end
})
renoise.tool():add_keybinding({
  name = "Pattern Editor:Block Operations:Decrease Delay",
  invoke = function() add_delay(-1) end
})
renoise.tool():add_keybinding({
  name = "Pattern Editor:Block Operations:Increase Effect Amount",
  invoke = function() add_effect(1) end
})
renoise.tool():add_keybinding({
  name = "Pattern Editor:Block Operations:Decrease Effect Amount",
  invoke = function() add_effect(-1) end
})

