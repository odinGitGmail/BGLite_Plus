local _, ns = ...

-- 内部模块仍使用 TCO 前缀的函数名时，在此统一到 BGP 命名
BG.BGP_ClearHope = BG.BGP_ClearHope or BG.TCOClearHope
BG.TCOClearHope = BG.BGP_ClearHope

BG.BGPPatchHopeEditBg = BG.BGPPatchHopeEditBg or BG.TCOPatchHopeEditBg
BG.TCOPatchHopeEditBg = BG.BGPPatchHopeEditBg

BG.BGPCleanupHopeOverlays = BG.BGPCleanupHopeOverlays or BG.TCOCleanupHopeOverlays
BG.TCOCleanupHopeOverlays = BG.BGPCleanupHopeOverlays

BG.BGP_ShowHopeLootList = BG.BGP_ShowHopeLootList or BG.TCOShowHopeLootList
BG.TCOShowHopeLootList = BG.BGP_ShowHopeLootList

BG.BGPHopeToolbar = BG.BGPHopeToolbar or BG.TCOHopeToolbar
BG.TCOHopeToolbar = BG.BGPHopeToolbar

BG.BGPHopeUIBuilt = BG.BGPHopeUIBuilt or BG.TCOHopeUIBuilt
BG.TCOHopeUIBuilt = BG.BGPHopeUIBuilt

BG.BGP_SetListzhuangbei = BG.BGP_SetListzhuangbei or BG.TCOSetListzhuangbei or BG.SetListzhuangbei
BG.TCOSetListzhuangbei = BG.BGP_SetListzhuangbei

-- 覆盖 BGLite 空壳
if BG.SetFBCD then
    -- RoleOverview_core 加载后会替换
end

function BG.UpdateHopeFrame_IsLooted_All()
    if not BG.HopeFrame or not BG.FB1 then return end
    local FB = BG.FB1
    if not ns.HopeMaxn or not ns.HopeMaxn[FB] then return end
    for n = 1, ns.HopeMaxn[FB] do
        for b = 1, (ns.HopeMaxb and ns.HopeMaxb[FB] or 0) do
            for i = 1, (ns.HopeMaxi or 7) do
                local bt = BG.HopeFrame[FB]
                    and BG.HopeFrame[FB]["nandu" .. n]
                    and BG.HopeFrame[FB]["nandu" .. n]["boss" .. b]
                    and BG.HopeFrame[FB]["nandu" .. n]["boss" .. b]["zhuangbei" .. i]
                if bt and BG.Update_IsLooted then
                    BG.Update_IsLooted(bt)
                end
            end
        end
    end
end
