-- Song Mode for
--
-- > Digitakt
-- > Model:Cycles 
-- 
-- Instructions
--
-- E1 Scroll pages [32 Bars]
-- E2 Scroll bars
-- E3 Pattern Number
--
-- K1 Alt
-- K2 Start at Position X / Stop
-- K2+K1 Start at Bar 1 / Stop  
-- K3 Add pattern
-- K3+K1 Delete pattern 

m = midi.connect()

local UI = require "ui"
local pages
local playback_icon
local fileselect = require "fileselect"
local textentry = require "textentry"
local SCREEN_FRAMERATE = 15
local screen_refresh_metro
local screen_dirty = true

function init()
  pages = UI.Pages.new(1, 11)
  playback_icon = UI.PlaybackIcon.new(0,55, 8)
  params:add_number("pattern", "Pattern", 0, 127, 0)
  params:hide("pattern")
  params:add_number("bars", "Bars", 1, 352, 1)
  params:hide("bars")
  params:add_separator("Song Mode")
  params:add{type='option',  id='loop', name='Loop Song', options={'Off', 'On'}, default=2}
  params:add_separator("")
  params:add_trigger('save_p', "<< Save Song" )
  params:set_action('save_p', function(x) textentry.enter(savestate) end)
  params:add_separator("")
  params:add_trigger('load_p', ">> Load Song" )
  params:set_action('load_p', function(x) fileselect.enter(_path.data.. "/songmode/", loadstate) end)
  params:add_separator("")
  params:add_trigger('clean_all', "Clean Song" )
  params:set_action('clean_all', function(x) t = {} end)
  
  beat_duration = clock.get_beat_sec()
  norns.enc.sens(1,3)
  norns.enc.sens(2,3)
  norns.enc.sens(3,3)
  t = {}
  t2 = {}
  lp = 0
  x = 0
  y = 1
  u = 0
  o = 0
  s = 0
  d = {}
end

function loop()
  l = params:get("loop")
  if l == 1 then
    lp = 1
  elseif l == 2 then
    lp = 10000
  end
end

function pulse()
  loop()
  m:start()
  for k = 1, lp do
    u = y - 1
    for i = 1, tab.count(t) - y + 1 do
      
      clock.sync(2)
      u = u + 1
      r = t2[u]
      s = t[u]
      print(r)
      m:program_change(r, 1)
      clock.sync(2)
      clock.sleep(beat_duration/2)
      
      redraw()
    end
  end
end  

function pulse2()
  loop()
  m:start()
  for k = 1, lp do
    u = 0
    for i = 1, tab.count(t) do
      
      clock.sync(2)
      u = u + 1
      r = t2[u]
      s = t[u]
      m:program_change(r, 1)
      clock.sync(2)
      clock.sleep(beat_duration/2)
      redraw()
    end
  end
end  

function key(n,z)

  if n == 1 then
    alt = z == n and true or false
  end
  
  if n == 2 and z == 1 then
      if alt then
        if o == 0 then
          o = o + 1
          q = clock.run(pulse2)
          else 
          m:stop()
          clock.cancel(q)
          o = o - 1
          u = 0
        end
      else
        if o == 0 then
          o = o + 1
          q = clock.run(pulse)
        else 
          m:stop()
          clock.cancel(q)
          o = o - 1
          u = 0
        end
      end
  elseif n == 3 and z == 1 then
    if alt then
      table.remove(t, y)
      table.remove(t2, y)
    else
      if x <= 15 then
        table.insert(t, y, "A" .. x + 1)
      elseif x <= 31 then
        table.insert(t, y, "B" .. x - 15)
      elseif x <= 47 then
        table.insert(t, y, "C" .. x - 31)
      elseif x <= 63 then
        table.insert(t, y, "D" .. x - 47)
      elseif x <= 79 then
        table.insert(t, y, "E" .. x - 63)
      elseif x <= 95 then
        table.insert(t, y, "F" .. x - 79)
      elseif x <= 111 then
        table.insert(t, y, "G" .. x - 95)
      elseif x <= 127 then
        table.insert(t, y, "H" .. x - 111)
      end
    table.insert(t2, y, x)
    end
   end
  redraw()
end

function savestate(txt)
  if txt then
    tab.save(t2, _path.data.. "/songmode/" ..txt..".txt")
  end
end

function loadstate(file)
  if file ~= nil then 
    init()
  t2 = tab.load(file)
  pattern_no()
  
  else
    print("cancle")
  end
end

function pattern_no()
  for i=1, tab.count(t2) do
    s = s + 1
    d = t2[s]
    if d <= 15 then
      table.insert(t, s, "A" .. d + 1)
    elseif d <= 31 then
      table.insert(t, s, "B" .. d - 15)
    elseif d <= 47 then
      table.insert(t, s, "C" .. d - 31)
    elseif d <= 63 then
      table.insert(t, s, "D" .. d - 47)
    elseif d <= 79 then
      table.insert(t, s, "E" .. d - 63)
    elseif d <= 95 then
      table.insert(t, s, "F" .. d - 79)
    elseif d <= 111 then
      table.insert(t, s, "G" .. d - 95)
    elseif d <= 127 then
      table.insert(t, s, "H" .. d - 111)
    end
  end
end

function enc(n,delta)
  if n == 3 then 
    params:delta("pattern", delta)
    x = params:get("pattern")
   
  elseif n == 1 then
    pages:set_index_delta(util.clamp(delta, -1, 1), false)
  
  elseif n == 2 then 
    params:delta("bars", delta)
    y = params:get("bars")
  end
  
  redraw()
end

