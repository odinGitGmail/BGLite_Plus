local AddonName, ns = ...

BG = BG or {}
BiaoGe = BiaoGe or {}

ns.RR = "|r"
ns.NN = "\n"
ns.RN = "|r\n"

local function RGB(hex, alpha)
    local r = tonumber(hex:sub(1, 2), 16) / 255
    local g = tonumber(hex:sub(3, 4), 16) / 255
    local b = tonumber(hex:sub(5, 6), 16) / 255
    if alpha then
        return r, g, b, alpha
    end
    return r, g, b
end
ns.RGB = RGB

ns.GetClassColor = GetClassColor

local function Size(t)
    local s = 0
    for _, v in pairs(t) do
        if v ~= nil then s = s + 1 end
    end
    return s
end
ns.Size = Size

ns.LibBG = LibStub:GetLibrary("BiaoGe-LibUIDropDownMenu-4.0", true)

-- 世界 Boss CD 团队通报（BGLite Plus 不实现，保持空函数避免报错）
ns.SendMyWorldBossCD = function() end

-- BGLite 已加载完毕后才加载 Plus，BG.Init 回调不会再触发，改为立即执行
if BG and BG.Init then
    function BG.Init(func)
        securecall(func)
    end
end

local function BridgeBGLiteData()
    if not BG or not BG.FBtable then
        return false
    end

    ns.Maxb = BG.Maxb
    ns.Maxi = BG.Maxi
    ns.Maxt = BG.Maxt

    local hopeMaxb, hopeMaxn = {}, {}
    for _, fb in ipairs(BG.FBtable) do
        hopeMaxb[fb] = BG.Maxb and BG.Maxb[fb] and (BG.Maxb[fb] - 1) or 12
        hopeMaxn[fb] = BG.difficultyTable and BG.difficultyTable[fb] and #BG.difficultyTable[fb] or 1
    end
    ns.HopeMaxb = hopeMaxb
    ns.HopeMaxn = hopeMaxn
    ns.HopeMaxi = BG.HopeMaxi or 7

    BiaoGe.options = BiaoGe.options or {}
    local defaults = {
        roleOverviewAlpha = 0.9,
        roleOverviewLayout = "new",
        roleOverviewShowNote = 1,
        roleOverviewShowNote_width = 80,
        roleOverviewShowTalent = 1,
        roleOverviewShowOtherEquip = 1,
        tipsSound = 1,
        hopeAuctionSound = 1,
        Sound = "AI",
    }
    for k, v in pairs(defaults) do
        if BiaoGe.options[k] == nil then
            BiaoGe.options[k] = v
        end
    end

    BiaoGe.FBCDchoice = BiaoGe.FBCDchoice or {}
    BiaoGe.MONEYchoice = BiaoGe.MONEYchoice or {}
    BiaoGe.SKILLchoice = BiaoGe.SKILLchoice or {}

    return true
end

-- PLAYER_LOGIN 在 /reload 后不会再次触发，需同时支持立即执行
function ns.RunWhenReady(func)
    local function run()
        if not BridgeBGLiteData() then
            return false
        end
        securecall(func)
        return true
    end

    if BG and BG.Init3 then
        BG.Init3(run)
    end

    if IsLoggedIn() then
        C_Timer.After(0, run)
        C_Timer.After(0.3, run)
        C_Timer.After(1, run)
    end

    return run
end

function ns.BridgeBGLiteData()
    return BridgeBGLiteData()
end

-- 后续 Module 会在加载时读取 ns.HopeMax*，必须在文件加载前桥接 BGLite 数据
BridgeBGLiteData()
