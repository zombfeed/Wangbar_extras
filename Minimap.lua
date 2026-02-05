local _, WB = ...
WB = WB or {}

local minimapIcon
local minimapButton
local minimapInitialized = false

function WB:InitMinimapButton()
  if minimapInitialized then return end
  if not LibStub then return end
  local LDB = LibStub("LibDataBroker-1.1", true)
  local DBIcon = LibStub("LibDBIcon-1.0", true)
  if not LDB or not DBIcon then
    local function CreateFallbackMinimapButton()
      if minimapButton then return end
      minimapButton = CreateFrame("Button", "WangbarMinimapButton", Minimap)
      minimapButton:SetSize(32, 32)
      minimapButton:SetFrameStrata("MEDIUM")
      minimapButton:SetFrameLevel(8)

      minimapButton:SetNormalTexture("Interface\\Icons\\Ability_Rogue_SliceDice")
      minimapButton:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
      minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
      minimapButton:GetHighlightTexture():SetBlendMode("ADD")

      local normal = minimapButton:GetNormalTexture()
      normal:SetTexCoord(0.07, 0.93, 0.07, 0.93)

      minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
      minimapButton:RegisterForDrag("LeftButton")

      local function UpdatePosition()
        local angle = SnapComboPointsDB.minimap.angle or 225
        local radius = 80
        local rad = math.rad(angle)
        local x = 52 - radius * math.cos(rad)
        local y = radius * math.sin(rad) - 52
        minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", x, y)
      end

      minimapButton:SetScript("OnDragStart", function()
        minimapButton:SetScript("OnUpdate", function()
          local mx, my = Minimap:GetCenter()
          local cx, cy = GetCursorPosition()
          local scale = Minimap:GetEffectiveScale()
          cx, cy = cx / scale, cy / scale
          local dx, dy = cx - mx, cy - my
          local angle = math.deg(math.atan2(dy, dx))
          SnapComboPointsDB.minimap.angle = angle
          UpdatePosition()
        end)
      end)

      minimapButton:SetScript("OnDragStop", function()
        minimapButton:SetScript("OnUpdate", nil)
      end)

      minimapButton:SetScript("OnClick", function(_, button)
        if button == "RightButton" then
          WB:ToggleDebugPanel()
        else
          WB:OpenOptionsPanel()
        end
      end)

      minimapButton:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine(ADDON_TITLE)
        GameTooltip:AddLine("Left-click: Options", 1, 1, 1)
        GameTooltip:AddLine("Right-click: Edit panel", 1, 1, 1)
        GameTooltip:Show()
      end)

      minimapButton:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)

      if SnapComboPointsDB.minimap.hide then
        minimapButton:Hide()
      else
        minimapButton:Show()
        UpdatePosition()
      end
      minimapInitialized = true
    end

    CreateFallbackMinimapButton()
    return
  end

  if not minimapIcon then
    minimapIcon = LDB:NewDataObject("Wangbar", {
      type = "launcher",
      text = ADDON_TITLE,
      icon = "Interface\\Icons\\Ability_Rogue_SliceDice",
      OnClick = function(_, button)
        if button == "RightButton" then
          WB:ToggleDebugPanel()
        else
          WB:OpenOptionsPanel()
        end
      end,
      OnTooltipShow = function(tooltip)
        tooltip:AddLine(ADDON_TITLE)
        tooltip:AddLine("Left-click: Options", 1, 1, 1)
        tooltip:AddLine("Right-click: Edit panel", 1, 1, 1)
      end,
    })
  end

  DBIcon:Register("Wangbar", minimapIcon, SnapComboPointsDB.minimap)
  minimapInitialized = true
end