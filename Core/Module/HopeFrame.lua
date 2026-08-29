local _, ns = ...

local L = ns.L
local LibBG = ns.LibBG

local HOPE_UI_VERSION = 15

local function EnsureHopeSaved()
    local realmID = GetRealmID()
    local player = BG.playerName
    BiaoGe.Hope = BiaoGe.Hope or {}
    BiaoGe.Hope[realmID] = BiaoGe.Hope[realmID] or {}
    BiaoGe.Hope[realmID][player] = BiaoGe.Hope[realmID][player] or {}
    for _, FB in ipairs(BG.FBtable or {}) do
        BiaoGe.Hope[realmID][player][FB] = BiaoGe.Hope[realmID][player][FB] or {}
        local nanduCount = (ns.HopeMaxn and ns.HopeMaxn[FB]) or 1
        for n = 1, nanduCount do
            BiaoGe.Hope[realmID][player][FB]["nandu" .. n] =
                BiaoGe.Hope[realmID][player][FB]["nandu" .. n] or {}
            local bossCount = (ns.HopeMaxb and ns.HopeMaxb[FB]) or 12
            for b = 1, bossCount do
                BiaoGe.Hope[realmID][player][FB]["nandu" .. n]["boss" .. b] =
                    BiaoGe.Hope[realmID][player][FB]["nandu" .. n]["boss" .. b] or {}
            end
        end
    end
end

local function IsHopeWidget(widget, hopeFrame)
    return widget
        and hopeFrame
        and widget.GetObjectType
        and widget:GetObjectType() == "EditBox"
        and widget:GetParent() == hopeFrame
end

local function HopeContentHeight(FB)
    local rows = (ns.HopeMaxb and ns.HopeMaxb[FB]) or 12
    local nandu = (ns.HopeMaxn and ns.HopeMaxn[FB]) or 1
    return 40 + nandu * (50 + rows * 22)
end

local function ApplyHopeFrameSize(FB)
    if not FB then return end
    local w = (BG.FBWidth and BG.FBWidth[FB]) or (BG.MainFrame and BG.MainFrame:GetWidth()) or 1275
    local h = HopeContentHeight(FB)
    local hf = BG["HopeFrame" .. FB]
    if hf then
        hf:SetSize(w - 48, h)
    end
end

local function HopeGridMissing(FB)
    local hopeFrame = BG["HopeFrame" .. FB]
    if not hopeFrame or not hopeFrame.isBGPHope then
        return true
    end
    if not ns.HopeMaxn or not ns.HopeMaxn[FB] or not ns.HopeMaxb or not ns.HopeMaxb[FB] then
        return true
    end
    if ns.HopeMaxb[FB] <= 0 or ns.HopeMaxn[FB] <= 0 then
        return true
    end
    local grid = BG.HopeFrame and BG.HopeFrame[FB]
    if not grid then
        return true
    end
    for n = 1, ns.HopeMaxn[FB] do
        for b = 1, ns.HopeMaxb[FB] do
            local cell = grid["nandu" .. n]
                and grid["nandu" .. n]["boss" .. b]
                and grid["nandu" .. n]["boss" .. b]["zhuangbei1"]
            if not IsHopeWidget(cell, hopeFrame) then
                return true
            end
        end
    end
    return false
end

local function DestroyHopeFrame(FB)
    local oldFrame = BG["HopeFrame" .. FB]
    if oldFrame then
        oldFrame.bgpHopeGridBuilt = nil
        oldFrame.bgpHopeShowHooked = nil
        oldFrame:Hide()
        oldFrame:SetParent(nil)
    end
    BG["HopeFrame" .. FB] = nil
    if BG.HopeFrame then
        BG.HopeFrame[FB] = nil
    end
    if BG.BGPHopeUIBuilt then
        BG.BGPHopeUIBuilt[FB] = nil
    end
end

local function FixHopeWidgetLevels(FB)
    local hopeFrame = BG["HopeFrame" .. FB]
    if not hopeFrame or not BG.HopeFrame or not BG.HopeFrame[FB] then
        return
    end
    if not ns.HopeMaxn or not ns.HopeMaxn[FB] then return end
    local base = hopeFrame:GetFrameLevel() + 5
    for n = 1, ns.HopeMaxn[FB] do
        for b = 1, ns.HopeMaxb[FB] do
            for i = 1, ns.HopeMaxi do
                local bt = BG.HopeFrame[FB]["nandu" .. n]["boss" .. b]["zhuangbei" .. i]
                if bt and bt.SetFrameLevel then
                    bt:SetFrameLevel(base)
                    bt:Show()
                end
            end
        end
    end
