local PANEL = {}
local draw, surface, string, table = draw, surface, string, table

AccessorFunc(PANEL, 'm_sFont', 'Font', FORCE_STRING)
AccessorFunc(PANEL, 'm_nFontSize', 'FontSize', FORCE_NUMBER)
AccessorFunc(PANEL, 'm_Message', 'Message')
AccessorFunc(PANEL, 'm_Segments', 'Segments')

function PANEL:Init() 
  self:Dock(TOP)
  self:DockMargin(4, 4, 4, 0)
	-- self:LerpPositions(1, true)
  self:SetFont('chatbox18')
  self:SetFontSize(draw.GetFontHeight(self:GetFont()))

  self.Avatar = vgui.Create('DPanel', self)
  self.Avatar.Paint = function(w, h)
    surface.SetFont(self:GetFont())
    local offset = surface.GetTextSize(LocalPlayer():Nick())
    draw.SimpleText(LocalPlayer():Nick(), self:GetFont(), 7 + self.Avatar.Image:GetWide(), 0, Color(248, 206, 79), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.SimpleText(':', self:GetFont(), 6 + self.Avatar.Image:GetWide() + offset, 0, Color(240, 240, 240), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) 
  end
  self.Avatar.Image = vgui.Create('AvatarImage', self.Avatar)
	self.Avatar.Image:SetSize(20, 20)
	self.Avatar.Image:SetPlayer(LocalPlayer(), 16)

  self.TextStart = vgui.Create('DPanel', self)
end

function PANEL:GenerateLines()
  surface.SetFont(self:GetFont())

  -- Get width of panel
  local selfWidth = self:GetWide() - (4 * 2)
  originalSelfWidth = selfWidth  -- Padding

  -- Hold all segments
  local formattedSegments = {}

  -- Current segment has a width, height, color, text
  local currentSegment = {
    x = 4 + self.Avatar:GetWide(), -- Offset by internal padding and avatar width 
    y = 4,
    w = 0,
    h = 20,
    color = Color(255, 255, 255),
    text = ''
  }

  local lineWidth = currentSegment.x
  local spaceWidth = surface.GetTextSize(' ')

  -- Begin looping through the message
  for k, messagePart in pairs(self:GetMessage()) do
    if (type(messagePart) == 'table') then
      -- table.insert(formattedSegments, table.shallow_copy(currentSegment))
      currentSegment.color = messagePart
      currentSegment.text = ''
      currentSegment.x = 4 + currentSegment.x + currentSegment.w - spaceWidth
      currentSegment.w = 0
    end

    if (type(messagePart) == 'string') then
      -- Split the message by spaces
      local splitText = string.Split(messagePart, ' ')

      -- Loop the words
      for k, word in pairs(splitText) do
        local wordWidth = surface.GetTextSize(word)
        -- If the word fits in the line, add it to the segment
        if (lineWidth + wordWidth <= selfWidth) then
          currentSegment.text = currentSegment.text .. ' ' .. word
          currentSegment.w = currentSegment.w + wordWidth + spaceWidth
          lineWidth = lineWidth + wordWidth + spaceWidth
        else -- The current segment exceeds the line length, create a new one
          table.insert(formattedSegments, table.shallow_copy(currentSegment))

          -- Reset the cursor w, move cursor y down by text height, add new word
          currentSegment.x = 4
          currentSegment.y = currentSegment.y + currentSegment.h
          currentSegment.w = wordWidth
          currentSegment.text = word
          lineWidth = wordWidth
        end

        if (k == #splitText) then
          table.insert(formattedSegments, table.shallow_copy(currentSegment))
        end 
      end
    end
  end


    --[[    -- TODO: Watch for edge case of word being bigger than panel here
    local lineWidth = surface.GetTextSize(currentLine)
    local wordWidth = surface.GetTextSize(word)

    -- Locate starting tag inside word
    local tag = '<r>'

    local startPos, endPos = string.find(word, tag)
    if (startPos != nil) then
      -- Case 1 - the tag is at the start
      if (startPos == 1) then
        currentColor = Color(255, 0, 0) -- Switch out current colour
        word = string.gsub(word, tag, '') -- Remove tag from text
        
        -- Recalculate size of current word
        wordWidth = surface.GetTextSize(word)
      end
      -- Case 2 - the tag is in the middle
      -- Case 3 - the tag is at the end of the word
    end

    if (#formattedSegments == 0) then
      selfWidth = originalSelfWidth - self.Avatar:GetWide() -- Reduce original width copy
    end
    
    -- If the current line width is greater than the width of panel, save line and reset
    if ((lineWidth + wordWidth) >= selfWidth) then
      table.insert(formattedSegments, { text = string.Trim(currentLine), color = currentColor })
      currentLine = word
    else
      currentLine = currentLine .. ' ' .. word
    end

    -- If this is the last word, add the line before reaching limit
    if (k == #splitText) then
      table.insert(formattedSegments, { text = string.Trim(currentLine), color = currentColor })
    end

    -- Reset width if we're past the first line
    if (#formattedSegments == 1) then
      selfWidth = originalSelfWidth
    end
   

  end --]]

  self:SetSegments(formattedSegments)
end

/*
 * Gets the width of a given segment in px
 */
function PANEL:GetSegmentWidth(segment)
  local width = 0

  surface.SetFont(self:GetFont())

  for k, v in pairs(segment) do
    if (type(v) == 'string') then
      width = width + surface.GetTextSize(v)
    end
  end

  return width
end

function PANEL:PerformLayout(width, height)
  surface.SetFont(self:GetFont())
  self.Avatar:SetWide(surface.GetTextSize(LocalPlayer():Nick() .. ':  ') + self.Avatar.Image:GetWide())
  self.Avatar:SetHeight(self:GetFontSize())
  self.Avatar:SetPos(0, 4)

  self.Avatar.Image:SetPos(4, (self.Avatar:GetTall() - self.Avatar.Image:GetTall()) / 2)

  self.TextStart:SetHeight(self:GetFontSize())
  self.TextStart:SetWide(self:GetWide() - self.Avatar:GetWide() - 4)
  self.TextStart:SetPos(self.Avatar:GetWide() + 4, 4)
  self.TextStart.Paint = function() end

  self:GenerateLines()

  local lastSegment = self:GetSegments()[#self:GetSegments()]
  self:SetHeight(lastSegment.y + lastSegment.h)

  -- PrintTable(self:GetSegments())
end

function PANEL:Paint(width, height)
  if (self:GetMessage() != nil) then

    draw.RoundedBox(4, 0, 0, width, height, Color(31, 31, 31))
    --[[
    for k, v in pairs(self:GetLines()) do
      local widthOffset = 4
      if (k == 1) then
        widthOffset = widthOffset + self.Avatar:GetWide()
      end
      draw.SimpleText(v.text, self:GetFont(), widthOffset, 4 + ((k - 1) * self:GetFontSize()), v.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) 
    end
    --]]

    for k, v in pairs(self:GetSegments()) do
      draw.SimpleText(v.text, self:GetFont(), v.x, v.y, v.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
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