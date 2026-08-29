local _, ns = ...

local function HideZhuangbeiList()
    if BG.FrameZhuangbeiList then
        BG.FrameZhuangbeiList:Hide()
    end
end

-- 心愿页 HopeMainFrame/格子 Level 远高于 BGLite 列表(120)，列表会被盖住无法点击。
local function RaiseZhuangbeiListAboveHope()
    local f = BG.FrameZhuangbeiList
    if not f or not f.SetFrameStrata then
        return
    end
    if not (BG.HopeMainFrame and BG.HopeMainFrame:IsShown()) then
        return
    end
    f:SetFrameStrata("TOOLTIP")
    f:SetToplevel(true)
    f:SetFrameLevel(500)
    local base = f:GetFrameLevel()
    for _, child in ipairs({ f:GetChildren() }) do
        if child and child.SetFrameLevel then
            child:SetFrameLevel(base + 10)
        end
    end
end

local function WrapSetListzhuangbei()
    if BG.BGP_SetListzhuangbeiWrapped or not BG.SetListzhuangbei then
        return
    end
    local origSetListzhuangbei = BG.SetListzhuangbei
    function BG.SetListzhuangbei(self)
        HideZhuangbeiList()
        local a, b, c, d, e = origSetListzhuangbei(self)
        RaiseZhuangbeiListAboveHope()
        local f = BG.FrameZhuangbeiList
        if f and not f.BGP_RaisedOnShow then
            f:HookScript("OnShow", RaiseZhuangbeiListAboveHope)
            f.BGP_RaisedOnShow = true
        end
        return a, b, c, d, e
    end
    BG.BGP_SetListzhuangbeiWrapped = true
end

local function WrapFrameHide()
    if BG.BGP_FrameHideWrapped or not BG.FrameHide then
        return
    end
    function BG.FrameHide(num, opts)
        opts = opts or {}
        if num == 0 then
            if BG.lastfocus then
                BG.lastfocus:ClearFocus()
            end
        end
        if BG.FrameZhuangbeiList and not opts.keepZhuangbeiList then
            BG.FrameZhuangbeiList:Hide()
        end
        if BG.FrameMaijiaList then
            BG.FrameMaijiaList:Hide()
        end
        if BG.FrameJineList then
            BG.FrameJineList:Hide()
        end
        if BG.ButtonAucitonWA and BG.ButtonAucitonWA.frame then
            BG.ButtonAucitonWA.frame:Hide()
        end
        if BG.frameExportHope then
            BG.frameExportHope:Hide()
        end
        if BG.frameImportHope then
            BG.frameImportHope:Hide()
        end
        if BG.auctionLogFrame and BG.auctionLogFrame.changeFrame then
            BG.auctionLogFrame.changeFrame:Hide()
        end
    end
    BG.BGP_FrameHideWrapped = true
end

function BG.BGP_SetListzhuangbei(self)
    WrapSetListzhuangbei()
    if BG.SetListzhuangbei then
        return BG.SetListzhuangbei(self)
    end
end

BG.TCOSetListzhuangbei = BG.BGP_SetListzhuangbei

function BG.BGP_HideZhuangbeiList()
    HideZhuangbeiList()
end

function BG.OpenHopeLootPicker(bt)
    if not bt then return end
    WrapSetListzhuangbei()
    HideZhuangbeiList()
    local fn = BG.BGP_SetListzhuangbei or BG.SetListzhuangbei
    if fn then
        local ok, err = pcall(fn, bt)
        if ok then
            RaiseZhuangbeiListAboveHope()
            return
        end
        print("|cff00BFFF<BGLite Plus>|r 装备列表打开失败:", tostring(err))
    end
    if BG.BGP_ShowHopeLootList or BG.TCOShowHopeLootList then
        (BG.BGP_ShowHopeLootList or BG.TCOShowHopeLootList)(bt)
        RaiseZhuangbeiListAboveHope()
    end
end

-- BGLite UpdateBiaoGeAllIsHaved 心愿分支用 Maxb/GetMaxi 遍历，
-- 但心愿格只建到 HopeMaxb/HopeMaxi，访问缺失 boss 会 nil 崩。
-- 不能改 BGLite，这里用安全实现覆盖。
local function WrapUpdateBiaoGeAllIsHaved()
    if BG.BGP_UpdateBiaoGeAllIsHavedWrapped or not BG.UpdateBiaoGeAllIsHaved then
        return
    end
    function BG.UpdateBiaoGeAllIsHaved()
        local FB = BG.FB1
        if not FB then
            return
        end
        if BG.FBMainFrame and BG.FBMainFrame:IsVisible() and BG.Frame and BG.Frame[FB] then
            local maxb = (BG.Maxb and BG.Maxb[FB]) or (Maxb and Maxb[FB]) or 0
            for b = 1, maxb do
                local boss = BG.Frame[FB]["boss" .. b]
                if boss then
                    local maxi = (BG.GetMaxi and BG.GetMaxi(FB, b)) or 0
                    for i = 1, maxi do
                        local bt = boss["zhuangbei" .. i]
                        if bt then
                            BG.IsHave(bt)
                        end
                    end
                end
            end
        elseif BG.HopeMainFrame and BG.HopeMainFrame:IsVisible() and BG.HopeFrame and BG.HopeFrame[FB] then
            local maxn = (ns.HopeMaxn and ns.HopeMaxn[FB])
                or (BG.HopeMaxn and BG.HopeMaxn[FB])
                or (HopeMaxn and HopeMaxn[FB])
                or 1
            local maxb = (ns.HopeMaxb and ns.HopeMaxb[FB])
                or (BG.HopeMaxb and BG.HopeMaxb[FB])
                or (HopeMaxb and HopeMaxb[FB])
                or 0
            local maxi = ns.HopeMaxi or BG.HopeMaxi or HopeMaxi or 7
            for n = 1, maxn do
                local nandu = BG.HopeFrame[FB]["nandu" .. n]
                if nandu then
                    for b = 1, maxb do
                        local boss = nandu["boss" .. b]
                        if boss then
                            for i = 1, maxi do
                                local bt = boss["zhuangbei" .. i]
                                if bt then
                                    BG.IsHave(bt)
                                end
                            end
                        end
                    end
                end
            end
        elseif BG.DuiZhangMainFrame and BG.DuiZhangMainFrame:IsVisible() and BG.DuiZhangFrame and BG.DuiZhangFrame[FB] then
            local maxb = (BG.Maxb and BG.Maxb[FB]) or (Maxb and Maxb[FB]) or 0
            for b = 1, maxb do
                local boss = BG.DuiZhangFrame[FB]["boss" .. b]
                if boss then
                    local maxi = (BG.GetMaxi and BG.GetMaxi(FB, b)) or 0
                    for i = 1, maxi do
                        local bt = boss["zhuangbei" .. i]
                        if bt then
                            BG.IsHave(bt)
                        end
                    end
                end
            end
        end
    end
    BG.BGP_UpdateBiaoGeAllIsHavedWrapped = true
end

WrapSetListzhuangbei()
WrapFrameHide()
WrapUpdateBiaoGeAllIsHaved()
ns.RunWhenReady(function()
    WrapSetListzhuangbei()
    WrapFrameHide()
    WrapUpdateBiaoGeAllIsHaved()
end)