end

local function SwitchHopeFB(FB)
    if not FB or not BG["HopeFrame" .. FB] then
        FB = BG.FBtable and BG.FBtable[1]
    end
    if not FB then return end

    BG.FB1 = FB
    BiaoGe.FB = FB
    BiaoGe.lastFrame = "Hope"

    if BG.FrameHide then
        BG.FrameHide(0)
    end

    for _, fb in ipairs(BG.FBtable or {}) do
        if BG["HopeFrame" .. fb] then
            BG["HopeFrame" .. fb]:SetShown(fb == FB)
        end
        if BG.BGP_WishlistFBButtons and BG.BGP_WishlistFBButtons[fb] then
            BG.BGP_WishlistFBButtons[fb]:SetEnabled(fb ~= FB)
        end
        if BG.BGPHopeToolbar and BG.BGPHopeToolbar[fb] then
            for _, w in ipairs(BG.BGPHopeToolbar[fb]) do
                if w.SetShown then
                    w:SetShown(fb == FB)
                end
            end
        end
    end

    ApplyHopeFrameSize(FB)
    FixHopeWidgetLevels(FB)

    local hf = BG["HopeFrame" .. FB]
    if hf then
        hf:Show()
    end

    if LibBG and BG.HopeSenddropDown and BG.HopeSenddropDown[FB] and BiaoGe.HopeSendChannel and BG.HopeSendTable then
        LibBG:UIDropDownMenu_SetText(BG.HopeSenddropDown[FB], BG.HopeSendTable[BiaoGe.HopeSendChannel])
    end
    if BG.UpdateHopeFrame_IsLooted_All then
        BG.UpdateHopeFrame_IsLooted_All()
    end
end

local function RunHopeUI(FB)
    EnsureHopeSaved()
    if not ns.HopeMaxn or not ns.HopeMaxn[FB] or not ns.HopeMaxb or not ns.HopeMaxb[FB] or not ns.HopeMaxi then
        print("|cff00BFFF<BGLite Plus>|r 心愿数据未就绪 [" .. tostring(FB) .. "] HopeMaxn/HopeMaxb/HopeMaxi")
        return false
    end
    if ns.HopeMaxb[FB] <= 0 then
        print("|cff00BFFF<BGLite Plus>|r 心愿 Boss 数为 0 [" .. tostring(FB) .. "]")
        return false
    end
    local ok, result = pcall(BG.HopeUI, FB)
    if not ok then
        print("|cff00BFFF<BGLite Plus>|r 心愿 UI 构建失败 [" .. tostring(FB) .. "]:", tostring(result))
        return false
    end
    if result ~= true then
        print("|cff00BFFF<BGLite Plus>|r 心愿 UI 未生成 [" .. tostring(FB) .. "]，请 /bgp hope debug 查看详情")
        return false
    end
    FixHopeWidgetLevels(FB)
    print("|cff00BFFF<BGLite Plus>|r 心愿 UI 已构建 [" .. tostring(FB) .. "] "
        .. tostring(ns.HopeMaxb[FB]) .. " Boss × " .. tostring(ns.HopeMaxi) .. " 格")
    return true
end

