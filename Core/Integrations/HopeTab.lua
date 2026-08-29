local _, ns = ...
local L = ns.L

local HOPE_TAB_NUM = 103

local function EnsureHopeMainFrame()
    if not BG.MainFrame then
        return nil
    end
    if BG.HopeMainFrame then
        BG.HopeMainFrame:SetParent(BG.MainFrame)
        BG.HopeMainFrame:ClearAllPoints()
        BG.HopeMainFrame:SetPoint("TOPLEFT", BG.MainFrame, "TOPLEFT", 1, -48)
        BG.HopeMainFrame:SetPoint("BOTTOMRIGHT", BG.MainFrame, "BOTTOMRIGHT", -1, 42)
        BG.HopeMainFrame:SetFrameLevel(BG.MainFrame:GetFrameLevel() + 50)
        BG.HopeMainFrame:SetAlpha(1)
        BG.HopeMainFrame:EnableMouse(false)
        return BG.HopeMainFrame
    end

    local f = CreateFrame("Frame", "BGP.HopeMainFrame", BG.MainFrame)
    f:SetPoint("TOPLEFT", BG.MainFrame, "TOPLEFT", 1, -48)
    f:SetPoint("BOTTOMRIGHT", BG.MainFrame, "BOTTOMRIGHT", -1, 42)
    f:SetFrameLevel(BG.MainFrame:GetFrameLevel() + 50)
    f:EnableMouse(false)
    f:Hide()

    BG.HopeMainFrame = f
    BG.HopeMainFrameTabNum = HOPE_TAB_NUM
    return f
end

local function BindHopeTabFrame(hopeFrame)
    if not hopeFrame or not BG.tabButtons then
        return
    end
    for _, v in ipairs(BG.tabButtons) do
        if v.num == HOPE_TAB_NUM then
            v.frame = hopeFrame
            return true
        end
    end
    return false
end

local function HideRivalFrames()
    if BG.FBMainFrame then
        BG.FBMainFrame:Hide()
    end
    if BG.DuiZhangMainFrame then
        BG.DuiZhangMainFrame:Hide()
    end
    if BG.MailHistoryMainFrame then
        BG.MailHistoryMainFrame:Hide()
    end
    if BG.TradeHistoryMainFrame then
        BG.TradeHistoryMainFrame:Hide()
    end
    if BG.TabButtonsFB then
        BG.TabButtonsFB:Hide()
    end
    if BG.TabButtonsFB_TBC then
        BG.TabButtonsFB_TBC:Hide()
    end
    if BG.NanDuDropDown and BG.NanDuDropDown.DropDown then
        BG.NanDuDropDown.DropDown:Hide()
    end
    if BG.auctionLogFrame then
        BG.auctionLogFrame:Hide()
    end
end

local function EnsureHopeContentVisible()
    local hopeFrame = EnsureHopeMainFrame()
    if not hopeFrame then
        return
    end
    HideRivalFrames()
    hopeFrame:Show()

    local FB = BG.FB1 or BiaoGe.FB or (BG.FBtable and BG.FBtable[1])
    if not FB then
        return
    end

    for _, fb in ipairs(BG.FBtable or {}) do
        local hf = BG["HopeFrame" .. fb]
        if hf then
            if hf:GetParent() ~= hopeFrame then
                hf:SetParent(hopeFrame)
                hf:ClearAllPoints()
                hf:SetPoint("TOPLEFT", hopeFrame, "TOPLEFT", 0, 0)
            end
            hf:SetFrameLevel(hopeFrame:GetFrameLevel() + 2)
            hf:SetShown(fb == FB)
        end
    end

    local hf = BG["HopeFrame" .. FB]
    if hf then
        hf:Show()
        if BG.HopeFrame and BG.HopeFrame[FB] and ns.HopeMaxn and ns.HopeMaxn[FB] then
            local base = hf:GetFrameLevel() + 5
            for n = 1, ns.HopeMaxn[FB] do
                for b = 1, (ns.HopeMaxb and ns.HopeMaxb[FB] or 0) do
                    for i = 1, (ns.HopeMaxi or 7) do
                        local bt = BG.HopeFrame[FB]["nandu" .. n]
                            and BG.HopeFrame[FB]["nandu" .. n]["boss" .. b]
                            and BG.HopeFrame[FB]["nandu" .. n]["boss" .. b]["zhuangbei" .. i]
                        if bt and bt.Show then
                            bt:SetFrameLevel(base)
                            bt:Show()
                        end
                    end
                end
            end
        end
    end

    if BG.BGP_WishlistTabButtonsFB then
        BG.BGP_WishlistTabButtonsFB:SetParent(hopeFrame)
        BG.BGP_WishlistTabButtonsFB:SetFrameLevel(hopeFrame:GetFrameLevel() + 10)
        BG.BGP_WishlistTabButtonsFB:Show()
    end
    if BG.ButtonHopeQingKong then
        BG.ButtonHopeQingKong:SetParent(hopeFrame)
        BG.ButtonHopeQingKong:SetFrameLevel(hopeFrame:GetFrameLevel() + 10)
        BG.ButtonHopeQingKong:Show()
    end
