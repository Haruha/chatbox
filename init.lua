surface.CreateFont("chatbox16", {
  font = "Coolvetica Lt",
  size = 16
})

surface.CreateFont("chatbox20", {
  font = "Coolvetica Lt",
  size = 18
})

surface.CreateFont("chatbox24", {
  font = "Coolvetica Lt",
  size = 24
})

surface.CreateFont("chatbox30", {
  font = "Coolvetica Lt",
  size = 30
})

surface.CreateFont("chatbox60", {
  font = "Coolvetica Lt",
  size = 60
})

function printf(...) print(string.format(...)) end

function table.shallow_copy(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

include('./vgui/message.lua')
include('./vgui/base.lua')

local base = vgui.Create('chatBase')

local messages = {
  {
    'A long string of sample text. 冰淇淋 Maybe this will be a message in game! ',
    Color(240, 124, 60),
    'In quis suscipit augue. http://google.com - Cras tristique nisl :smile: libero, жзклмнпрстф luctus magna tincidunt sed. ',
    Color(156, 125, 232),
    'Maecenas ut mollis justo, vitae consequat elit. Etiam อักษรจีน tincidunt http://google.com id nunc at ultrices. '
  },
  { 
    Color(122, 160, 240),
    'Et odio pellentesque diam volutpat commodo sed egestas. Orci eu lobortis elementum nibh',
    Color(102, 219, 134),
    'tellus molestie nunc non. Quis viverra nibh cras pulvinar mattis nunc sed blandit.',
    Color(240, 240, 240), 
    'Venenatis a condimentum vitae sapien pellentesque habitant morbi tristique.',
  },
  { 
    'A text message!',
  },
}

local count = 1
for k, v in pairs(messages) do
  if (IsValid(base)) then
    base:AddMessage(v)
  end
end