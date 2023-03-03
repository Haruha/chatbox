local PANEL = {}
local draw, surface, string, table = draw, surface, string, table

local SEGMENT_TYPE_MATERIAL = 0
local testEmoji = Material('vgui/test.png', "noclamp mips" )

local emojis = {
  {
    name = ':smile:',
    source = 'vgui/test.png',
    size = { 16, 16 }
  }
}

for k, v in pairs(emojis) do
  if (!(string.StartWith(v.source, 'http://') || string.StartWith(v.source, 'https://'))) then
    v.isLocal = true
  end
end


AccessorFunc(PANEL, 'm_sFont', 'Font', FORCE_STRING)
AccessorFunc(PANEL, 'm_nFontSize', 'FontSize', FORCE_NUMBER)
AccessorFunc(PANEL, 'm_nMessagePadding', 'MessagePadding', FORCE_NUMBER)
AccessorFunc(PANEL, 'm_Player', 'Player')
AccessorFunc(PANEL, 'm_Message', 'Message')
AccessorFunc(PANEL, 'm_Segments', 'Segments')

function PANEL:Init()
  self:Dock(TOP)
  self:DockMargin(4, 4, 4, 0)
  self:SetFont('chatbox20')
  self:SetFontSize(draw.GetFontHeight(self:GetFont()))
  self:SetMessagePadding(4)

  self.Avatar = vgui.Create('DPanel', self)
  self.Avatar:SetSize(self:GetFontSize())
  self.Avatar.Paint = function(w, h)
    surface.SetFont(self:GetFont())
    local offset = surface.GetTextSize(LocalPlayer():Nick())
    draw.SimpleText(LocalPlayer():Nick(), self:GetFont(), 7 + self.Avatar.Image:GetWide(), self:GetMessagePadding(), Color(248, 206, 79), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.SimpleText(':', self:GetFont(), 9 + self.Avatar.Image:GetWide() + offset, self:GetMessagePadding(), Color(240, 240, 240), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) 
  end
  self.Avatar.Image = vgui.Create('AvatarImage', self.Avatar)
	self.Avatar.Image:SetSize(24, 24)
	self.Avatar.Image:SetPlayer(LocalPlayer(), 24)

  self.TextStart = vgui.Create('DPanel', self)

  self.Links = {}
end

function PANEL:AddContent(content)
  self:SetMessage(content)  
  self:GenerateLines()

  local count = 1
  for k, messagePart in pairs(self:GetMessage()) do
    if (type(messagePart) == 'string') then
      for i, word in pairs(string.Split(messagePart, ' ')) do
        if (string.StartWith(word, 'http://') || string.StartWith(word, 'https://')) then
          table.insert(self.Links, count, vgui.Create("DLabel", self))
          count = count + 1
        end
      end
    end
  end

end


function PANEL:GenerateLines()
  surface.SetFont(self:GetFont())

  -- Get width of panel
  local selfWidth = self:GetWide() - (self:GetMessagePadding() * 2)
  originalSelfWidth = selfWidth  -- Padding

  -- Hold all segments
  local formattedSegments = {}

  -- Current segment has a width, height, color, text
  local currentSegment = {
    x = self.Avatar:GetWide(), -- Offset by internal padding and avatar width 
    y = self:GetMessagePadding() + self.Avatar:GetY(),
    w = 0,
    h = 20,
    color = Color(255, 255, 255),
    text = '',
    -- material
    -- url
  }

  local lineWidth = currentSegment.x
  local spaceWidth = surface.GetTextSize(' ')

  -- Begin looping through the message
  for k, messagePart in pairs(self:GetMessage()) do
    if (type(messagePart) == 'table') then
      currentSegment.color = messagePart
      currentSegment.text = ''
      currentSegment.x = self:GetMessagePadding() + currentSegment.x + currentSegment.w - spaceWidth
      currentSegment.w = 0
    end

    if (type(messagePart) == 'string') then
      -- Split the message by spaces
      local splitText = string.Split(messagePart, ' ')

      -- Loop the words
      for k, word in pairs(splitText) do
        local wordWidth = surface.GetTextSize(word)
        -- If the word fits in the line, append the text to the segment
        if (lineWidth + wordWidth <= selfWidth - self:GetMessagePadding()) then
          -- Handle links as segments
          if (string.StartWith(word, 'http://') || string.StartWith(word, 'https://')) then
            -- Insert all regular text up until this point
            table.insert(formattedSegments, table.shallow_copy(currentSegment))

            -- Prepare current segment as a URL and save
            currentSegment.url = word
            currentSegment.x = currentSegment.x + currentSegment.w + spaceWidth
            currentSegment.w = wordWidth
            table.insert(formattedSegments, table.shallow_copy(currentSegment))

            -- Reset next segment back to regular text
            currentSegment.url = nil
            currentSegment.text = ''
            currentSegment.x = currentSegment.x + wordWidth
            currentSegment.w = 0
          elseif (word == ':smile:') then
            -- Insert all regular text up until this point
            table.insert(formattedSegments, table.shallow_copy(currentSegment))

            -- Prepare current segment as an emoji and save
            currentSegment.material = testEmoji
            currentSegment.x = currentSegment.x + currentSegment.w + spaceWidth
            currentSegment.w = 16 + spaceWidth
            table.insert(formattedSegments, table.shallow_copy(currentSegment))

            -- Reset next segment back to regular text
            currentSegment.material = nil
            currentSegment.text = ''
            currentSegment.x = currentSegment.x + 16
            currentSegment.w = 0
          else 
            currentSegment.text = currentSegment.text .. ' ' .. word
            currentSegment.w = currentSegment.w + wordWidth + spaceWidth
          end
          
          lineWidth = lineWidth + wordWidth + spaceWidth
        else -- The current segment exceeds the line length, create a new one
          table.insert(formattedSegments, table.shallow_copy(currentSegment))
          -- Reset the cursor w, move cursor y down by text height, add new word
          currentSegment.x = self:GetMessagePadding()
          currentSegment.y = currentSegment.y + currentSegment.h
          currentSegment.w = wordWidth
          currentSegment.text = word

          -- Check for URLs on the first word of the newline
          if (string.StartWith(word, 'http://') || string.StartWith(word, 'https://')) then
            currentSegment.url = word
            currentSegment.text = ''
            table.insert(formattedSegments, table.shallow_copy(currentSegment))
            currentSegment.url = nil
            currentSegment.text = ''
            currentSegment.w = 0
            currentSegment.x = currentSegment.x + wordWidth
          elseif (word == ':smile:') then
            currentSegment.material = testEmoji
            currentSegment.text = ''
            currentSegment.w = 16 + spaceWidth
            table.insert(formattedSegments, table.shallow_copy(currentSegment))
            currentSegment.material = nil
            currentSegment.text = ''
            currentSegment.x = currentSegment.x + 16
            currentSegment.w = 0
          end

          lineWidth = wordWidth
        end

        if (k == #splitText) then
          table.insert(formattedSegments, table.shallow_copy(currentSegment))
        end
      end
    end
  end

  /*
  table.insert(formattedSegments, {
    x = self:GetMessagePadding() + currentSegment.x + currentSegment.w,
    y = currentSegment.y,
    w = 16,
    h = 16,
    material = testEmoji
  })


  table.insert(formattedSegments, {
    x = self:GetMessagePadding() + currentSegment.x + currentSegment.w + 24,
    y = currentSegment.y,
    w = surface.GetTextSize('http://google.com'),
    h = self:GetFontSize(),
    url = 'http://google.com'
  })*/

  self:SetSegments(formattedSegments)
end

function PANEL:PerformLayout(width, height)
  surface.SetFont(self:GetFont())
  self.Avatar:SetWide(surface.GetTextSize(LocalPlayer():Nick() .. ':  ') + self.Avatar.Image:GetWide())
  self.Avatar:SetHeight(self:GetFontSize() + (self:GetMessagePadding() * 2))
  self.Avatar:SetPos(0, self:GetMessagePadding())

  self.Avatar.Image:SetPos(self:GetMessagePadding(), (self.Avatar:GetTall() - self.Avatar.Image:GetTall()) / 2)

  self.TextStart:SetHeight(self:GetFontSize())
  self.TextStart:SetWide(self:GetWide() - self.Avatar:GetWide() - 4)
  self.TextStart:SetPos(self.Avatar:GetWide() + self:GetMessagePadding(), self:GetMessagePadding())
  self.TextStart.Paint = function() end

  self:GenerateLines()

  local count = 1
  for k, segment in pairs(self:GetSegments()) do
    if (segment.url && self.Links[count]) then
      local label = self.Links[count]
      label:SetPos(segment.x, segment.y - (self:GetFontSize() / 4))
      label:SetSize(segment.w, segment.h + self:GetMessagePadding() + 1)
      label:SetFont(self:GetFont())
      label:SetText(segment.url)
      label:SetColor(Color(48, 167, 250))
      label:SetMouseInputEnabled( true )
      label.DoClick = function() gui.OpenURL(segment.url) end
      label.Paint = function(this, w, h) draw.RoundedBox(4, 0, h, w, 2, Color(48, 167, 250)) end
      count = count + 1
    end
  end

  local lastSegment = self:GetSegments()[#self:GetSegments()]
  self:SetHeight(lastSegment.y + lastSegment.h + (self:GetMessagePadding() * 2))
end

function PANEL:Paint(width, height)
  if (self:GetMessage() != nil) then
    -- Background
    draw.RoundedBox(4, 0, 0, width, height, Color(31, 31, 31))

    -- Individual segments
    for k, v in pairs(self:GetSegments()) do
      if (v.material) then
        surface.SetMaterial(v.material)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(v.x, v.y, 16, 16)
      elseif (v.url) then

      else
        draw.SimpleText(v.text, self:GetFont(), v.x, v.y, v.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
      end
    end
  end
end

function PANEL:OnMouseReleased(control)
	if (control == MOUSE_RIGHT) then

		local menu = DermaMenu()

		menu:AddOption('Copy', function() 
      if (ValidPanel(self)) then
        local message = ''
        for k, v in pairs(self:GetMessage()) do
          if (type(v) == 'string') then
            message = message .. v
          end
        end
        
        SetClipboardText(message)
      end
    end)

		menu:Open()
	end
end

vgui.Register('chatMessage', PANEL, 'DPanel')