end

-- 完全接管心愿 Tab 点击：先绑对帧，再 ClickTabButton，再强制显示内容
local function OnHopeTabClick()
    local hopeFrame = EnsureHopeMainFrame()
    if not hopeFrame then
        return
    end
    BindHopeTabFrame(hopeFrame)
    HideRivalFrames()

    if BG.ClickTabButton then
        BG.ClickTabButton(HOPE_TAB_NUM)
    end

    hopeFrame:Show()
    if ns.BridgeBGLiteData then
        ns.BridgeBGLiteData()
    end
    if BG.FrameHide then
        BG.FrameHide(0)
    end
    if BG.BGP_BuildHopeUI then
        BG.BGP_BuildHopeUI()
    end
    EnsureHopeContentVisible()
    if BG.BGP_LayoutHopeExportImport then
        BG.BGP_LayoutHopeExportImport(true)
    end
    if BG.UpdateHopeFrame_IsLooted_All then
        BG.UpdateHopeFrame_IsLooted_All()
    end
    if BG.PlaySound then
        BG.PlaySound(1)
    end
end

local function AttachHopeTabScripts(hopeFrame)
    hopeFrame:SetScript("OnShow", function()
        BiaoGe.lastFrame = "Hope"
        if ns.BridgeBGLiteData then
            ns.BridgeBGLiteData()
        end
        if BG.FrameHide then
            BG.FrameHide(0)
        end
        HideRivalFrames()
        if BG.BGP_BuildHopeUI then
            BG.BGP_BuildHopeUI()
        end
        EnsureHopeContentVisible()
        if BG.BGP_LayoutHopeExportImport then
            BG.BGP_LayoutHopeExportImport(true)
        end
        if BG.UpdateHopeFrame_IsLooted_All then
            BG.UpdateHopeFrame_IsLooted_All()
        end
    end)

    hopeFrame:SetScript("OnHide", function()
        if BG.BGP_WishlistTabButtonsFB then
            BG.BGP_WishlistTabButtonsFB:Hide()
        end
        if BG.BGP_LayoutHopeExportImport then
            BG.BGP_LayoutHopeExportImport(false)
        end
    end)
end

local function WireHopeTabButton(bt)
    if not bt then
        return
    end
    -- SetScript 覆盖原 OnClick，避免 Hook 太晚、ClickTabButton 仍绑错帧
    bt:SetScript("OnClick", OnHopeTabClick)
    bt.bgpHopeClickWired = true
end

local function InstallHopeTab()
    if not BG.MainFrame or not BG.Create_TabButton or not BG.tabButtons then
        return false
    end

    local hopeFrame = EnsureHopeMainFrame()
    if not hopeFrame then
        return false
    end

    BindHopeTabFrame(hopeFrame)
    AttachHopeTabScripts(hopeFrame)

    for _, v in ipairs(BG.tabButtons) do
        if v.num == HOPE_TAB_NUM then
            local tabText = L["心愿清单"]
            local fs = v.button:GetFontString()
            if fs then
                fs:SetText(tabText)
            end
            v.button:SetWidth((fs and fs:GetStringWidth() or 80) + 20)
            v.frame = hopeFrame
            WireHopeTabButton(v.button)
            BG.BGP_HopeTabInstalled = true
            return true
        end
    end

    BG.Create_TabButton(HOPE_TAB_NUM, L["心愿清单"], hopeFrame, 105)
    BindHopeTabFrame(hopeFrame)
    AttachHopeTabScripts(hopeFrame)
    for _, v in ipairs(BG.tabButtons) do
        if v.num == HOPE_TAB_NUM then
            WireHopeTabButton(v.button)
            break
        end
    end
    BG.BGP_HopeTabInstalled = true
    return true
end

function BG.BGP_OpenHopeTab()
    if not InstallHopeTab() then
        print("|cff00BFFF<BGLite Plus>|r BGLite 主界面未就绪，请 /reload 后重试。")
        return
    end
    if BG.MainFrame and not BG.MainFrame:IsVisible() then
        BG.MainFrame:Show()
    end
    OnHopeTabClick()
end

BG.OpenWishlist = BG.BGP_OpenHopeTab
BG.BGP_EnsureHopeContentVisible = EnsureHopeContentVisible

local function EnsureHopeTabOnMainFrame()
    InstallHopeTab()
end

C_Timer.After(0, EnsureHopeTabOnMainFrame)
ns.RunWhenReady(EnsureHopeTabOnMainFrame)

if BG.MainFrame and not BG.BGP_MainFrameHooked then
    BG.BGP_MainFrameHooked = true
    BG.MainFrame:HookScript("OnShow", EnsureHopeTabOnMainFrame)
end

ns.RunWhenReady(function()
    if BG.MainFrame and not BG.BGP_MainFrameHooked then
        BG.BGP_MainFrameHooked = true
        BG.MainFrame:HookScript("OnShow", EnsureHopeTabOnMainFrame)
        EnsureHopeTabOnMainFrame()
    end
end)