function BG.BGP_HopeDebug()
    if ns.BridgeBGLiteData then
        ns.BridgeBGLiteData()
    end
    local FB = BG.FB1 or BiaoGe.FB or (BG.FBtable and BG.FBtable[1])
    print("|cff00BFFF[BGLite Plus 心愿调试]|r FB=", tostring(FB))
    local function Vis(f)
        if not f then return "无帧" end
        return "Shown=" .. tostring(f:IsShown()) .. " Visible=" .. tostring(f:IsVisible())
    end
    print("  HopeMainFrame=", BG.HopeMainFrame and "有" or "无",
        Vis(BG.HopeMainFrame),
        "Level=", BG.HopeMainFrame and BG.HopeMainFrame:GetFrameLevel() or "?")
    print("  HopeMaxn=", FB and ns.HopeMaxn and ns.HopeMaxn[FB],
        "HopeMaxb=", FB and ns.HopeMaxb and ns.HopeMaxb[FB],
        "HopeMaxi=", ns.HopeMaxi)
    print("  HopeGridMissing=", FB and tostring(HopeGridMissing(FB)) or "n/a",
        "BGPHopeUIBuilt=", FB and BG.BGPHopeUIBuilt and tostring(BG.BGPHopeUIBuilt[FB]) or "n/a")
    if FB then
        local hf = BG["HopeFrame" .. FB]
        print("  HopeFrame=", hf and "有" or "无",
            Vis(hf),
            "Level=", hf and hf:GetFrameLevel() or "?")
        local cell = BG.HopeFrame and BG.HopeFrame[FB]
            and BG.HopeFrame[FB]["nandu1"]
            and BG.HopeFrame[FB]["nandu1"]["boss1"]
            and BG.HopeFrame[FB]["nandu1"]["boss1"]["zhuangbei1"]
        print("  首格=", cell and (cell:GetObjectType() .. " L" .. cell:GetFrameLevel()
            .. " Shown=" .. tostring(cell:IsShown())
            .. " Visible=" .. tostring(cell:IsVisible())) or "无")
    end
end

function BG.BGP_ForceRebuildHope(FB)
    if FB then
        DestroyHopeFrame(FB)
    else
        for _, fb in ipairs(BG.FBtable or {}) do
            DestroyHopeFrame(fb)
        end
    end
    BG.BGP_BuildHopeUI()
end

StaticPopupDialogs["BGP_CLEAR_HOPE"] = {
    text = L["确定清空心愿？"],
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function()
        BG.BGP_ClearHope(BG.BGP_ClearHopeFB or BG.FB1 or BiaoGe.FB)
        if BG.PlaySound then BG.PlaySound(1) end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    showAlert = true,
}

local function EnsureClearButton(parent)
    if not parent then return end
    if not BG.ButtonHopeQingKong then
        local clearBt = BG.CreateButton(parent)
        clearBt:SetSize(120, 25)
        clearBt:SetText(L["清空心愿"])
        clearBt:SetScript("OnClick", function()
            BG.BGP_ClearHopeFB = BG.FB1 or BiaoGe.FB
            StaticPopup_Show("BGP_CLEAR_HOPE")
            if BG.PlaySound then BG.PlaySound(1) end
        end)
        BG.ButtonHopeQingKong = clearBt
    end
    BG.ButtonHopeQingKong:SetParent(parent)
    BG.ButtonHopeQingKong:ClearAllPoints()
    BG.ButtonHopeQingKong:SetPoint("BOTTOMLEFT", BG.MainFrame, "BOTTOMLEFT", 250, 38)
    BG.ButtonHopeQingKong:SetFrameLevel(parent:GetFrameLevel() + 10)
    BG.ButtonHopeQingKong:Show()
end

local function CreateHopeFBButtons(parent)
    if BG.BGP_WishlistTabButtonsFB then return end
    BG.BGP_WishlistFBButtons = {}
    BG.BGP_WishlistTabButtonsFB = CreateFrame("Frame", nil, parent)
    BG.BGP_WishlistTabButtonsFB:SetPoint("TOP", BG.MainFrame, "TOP", 0, -28)
    BG.BGP_WishlistTabButtonsFB:SetHeight(20)
    BG.BGP_WishlistTabButtonsFB:SetFrameLevel(parent:GetFrameLevel() + 10)

    local lastBtn
    local totalWidth = 0
    local seenFB = {}
    for _, v in ipairs(BG.FBtable2 or {}) do
        local FB = v.FB
        if not seenFB[FB] then
            seenFB[FB] = true
            local bt = CreateFrame("Button", nil, BG.BGP_WishlistTabButtonsFB)
            bt:SetHeight(20)
            bt:SetNormalFontObject(BG.FontBlue15)
            bt:SetDisabledFontObject(BG.FontWhite15)
            bt:SetHighlightFontObject(BG.FontWhite15)
            if not lastBtn then
                bt:SetPoint("LEFT")
            else
                bt:SetPoint("LEFT", lastBtn, "RIGHT", 0, 0)
            end
            bt:SetText(BG.GetFBinfo and BG.GetFBinfo(FB, "shortName") or FB)
            local fs = bt:GetFontString()
            bt:SetWidth((fs and fs:GetStringWidth() or 60) + 20)
            bt:SetHighlightTexture("Interface/PaperDollInfoFrame/UI-Character-Tab-Highlight")
            bt:SetScript("OnClick", function()
                SwitchHopeFB(FB)
                if BG.PlaySound then BG.PlaySound(1) end
            end)
            BG.BGP_WishlistFBButtons[FB] = bt
            totalWidth = totalWidth + bt:GetWidth()
            lastBtn = bt
        end
    end
    if totalWidth > 0 then
        BG.BGP_WishlistTabButtonsFB:SetWidth(totalWidth)
    end
    BG.BGP_WishlistTabButtonsFB:Hide()
