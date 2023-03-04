surface.CreateFont("chatbox16", {
  font = "Open Sans SemiBold",
  size = 16
})

surface.CreateFont("chatbox20", {
  font = "Open Sans SemiBold",
  size = 18,
})

surface.CreateFont("chatbox24", {
  font = "Open Sans SemiBold",
  size = 24
})

surface.CreateFont("chatbox30", {
  font = "Open Sans SemiBold",
  size = 30
})

surface.CreateFont("chatbox60", {
  font = "Open Sans SemiBold",
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

include('./vgui/roundedavatar.lua')
include('./vgui/message.lua')
include('./vgui/base.lua')

local base = vgui.Create('chatBase')

local messages = {
  {
    'A long string of sample text. 冰淇淋 Maybe this will be a message in game! ',
    Color(240, 124, 60),
    'In quis suscipit augue. http://google.com - Cras tristique : nisl :smile: libero, жзклмнпрстф luctus magna tincidunt sed. ',
    Color(156, 125, 232),
    'Maecenas ut mollis justo, :cute: vitae consequat elit. :b1: Etiam อักษรจีน :stonks: tincidunt http://google.com id nunc at ultrices. '
  },
  { 
    Color(122, 160, 240),
    'Et odio pellentesque diam volutpat commodo sed egestas. Orci eu lobortis elementum nibh',
  },
  { 
    'A text message!',
  },  
  { 
    'A text message!',
  },  
  { 
    'A text message!',
  },  
  { 
    'A text message!',
  },  
  { 
    'A text message!',
  },  
  { 
    'A text message!',
  },  
  { 
    'A text message!',
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