function pat_text()
  local x_pos = 15
  local x_indent = 13
  local x_indent2 = 14
  local y_pos = 7
  local y_pos2 = 9
  local x_line_move = 120
  local y_line_move = 8
  local i_start = (-32 + (pages.index * 32 + 1))
    
  for i = i_start, tab.count(t) do
    if i <= 8 + ((pages.index - 1) * 32) then
      screen.move(i * x_pos - (x_indent + (0 + (pages.index - 1) * 4) * x_line_move), y_pos + (0 * y_line_move))
      screen.text(t[i])
    elseif i <= 16 + ((pages.index - 1) * 32) then
      screen.move(i * x_pos - (x_indent + (1 + (pages.index - 1) * 4) * x_line_move), y_pos + (1 * y_line_move))
      screen.text(t[i])
    elseif i <= 24 + ((pages.index - 1) * 32) then
      screen.move(i * x_pos - (x_indent + (2 + (pages.index - 1) * 4) * x_line_move), y_pos + (2 * y_line_move))
      screen.text(t[i])
    elseif i <= 32 + ((pages.index - 1) * 32) then
      screen.move(i * x_pos - (x_indent + (3 + (pages.index - 1) * 4) * x_line_move), y_pos + (3 * y_line_move))
      screen.text(t[i])
    end  
  end

  if u <= 8 + ((pages.index - 1) * 32) then 
    screen.move(u * x_pos - (x_indent2 + (0 + (pages.index - 1) * 4) * x_line_move), (y_pos2 + (0 * y_line_move)))
    screen.text("___")
  elseif u <= 16 + ((pages.index - 1) * 32) then
    screen.move(u * x_pos - (x_indent2 + (1 + (pages.index - 1) * 4) * x_line_move), (y_pos2 + (1 * y_line_move)))
    screen.text("___")
  elseif u <= 24 + ((pages.index - 1) * 32) then
    screen.move(u * x_pos - (x_indent2 + (2 + (pages.index - 1) * 4) * x_line_move), (y_pos2 + (2 * y_line_move)))
    screen.text("___")
  elseif u <= 32 + ((pages.index - 1) * 32) then
    screen.move(u * x_pos - (x_indent2 + (3 + (pages.index - 1) * 4) * x_line_move), (y_pos2 + (3 * y_line_move)))
    screen.text("___")
  end
    
  if y <= 8 + ((pages.index - 1) * 32) then
    screen.rect(y * x_pos - ((0 + (pages.index - 1) * 4) * x_line_move) - 14, (-7+8) , 15, 8)
    screen.stroke()
  elseif y <= 16 + ((pages.index - 1) * 32) then
    screen.rect(y * x_pos - ((1 + (pages.index - 1) * 4) * x_line_move) - 14, (-7+16) , 15, 8)
    screen.stroke()
  elseif y <= 24 + ((pages.index - 1) * 32) then
    screen.rect(y * x_pos - ((2 + (pages.index - 1) * 4) * x_line_move) - 14, (-7+24) , 15, 8)
    screen.stroke()
  elseif y <= 32 + ((pages.index - 1) * 32) then
    screen.rect(y * x_pos - ((3 + (pages.index - 1) * 4) * x_line_move) - 14, (-7+32) , 15, 8)
    screen.stroke()
  end
end


function redraw()
  screen.clear()
  pages:redraw()
  
  if o == 0 then
    playback_icon.status = 0
  else
    playback_icon.status = 1
  end
    playback_icon:redraw()
  
  screen.move(0,39) -- text: add pattern #
  screen.level(15)
    if x <= 15 then
    screen.text("Add A" .. x+1)
  elseif x <= 31 then
    screen.text("Add B" .. x-15)
  elseif x <= 47 then
    screen.text("Add C" .. x-31)
  elseif x <= 63 then
    screen.text("Add D" .. x-47)
  elseif x <= 79 then
    screen.text("Add E" .. x-63)
  elseif x <= 95 then
    screen.text("Add F" .. x-79)
  elseif x <= 111 then
    screen.text("Add G" .. x-95)
  elseif x <= 127 then
    screen.text("Add H" .. x-111)
  end
  
  screen.move(0, 46)
  screen.text("Position " ..y)
  
  screen.move(0, 53)
  if u > 0 then
    screen.text("Bar " ..u)
  else
    screen.text("Bar " ..u+1)
  end
  
  screen.level(1)
  for m = 1,8 do
    for n = 1,4 do
      screen.rect(m*15-14, n*8-7, 15, 8)
      screen.stroke()
    end
  end

  screen.level(5) -- song position indicator
  if u <= 32 then
    screen.move(122,4)
    screen.text("o")
  elseif u <= 64  then
    screen.move(122,10)
    screen.text("o")
  elseif u <= 96 then
    screen.move(122,16)
    screen.text("o")
  elseif u <= 128 then
    screen.move(122,22)
    screen.text("o")
  elseif u <= 160 then
    screen.move(122,28)
    screen.text("o")
  elseif u <= 192  then
    screen.move(122,34)
    screen.text("o")
  elseif u <= 224 then
    screen.move(122,40)
    screen.text("o")
  elseif u <= 256 then
    screen.move(122,46)
    screen.text("o")
  elseif u <= 288 then
    screen.move(122,52)
    screen.text("o")
  elseif u <= 320 then
    screen.move(122,58)
    screen.text("o")
  elseif u <= 352 then
    screen.move(122,64)
    screen.text("o")  
  end 
  
  screen.level(10)  
  for i=1, 11 do
    if pages.index == i then
      pat_text()
    end
  end
  screen.update()
end
