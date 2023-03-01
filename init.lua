surface.CreateFont("chatbox16", {
  font = "Open Sans",
  size = 16
})

surface.CreateFont("chatbox18", {
  font = "Open Sans SemiBold",
  size = 18
})

surface.CreateFont("chatbox20", {
  font = "Open Sans",
  size = 20
})

surface.CreateFont("chatbox24", {
  font = "Open Sans",
  size = 24
})

surface.CreateFont("chatbox30", {
  font = "Open Sans",
  size = 30
})

surface.CreateFont("chatbox60", {
  font = "Open Sans",
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
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. ',
    Color(240, 124, 60),
    'In quis suscipit augue. Cras tristique nisl libero, a luctus magna tincidunt sed. ',
    Color(156, 125, 232),
    'Maecenas ut mollis justo, vitae consequat elit. Etiam tincidunt id nunc at ultrices.'
  },
  { 
    Color(122, 160, 240),
    'Et odio pellentesque diam volutpat commodo sed egestas. Orci eu lobortis elementum nibh',
    Color(102, 219, 134),
    'tellus molestie nunc non. Quis viverra nibh cras pulvinar mattis nunc sed blandit.',
    Color(240, 240, 240), 
    'Venenatis a condimentum vitae sapien pellentesque habitant morbi tristique.',
  },
  --[['Nisi lacus sed viverra tellus in hac habitasse. Morbi tristique senectus et netus et malesuada fames ac turpis. Lacus sed viverra tellus in hac habitasse platea. Cursus metus aliquam eleifend mi in.',
  'Fringilla phasellus faucibus scelerisque eleifend donec pretium vulputate sapien nec. Donec ultrices tincidunt arcu non sodales. A arcu cursus vitae congue mauris rhoncus aenean vel.',
  'Eget dolor morbi non arcu. Egestas fringilla phasellus faucibus scelerisque eleifend. Ipsum nunc aliquet bibendum enim facilisis gravida neque convallis a. Nunc non blandit massa enim nec dui nunc mattis enim.',
  'Eu tincidunt tortor aliquam nulla. Vitae congue mauris rhoncus aenean vel elit scelerisque mauris pellentesque.',
  'Tortor pretium viverra suspendisse potenti nullam ac tortor vitae purus. Diam ut venenatis tellus in metus vulputate eu scelerisque. Adipiscing elit ut aliquam purus sit amet.',
  'Blandit turpis cursus in hac habitasse platea dictumst quisque. Morbi tempus iaculis urna id volutpat. Eu feugiat pretium nibh ipsum. Est placerat in egestas erat imperdiet. Senectus et netus et malesuada fames. Faucibus turpis in eu mi bibendum neque egestas congue quisque.',
  'Accumsan sit amet nulla facilisi morbi tempus iaculis. Eu lobortis elementum nibh tellus molestie nunc non. Ridiculus mus mauris vitae ultricies leo integer malesuada nunc vel.',
  'Eget felis eget nunc lobortis mattis aliquam faucibus purus in. Volutpat sed cras ornare arcu dui vivamus arcu felis. Montes nascetur ridiculus mus mauris.',
  'Condimentum lacinia quis vel eros donec. Lacus sed viverra tellus in. Neque gravida in fermentum et sollicitudin ac orci phasellus egestas.',
  'Aenean vel elit scelerisque mauris pellentesque pulvinar. Sed velit dignissim sodales ut.', 
  'Maecenas et euismod mauris. Fusce tristique, ipsum a cursus interdum, felis sapien elementum sapien'--]]
}

local count = 1
timer.Create('chatTimer', 1, #messages, function()
  if (IsValid(base)) then
    base:AddMessage(messages[count])
    count = count + 1
  end
end)