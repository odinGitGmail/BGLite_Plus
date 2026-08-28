local _, ns = ...
local L = ns.L

local function HideRoleOverviewHover()
    if BG.FBCDFrame and not BG.FBCDFrame.click then
        BG.FBCDFrame:Hide()
    end
end

local function ShowRoleOverviewHover(button)
    if not BG.SetFBCD then
        return
    end
    BG.SetFBCD(button, "minimap")
end

local function HookLDBMinimap()
    local ldb = LibStub("LibDataBroker-1.1", true)
    if not ldb then
        return false
    end

    local obj = ldb:GetDataObjectByName("BGLite")
    if not obj or obj.bgpHoverHooked then
        return obj ~= nil
    end
    obj.bgpHoverHooked = true

    local oldEnter = obj.OnEnter
    function obj:OnEnter(button)
        ShowRoleOverviewHover(button or self)
        if oldEnter then
            oldEnter(self, button)
        end
    end

    local oldLeave = obj.OnLeave
    function obj:OnLeave(button)
        HideRoleOverviewHover()
        if oldLeave then
            oldLeave(self, button)
        end
    end

    return true
end

local function HookLibDBIconButton()
    local iconLib = LibStub("LibDBIcon-1.0", true)
    if not iconLib or not iconLib.GetMinimapButton then
        return false
    end

    local btn = iconLib:GetMinimapButton("BGLite") or _G["LibDBIcon10_BGLite"]
    if not btn or btn.bgpHoverHooked then
        return btn ~= nil
    end
    btn.bgpHoverHooked = true

    local oldEnter = btn:GetScript("OnEnter")
    local oldLeave = btn:GetScript("OnLeave")

    btn:SetScript("OnEnter", function(self, ...)
        ShowRoleOverviewHover(self)
        if oldEnter then
            oldEnter(self, ...)
        end
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["角色总览"], 1, 1, 1)
        GameTooltip:AddLine(L["鼠标移入显示角色总览"], 0.8, 0.8, 0.8)
        GameTooltip:AddLine(L["Ctrl+左键：固定打开角色总览"], 0.8, 0.8, 0.8)
        GameTooltip:AddLine(L["左键：打开/关闭表格"], 0.8, 0.8, 0.8)
        GameTooltip:AddLine(L["右键：打开设置"], 0.8, 0.8, 0.8)
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function(self, ...)
        HideRoleOverviewHover()
        GameTooltip:Hide()
        if oldLeave then
            oldLeave(self, ...)
        end
    end)

    return true
end

local function InstallMinimapHover()
    HookLDBMinimap()
    HookLibDBIconButton()
end

-- BGLite 的 LDB 对象在 Plus 加载前已创建，可立即挂钩
InstallMinimapHover()

ns.RunWhenReady(function()
    InstallMinimapHover()
end)

-- LibDBIcon 按钮可能稍晚创建（PLAYER_LOGIN / 收藏栏插件）
C_Timer.After(0.5, InstallMinimapHover)
C_Timer.After(2, InstallMinimapHover)
