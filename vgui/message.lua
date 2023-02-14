local PANEL = {}

AccessorFunc(PANEL, 'm_sMessage', 'Message', FORCE_STRING)
AccessorFunc(PANEL, 'm_sFont', 'Font', FORCE_STRING)
AccessorFunc(PANEL, 'm_nFontSize', 'FontSize', FORCE_NUMBER)
AccessorFunc(PANEL, 'm_Lines', 'Lines')

function PANEL:Init() 
  
  self:Dock(TOP)
  self:DockMargin(0, 0, 0, 0)
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
  
  local message = self:GetMessage()

  -- Get sizes of panel, text
  local selfWidth = self:GetWide() - (4 * 2)
  originalSelfWidth = selfWidth  -- Padding

  local textWidth = surface.GetTextSize(message)

  -- If the text size is less than the panel size, return early without wrapping
  if (textWidth <= selfWidth - self.Avatar:GetWide()) then
    self:SetLines({ message })
    return
  end

  -- Hold all length-aware lines
  local formattedLines = {}

  -- Split the message by spaces
  local splitText = string.Split(message, ' ')
  local currentLine = ''

  for k, word in pairs(splitText) do
    -- TODO: Watch for edge case of word being bigger than panel here
    local lineWidth = surface.GetTextSize(currentLine)
    local wordWidth = surface.GetTextSize(word)

    if (#formattedLines == 0) then
      selfWidth = originalSelfWidth - self.Avatar:GetWide() -- Reduce original width copy
    end
    
    -- If the current line width is greater than the width of panel, save line and reset
    if ((lineWidth + wordWidth) >= selfWidth) then
      table.insert(formattedLines, string.Trim(currentLine))
      currentLine = word
    else
      currentLine = currentLine .. ' ' .. word
    end

    -- If this is the last word, add the line before reaching limit
    if (k == #splitText) then
      table.insert(formattedLines, string.Trim(currentLine))
    end

    -- Reset width if we're past the first line
    if (#formattedLines == 1) then
      selfWidth = originalSelfWidth
    end

  end

  self:SetLines(formattedLines)
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
  self:SetHeight((#self:GetLines() * self:GetFontSize()) + 8)
end

function PANEL:Paint(width, height)
  if self:GetMessage() != nil then
    -- draw.RoundedBox(4, 0, 0, width, height, Color(0, 0, 0))

    for k, v in pairs(self:GetLines()) do
      local widthOffset = 4
      if (k == 1) then
        widthOffset = widthOffset + self.Avatar:GetWide()
      end
      draw.SimpleText(v, self:GetFont(), widthOffset, 4 + ((k - 1) * self:GetFontSize()), Color(240, 240, 240), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) 
    end
  end
end

function PANEL:OnMouseReleased(control)
	if control == MOUSE_RIGHT then

		local menu = DermaMenu()

		menu:AddOption('Copy', function() 
      if IsValid(self) then
        SetClipboardText(self:GetMessage())
      end
    end)

		menu:Open()
	end
end

vgui.Register('chatMessage', PANEL, 'DPanel')