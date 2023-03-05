local PANEL = {}

AccessorFunc(PANEL, 'm_nHeaderSize', 'HeaderSize', FORCE_NUMBER)

function PANEL:Init()
  self:SetTitle('')
  self:ShowCloseButton(false)
  self:SetHeaderSize(24)
  self.BlurMat = Material("pp/blurscreen")
  self.HasScrolledToFirstMessage = false
  self.Messages = {}

  self.Content = vgui.Create('DScrollPanel', self)
  self.Content.Paint = function(this, w, h) 
    -- draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 100))
  end

  local canvasInternalLayout = self.Content.PerformLayout
	self.Content.PerformLayout = function(this)
		canvasInternalLayout(this)

    local scrollCanvasPositionYStart = self.Content.VBar:GetOffset() * -1
    local scrollCanvasPositionYEnd = scrollCanvasPositionYStart + self.Content:GetTall()

    for k, v in pairs(self.Messages) do
      local vX, vY = v:GetPos()
      local vW, vH = v:GetSize()
      local extraRenderHeight = 200

      if ((vY + vH >= scrollCanvasPositionYStart - extraRenderHeight) && (vY <= scrollCanvasPositionYEnd + extraRenderHeight)) then
        if (v.ShouldRender == false) then
          v.ShouldRender = true
          v:GenerateSegmentVguiElements()
          v:PerformLayout()
        end
      else
        if (v.ShouldRender == true) then
          v.ShouldRender = false
          v:RemoveSegmentVguiElements()
          v:PerformLayout()
        end
      end
    end

	end

  local scr = self.Content:GetVBar()
  scr.PerformLayout = function()
    local scrollWidth = scr:GetWide()
    local scroll = scr:GetScroll() / scr.CanvasSize
    local barSize = math.max(scr:BarScale() * scr:GetTall(), 10)
    local track = scr:GetTall() - barSize

    scroll = scroll * track

    scr.btnGrip:SetPos(0, scroll)
    scr.btnGrip:SetSize(scrollWidth, barSize)

    scr.btnUp:SetPos(0, 0, scrollWidth, scrollWidth)
    scr.btnUp:SetSize(scrollWidth, 0)

    scr.btnDown:SetPos(0, scr:GetTall(), scrollWidth, scrollWidth)
    scr.btnDown:SetSize(scrollWidth, 0)
  end
  scr.Paint = function() end
  scr.btnUp.Paint = function() end
  scr.btnDown.Paint = function() end
  scr.btnGrip.Paint = function(_, w, h) draw.RoundedBox(4, 2, 0, w - 4, h, Color(0, 0, 0, 100)) end

  self.CloseButton = vgui.Create('DButton', self)
  self.CloseButton:SetSize(32, 20)
  self.CloseButton:SetText('')
  self.CloseButton.Paint = function(this, w, h)
    -- draw.RoundedBox(4, 0, 0, w, h, Color(33, 33, 33))
    draw.SimpleText('x', 'chatbox24', w/2, h/2 - 2, Color(240, 240, 240), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) 
  end
  self.CloseButton.DoClick = function()
    self:Close()
  end

  self:MakePopup();
  self:SetSize(ScrW()*0.26, ScrH()*0.33)
  self:SetPos(10, ScrH()/2)
  self:SetSizable(true)
end

function PANEL:PerformLayout(width, height)
  self.BaseClass.PerformLayout(self, width, height)

  self.CloseButton:SetPos(width - 36, 4)

  self.Content:SetPos(4, self:GetHeaderSize() + (4 * 2))
  self.Content:SetSize(width - 8, height - (self:GetHeaderSize() + 4 *3))
end

function PANEL:AddMessage(content)
  local message = vgui.Create('chatMessage', self.Content)
  message:AddContent(content)
  message:InvalidateLayout(true)

  table.insert(self.Messages, message)
  
  -- Only scroll to the new message if the scrollbar is enabled and we're not viewing the most recent message
  if (self.Content:GetCanvas():GetTall() >= self.Content:GetTall()) then
    local bar = self.Content:GetVBar()
    local barPosX, barPosY = bar.btnGrip:GetPos()
    local y = self.Content.pnlCanvas:GetTall()
    local w, h = message:GetSize()
      
    y = y + h * 0.5
    y = y - self.Content:GetTall() * 0.5


    -- if (!self.HasScrolledToFirstMessage || (bar.btnGrip:GetTall() + barPosY == self.Content:GetTall() - 1)) then
    if (!self.HasScrolledToFirstMessage || (self.Content.VBar:GetScroll() / self.Content.VBar.CanvasSize) != 1) then
      timer.Simple(0.1, function() self.Content.VBar:AnimateTo(y, 1, 0, -1) end)

      self.HasScrolledToFirstMessage = true -- Account for scrolling to the message when the scrollbar is first enabled
    end
  end
end

function PANEL:Paint(width, height)
  local x, y = self:LocalToScreen(0, 0);

  surface.SetDrawColor(255, 255, 255, 100);
  surface.SetMaterial(self.BlurMat);

  for i = 1, 3 do
    self.BlurMat:SetFloat("$blur", i * 2);
    self.BlurMat:Recompute();
    render.UpdateScreenEffectTexture();
    surface.DrawTexturedRect(-x, -y, ScrW(), ScrH());
  end

  draw.RoundedBox(4, 0, 0, width, height, Color(0, 0, 0, 230))

  draw.RoundedBoxEx(4, 0, 0, width, self:GetHeaderSize() + 4, Color(35, 130, 186), true, true)
  -- draw.RoundedBoxEx(4, 0, self:GetHeaderSize() + 4, width, height - self:GetHeaderSize(), Color(33, 33, 33), false, false, true, true)
  draw.SimpleText(GetHostName(), 'chatbox24', 8, 2, Color(240, 240, 240), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) 
end

vgui.Register('chatBase', PANEL, 'DFrame')