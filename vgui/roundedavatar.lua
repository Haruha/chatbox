local PANEL = {}
local render = render

function PANEL:Init()
  self.Color = Color(255, 255, 255)
  self.Poly = {}
end

function PANEL:PerformLayout()
  self.Poly = {}

  for i = 0, 3 do
    local _x = (i < 2 && self:GetWide() - 4 || 4)
    local _y = (i % 3 > 0 && self:GetTall() - 4 || 4)
    local a = 90 * i
    
    for j = 0, 15 do
      local _a = math.rad(a + j * 6)

      self.Poly[i * 16 + j] = {
        x = _x + 4 * math.sin(_a),
        y = _y - 4 * math.cos(_a)
      }
    end
  end
end

function PANEL:Paint()
  render.ClearStencil()

  render.SetStencilWriteMask(0xFF)
  render.SetStencilTestMask(0xFF)
  render.SetStencilPassOperation(STENCIL_KEEP)
  render.SetStencilZFailOperation(STENCIL_KEEP)
  render.SetStencilEnable(true)
  render.SetStencilReferenceValue(1)
  render.SetStencilCompareFunction(STENCIL_NEVER)
  render.SetStencilFailOperation(STENCIL_REPLACE)
  
  draw.NoTexture()
  surface.SetDrawColor(self.Color)
  surface.DrawPoly(self.Poly)

  render.SetStencilCompareFunction(STENCIL_EQUAL)
  render.SetStencilFailOperation(STENCIL_KEEP)
end

function PANEL:PaintOver()
  render.SetStencilEnable(false)
end

PANEL.AllowAutoRefresh = true

vgui.Register('RoundedAvatarImage', PANEL, 'AvatarImage')