local PANEL = {}

AccessorFunc(PANEL, 'm_nHeaderSize', 'HeaderSize', FORCE_NUMBER)

function PANEL:Init()
  self:SetTitle('')
  self:ShowCloseButton(false)
  self:SetHeaderSize(24)
  self.BlurMat = Material("pp/blurscreen")

  self.Content = vgui.Create('DScrollPanel', self)
  self.Content.Paint = function(this, w, h) 
    -- draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 100))
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
  scr.btnGrip.Paint = function() draw.RoundedBox(4, 2, 0, scr.btnGrip:GetWide() - 4, scr.btnGrip:GetTall() - 2, Color(0, 0, 0, 100)) end

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
  
  local y = self.Content.pnlCanvas:GetTall()
  local w, h = message:GetSize()
    
  y = y + h * 0.5;
  y = y - self.Content:GetTall() * 0.5;

  self.Content.VBar:AnimateTo(y, 0.5, 0, 0.5);
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