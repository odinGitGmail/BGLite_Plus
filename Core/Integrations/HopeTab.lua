local _, ns = ...
local L = ns.L

local HOPE_TAB_NUM = 103

local function EnsureHopeMainFrame()
    if BG.HopeMainFrame then
        BG.HopeMainFrame:ClearAllPoints()
        BG.HopeMainFrame:SetPoint("TOPLEFT", BG.MainFrame, "TOPLEFT", 1, -48)
        BG.HopeMainFrame:SetPoint("BOTTOMRIGHT", BG.MainFrame, "BOTTOMRIGHT", -1, 42)
        BG.HopeMainFrame:SetFrameLevel(BG.MainFrame:GetFrameLevel() + 2)
        BG.HopeMainFrame:EnableMouse(false)
        return BG.HopeMainFrame
    end
    if not BG.MainFrame then
        return nil
    end

    local f = CreateFrame("Frame", "BGP.HopeMainFrame", BG.MainFrame)
    -- 与 BGLite 表格内容区对齐，避免整窗遮罩吞掉格子
    f:SetPoint("TOPLEFT", BG.MainFrame, "TOPLEFT", 1, -48)
    f:SetPoint("BOTTOMRIGHT", BG.MainFrame, "BOTTOMRIGHT", -1, 42)
    f:SetFrameLevel(BG.MainFrame:GetFrameLevel() + 2)
    f:EnableMouse(false)
    f:Hide()

    BG.HopeMainFrame = f
    BG.HopeMainFrameTabNum = HOPE_TAB_NUM

    return f
end

local function AttachHopeTabScripts(hopeFrame)
    local function HideBiaoGeFBTabs()
        if BG.TabButtonsFB then
            BG.TabButtonsFB:Hide()
        end
        if BG.TabButtonsFB_TBC then
            BG.TabButtonsFB_TBC:Hide()
        end
    end

    local function ShowHopeFBTabs()
        if BG.BGP_WishlistTabButtonsFB then
            BG.BGP_WishlistTabButtonsFB:Show()
        end
    end

    local function HideHopeFBTabs()
        if BG.BGP_WishlistTabButtonsFB then
            BG.BGP_WishlistTabButtonsFB:Hide()
        end
    end

    hopeFrame:SetScript("OnShow", function()
        BiaoGe.lastFrame = "Hope"
        if ns.BridgeBGLiteData then
            ns.BridgeBGLiteData()
        end
        if BG.FrameHide then
            BG.FrameHide(0)
        end
        -- 心愿页不显示左侧拍卖记录，避免干扰
        if BG.auctionLogFrame and BG.auctionLogFrame:IsVisible() then
            BG.auctionLogFrame:Hide()
        end
        HideBiaoGeFBTabs()
        if BG.NanDuDropDown and BG.NanDuDropDown.DropDown then
            BG.NanDuDropDown.DropDown:Hide()
        end
        if BG.BGP_BuildHopeUI then
            BG.BGP_BuildHopeUI()
        end
        ShowHopeFBTabs()
        if BG.BGP_LayoutHopeExportImport then
            BG.BGP_LayoutHopeExportImport(true)
        end
        if BG.UpdateHopeFrame_IsLooted_All then
            BG.UpdateHopeFrame_IsLooted_All()
        end
    end)

    hopeFrame:SetScript("OnHide", function()
        HideHopeFBTabs()
        if BG.BGP_LayoutHopeExportImport then
            BG.BGP_LayoutHopeExportImport(false)
        end
    end)
end

local function InstallHopeTab()
    if not BG.MainFrame or not BG.Create_TabButton or not BG.tabButtons then
        return false
    end
    if BG.BGP_HopeTabInstalled then
        local existing = EnsureHopeMainFrame()
        if existing then
            AttachHopeTabScripts(existing)
        end
        return true
    end

    local hopeFrame = EnsureHopeMainFrame()
    if not hopeFrame then
        return false
    end

    for _, v in ipairs(BG.tabButtons) do
        if v.num == HOPE_TAB_NUM then
            local tabText = L["心愿清单"]
            local fs = v.button:GetFontString()
            if fs then
                fs:SetText(tabText)
            end
            v.button:SetWidth((fs and fs:GetStringWidth() or 80) + 20)
            AttachHopeTabScripts(hopeFrame)
            BG.BGP_HopeTabInstalled = true
            return true
        end
    end

    BG.Create_TabButton(HOPE_TAB_NUM, L["心愿清单"], hopeFrame, 105)
    BG.BGP_HopeTabInstalled = true
    AttachHopeTabScripts(hopeFrame)

    return true
end

function BG.BGP_OpenHopeTab()
    if not InstallHopeTab() then
        print("|cff00BFFF<BGLite Plus>|r BGLite 主界面未就绪，请 /reload 后重试。")
        return
    end
    if BG.BGP_BuildHopeUI then
        BG.BGP_BuildHopeUI()
    end
    if BG.MainFrame and not BG.MainFrame:IsVisible() then
        BG.MainFrame:Show()
    end
    BG.ClickTabButton(HOPE_TAB_NUM)
end

BG.OpenWishlist = BG.BGP_OpenHopeTab

local function EnsureHopeTabOnMainFrame()
    InstallHopeTab()
end

-- BGLite UI 在 Plus 加载前已建好，/reload 时也需立即挂 Tab
C_Timer.After(0, EnsureHopeTabOnMainFrame)

ns.RunWhenReady(EnsureHopeTabOnMainFrame)

-- 打开主窗时再兜底一次
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
