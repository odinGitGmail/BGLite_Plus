local _, ns = ...

local function HideZhuangbeiList()
    if BG.FrameZhuangbeiList then
        BG.FrameZhuangbeiList:Hide()
    end
end

local function WrapSetListzhuangbei()
    if BG.BGP_SetListzhuangbeiWrapped or not BG.SetListzhuangbei then
        return
    end
    local origSetListzhuangbei = BG.SetListzhuangbei
    function BG.SetListzhuangbei(self)
        HideZhuangbeiList()
        return origSetListzhuangbei(self)
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
        if ok then return end
        print("|cff00BFFF<BGLite Plus>|r 装备列表打开失败:", tostring(err))
    end
    if BG.BGP_ShowHopeLootList or BG.TCOShowHopeLootList then
        (BG.BGP_ShowHopeLootList or BG.TCOShowHopeLootList)(bt)
    end
end

WrapSetListzhuangbei()
WrapFrameHide()
ns.RunWhenReady(function()
    WrapSetListzhuangbei()
    WrapFrameHide()
end)