end

local function EnsureHopeFrame(FB, parent)
    local hf = BG["HopeFrame" .. FB]
    if not hf then
        hf = CreateFrame("Frame", "BGP.HopeFrame." .. FB, parent)
        hf.isBGPHope = true
        hf.isTCOHope = true
        hf:Hide()
        BG["HopeFrame" .. FB] = hf
    end
    -- 防止父帧脱钩导致 Show 了但看不见
    if parent and hf:GetParent() ~= parent then
        hf:SetParent(parent)
    end
    hf:ClearAllPoints()
    hf:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
    hf:SetFrameLevel(parent:GetFrameLevel() + 2)
    return hf
end

function BG.BGP_BuildHopeUI()
    if not BG.IsTitan then
        print("|cff00BFFF<BGLite Plus>|r 心愿清单仅支持时光服。")
        return
    end
    if not BG.HopeMainFrame then return end
    if ns.BridgeBGLiteData then
        ns.BridgeBGLiteData()
    end

    if BG.BGPHopeUIVersion ~= HOPE_UI_VERSION then
        BG.BGPHopeUIVersion = HOPE_UI_VERSION
        BG.BGPHopeUIBuilt = {}
        for _, FB in ipairs(BG.FBtable or {}) do
            DestroyHopeFrame(FB)
        end
    end

    local parent = BG.HopeMainFrame

    EnsureHopeSaved()
    CreateHopeFBButtons(parent)
    EnsureClearButton(parent)

    BG.BGPHopeUIBuilt = BG.BGPHopeUIBuilt or {}

    for _, FB in ipairs(BG.FBtable or {}) do
        if not BG.BGPHopeUIBuilt[FB] or HopeGridMissing(FB) then
            DestroyHopeFrame(FB)
        end

        EnsureHopeFrame(FB, parent)

        if not BG.BGPHopeUIBuilt[FB] or HopeGridMissing(FB) then
            BG.BGPHopeUIBuilt[FB] = nil
            if RunHopeUI(FB) then
                BG.BGPHopeUIBuilt[FB] = true
            end
        end

        ApplyHopeFrameSize(FB)

        if BG.BGPCleanupHopeOverlays then
            BG.BGPCleanupHopeOverlays(FB)
        end
        if BG.BGPPatchHopeEditBg and ns.HopeMaxn and ns.HopeMaxn[FB] and BG.HopeFrame and BG.HopeFrame[FB] then
            for n = 1, ns.HopeMaxn[FB] do
                for b = 1, ns.HopeMaxb[FB] do
                    for i = 1, ns.HopeMaxi do
                        local bt = BG.HopeFrame[FB]["nandu" .. n]["boss" .. b]["zhuangbei" .. i]
                        if bt then
                            BG.BGPPatchHopeEditBg(bt)
                        end
                    end
                end
            end
        end
    end

    if BG.HopeDaoChuUI then
        BG.HopeDaoChuUI()
    end

    SwitchHopeFB(BiaoGe.FB or BG.FB1)
end

BG.TCOHopeUIBuilt = BG.BGPHopeUIBuilt
BG.TCOHopeToolbar = BG.BGPHopeToolbar
BG.TCOPatchHopeEditBg = BG.BGPPatchHopeEditBg
BG.TCOCleanupHopeOverlays = BG.BGPCleanupHopeOverlays

ns.RunWhenReady(function()
    if BG.IsTitan and BG.HopeMainFrame then
        BG.BGP_BuildHopeUI()
    end
end)
