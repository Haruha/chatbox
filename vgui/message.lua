local PANEL = {}
local draw, surface, string, table = draw, surface, string, table

local emojis = {
  {
    name = ':smile:',
    source = 'vgui/test.png',
    size = { 16, 16 }
  },
  {
    name = ':b1:',
    source = 'https://steamcommunity-a.akamaihd.net/economy/emoticon/:B1:',
    size = { 16, 16 }
  },
  {
    name = ':cute:',
    source = 'https://cdn3.emoji.gg/emojis/4285-owo.gif',
    size = { 16, 16 }
  },
  {
    name = ':stonks:',
    source = 'https://cdn3.emoji.gg/emojis/2946-surprise-shake.gif',
    size = { 16, 16 }
  }
}

AccessorFunc(PANEL, 'm_sFont', 'Font', FORCE_STRING)
AccessorFunc(PANEL, 'm_nFontSize', 'FontSize', FORCE_NUMBER)
AccessorFunc(PANEL, 'm_nMessagePadding', 'MessagePadding', FORCE_NUMBER)
AccessorFunc(PANEL, 'm_Player', 'Player')
AccessorFunc(PANEL, 'm_Message', 'Message')
AccessorFunc(PANEL, 'm_Segments', 'Segments')

function PANEL:Init()
  self:Dock(TOP)
  self:DockMargin(4, 2, 4, 2)
  self:SetFont('chatbox20')
  self:SetFontSize(draw.GetFontHeight(self:GetFont()))
  self:SetMessagePadding(2)
  self.ShouldRender = true

  self.Avatar = vgui.Create('DPanel', self)
  self.Avatar:SetTall(30)
  self.Avatar.Paint = function(_, w, h)
    -- draw.RoundedBox(4, 0, 0, w, h, Color(131, 31, 31))
    surface.SetFont(self:GetFont())
    local spaceWidth = surface.GetTextSize(' ')

    local avatarOffset = self.Avatar.Image:GetWide() + 4 + self:GetMessagePadding()
    local colonOffset = surface.GetTextSize(LocalPlayer():Nick()) - 1
    draw.SimpleText(LocalPlayer():Nick(), self:GetFont(), avatarOffset, h / 2, Color(248, 206, 79), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(':', self:GetFont(), avatarOffset + colonOffset, h / 2, Color(240, 240, 240), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) 
  end

  self.Avatar.Image = vgui.Create('RoundedAvatarImage', self.Avatar)
	self.Avatar.Image:SetSize(24, 24)
	self.Avatar.Image:SetPlayer(LocalPlayer(), 24)

  self.Links = {}
  self.WebImages = {}
  self.iMaterials = {}
end

function PANEL:AddContent(content)
  self:SetMessage(content)
  self:GenerateSegmentVguiElements()
  self:GenerateSegments()
end

function PANEL:GenerateSegmentVguiElements()
  local linkPosition = 1
  local webImagePosition = 1
  for k, messagePart in pairs(self:GetMessage()) do
    if (type(messagePart) == 'string') then
      for i, word in pairs(string.Split(messagePart, ' ')) do

        -- Attempt to find a match with a link
        if (self:IsValidURL(word)) then
          local label = vgui.Create('DLabel', self)
          label:SetFont(self:GetFont())
          label:SetColor(Color(48, 167, 250))
          label:SetMouseInputEnabled(true)
          label:SetText(word)
          label.DoClick = function(self)
            gui.OpenURL(self:GetText())
          end

          table.insert(self.Links, linkPosition, label)
        
          linkPosition = linkPosition + 1
        end

        -- Loop through emojis and try to find a match
        for _, emoji in pairs(emojis) do
          if (word == emoji.name) then
            if (self:IsValidURL(emoji.source)) then
              local html = vgui.Create('DHTML', self)
              html.OnDocumentReady = function(self, page)
                self:RunJavascript([[
                  window.addEventListener('DOMContentLoaded', (event) => {
                    document.body.style.overflow = 'hidden';
                  });
                ]])
              end

              table.insert(self.WebImages, webImagePosition, html)
  
              webImagePosition = webImagePosition + 1
            else 
              self.iMaterials[emoji.source] = Material(emoji.source, "noclamp mips")
            end
          end
        end
      end
    end
  end
end

function PANEL:RemoveSegmentVguiElements()
  for k,v in pairs(self.Links) do
    v:Remove()
  end
  
  self.Links = {}


  for k, v in pairs(self.WebImages) do
    v:Remove()
  end

  self.WebImages = {}
end

function PANEL:IsValidURL(url)
  -- TODO: Pattern matching
  return string.StartWith(url, 'http://') || string.StartWith(url, 'https://')
end

function PANEL:PerformSegmentLayout()
  local linkCount = 1
  local webImageCount = 1

  for k, segment in pairs(self:GetSegments()) do
    -- Update size, position and text of link
    if (segment.url && self.Links[linkCount]) then
      local label = self.Links[linkCount]
      label:SetPos(segment.x, segment.y - (segment.h / 2) - (self:GetMessagePadding() / 2))
      label:SetSize(segment.w, segment.h + self:GetMessagePadding() + 1)

      linkCount = linkCount + 1
    end

    if (segment.isWebEmoji && self.WebImages[webImageCount]) then
      local dhtml = self.WebImages[webImageCount]
      dhtml:SetPos(segment.x, segment.y - (segment.h / 2))
      dhtml:SetSize(segment.w, segment.h)
      dhtml:SetHTML([[
        <img src="]] .. segment.material .. [[" style="position:absolute;right:0;top:0;width:16px;height:16px;"></img>
      ]])

      webImageCount = webImageCount + 1
    end
  end
end


function PANEL:GenerateSegments()
  surface.SetFont(self:GetFont())

  -- Get width of panel
  local selfWidth = self:GetWide() - (self:GetMessagePadding() * 2)
  originalSelfWidth = selfWidth  -- Padding

  -- Hold all segments
  local formattedSegments = {}

  -- Current segment has a width, height, color, text
  -- Could potentially also hold a material (for local Emojis) or a URL (for links or web Emojis)
  local currentSegment = {
    x = self.Avatar:GetWide(), 
    y = self:GetMessagePadding() + (self.Avatar:GetTall() / 2),
    w = 0,
    h = self.Avatar.Image:GetTall() - 2,
    color = Color(255, 255, 255),
    text = ''
  }

  local lineWidth = currentSegment.x
  local lineCount = 1
  local spaceWidth = surface.GetTextSize(' ')

  -- Begin looping through the message
  for k, messagePart in pairs(self:GetMessage()) do
    if (type(messagePart) == 'table') then
      currentSegment.color = messagePart
      currentSegment.text = ''
      currentSegment.x = currentSegment.x + currentSegment.w
      currentSegment.w = 0
    end

    if (type(messagePart) == 'string') then
      -- Split the message by spaces
      local splitText = string.Split(messagePart, ' ')

      -- Loop the words
      for k, word in pairs(splitText) do
        local wordWidth = surface.GetTextSize(word)

        -- Handle emoji width replacement for text width

        local emoji = false
        for key, value in pairs(emojis) do
          if (word == value.name) then
            emoji = value
          end
        end

        if (emoji) then
          wordWidth = emoji.size[1]
        end

        -- If the word fits in the line, append the text to the segment
        if (lineWidth + wordWidth >= selfWidth - spaceWidth) then
        -- The current segment exceeds the line length, save existing segment and create a new one
          table.insert(formattedSegments, table.shallow_copy(currentSegment))
  
          -- Reset the cursor w, move cursor y down by text height
          currentSegment.x = self:GetMessagePadding() - 4
          currentSegment.y = currentSegment.y + currentSegment.h
          currentSegment.w = 0
          currentSegment.h = self:GetFontSize()
          currentSegment.text = ''

          lineWidth = 0
          lineCount = lineCount + 1
        end

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
        elseif (emoji != false) then
          -- Insert all regular text up until this point
          table.insert(formattedSegments, table.shallow_copy(currentSegment))

          -- Prepare current segment as an emoji and save
          if (string.StartWith(emoji.source, 'http://') || string.StartWith(emoji.source, 'https://')) then
            currentSegment.isWebEmoji = true
          else 
            currentSegment.isLocalEmoji = true
          end

          currentSegment.material = emoji.source
          currentSegment.x = currentSegment.x + currentSegment.w + spaceWidth
          currentSegment.w = wordWidth + 2
          currentSegment.text = ''
          -- TODO: currentSegment.h bumping for > fontSize
          table.insert(formattedSegments, table.shallow_copy(currentSegment))

          -- Reset next segment back to regular text
          currentSegment.material = nil
          currentSegment.isWebEmoji = nil
          currentSegment.isLocalEmoji = nil
          currentSegment.text = ''
          currentSegment.x = currentSegment.x + wordWidth + spaceWidth
          currentSegment.w = 0
        else 
          currentSegment.text = currentSegment.text .. ' ' .. word
          currentSegment.w = currentSegment.w + wordWidth + spaceWidth
        end
        
        lineWidth = lineWidth + wordWidth + spaceWidth

        if (k == #splitText) then
          if (string.EndsWith(currentSegment.text, ' ')) then
            currentSegment.w = currentSegment.w
          end

          table.insert(formattedSegments, table.shallow_copy(currentSegment))
        end
      end
    end
  end

  self:SetSegments(formattedSegments)
end

function PANEL:PerformLayout(width, height)
  surface.SetFont(self:GetFont())

  self.Avatar:SetWide(surface.GetTextSize(LocalPlayer():Nick() .. ':  ') + self.Avatar.Image:GetWide())
  self.Avatar:SetHeight(math.max(self:GetFontSize() + (self:GetMessagePadding() * 2), self.Avatar.Image:GetTall()))
  self.Avatar:SetPos(0, self:GetMessagePadding())
  self.Avatar.Image:SetPos(self:GetMessagePadding(), (self.Avatar:GetTall() - self.Avatar.Image:GetTall()) / 2)

  self:GenerateSegments()
  self:PerformSegmentLayout()

  local lastSegment = self:GetSegments()[#self:GetSegments()]
  local height = math.max(
    lastSegment.y + self:GetFontSize() - (self:GetMessagePadding() * 2) - 6, 
    (self.Avatar:GetTall() + self:GetMessagePadding())
  )

  self:SetHeight(height)

  for k, v in pairs(self.WebImages) do
    v:SetVisible(self.ShouldRender)
    print(v:IsVisible())
  end

  self.Avatar:SetVisible(self.ShouldRender)

  -- self:SetVisible(self.ShouldRender)
end

function PANEL:Paint(width, height)
  if (self:GetMessage() != nil && self.ShouldRender) then
    -- Background
    -- draw.RoundedBox(4, 0, 0, width, height, Color(31, 31, 31))

    -- Individual segments
    for k, v in pairs(self:GetSegments()) do
      if (v.isLocalEmoji) then
        -- surface.SetMaterial(self.iMaterials[v.material])
        -- surface.SetDrawColor(255, 255, 255, 255)
        -- surface.DrawTexturedRect(v.x, v.y - (v.h / 2), 16, 16)
      elseif (v.url) then

      else
        draw.SimpleText(v.text, self:GetFont(), v.x, v.y, v.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
      end
    end
  end
end

function PANEL:GetMessageText()
  local message = ''

  for k, v in pairs(self:GetMessage()) do
    if (type(v) == 'string') then
      message = message .. v
    end
  end

  return message
end

function PANEL:OnMouseReleased(input)
	if (input == MOUSE_RIGHT) then

		local menu = DermaMenu()

		menu:AddOption('Copy', function() 
      if (ValidPanel(self)) then
        SetClipboardText(self:GetMessageText())
      end
    end)

		menu:Open()
	end
end

vgui.Register('chatMessage', PANEL, 'DPanel')