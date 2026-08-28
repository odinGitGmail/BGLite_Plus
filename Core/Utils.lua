local _, ns = ...

local function Round(number, decimal_places)
    local mult = 10 ^ (decimal_places or 0)
    return math.floor(number * mult + 0.5) / mult
end
ns.Round = Round

local function RGB_16(name, r, g, b)
    if not r then
        r, g, b = name:GetTextColor()
        name = name:GetText()
    end
    local rr = string.format("%X", tonumber(r) * 255)
    if rr and strlen(rr) == 1 then rr = "0" .. rr end
    local gg = string.format("%X", tonumber(g) * 255)
    if gg and strlen(gg) == 1 then gg = "0" .. gg end
    local bb = string.format("%X", tonumber(b) * 255)
    if bb and strlen(bb) == 1 then bb = "0" .. bb end
    local c = rr .. gg .. bb
    if name then
        return "|cff" .. c .. name .. "|r"
    end
    return c
end
ns.RGB_16 = RGB_16

local function AddTexture(texture, y, coord, width)
    if not texture then return "" end
    y = y or "-0"
    coord = coord or ""
    local tex
    if texture == "BOX" then
        tex = "Interface\\AddOns\\BGLite\\Media\\icon\\BOX"
    elseif texture == "DD" then
        tex = "Interface\\AddOns\\BGLite\\Media\\icon\\DD"
    else
        tex = texture
    end
    width = width or 0
    return "|T" .. tex .. ":" .. width .. ":" .. width .. ":0:" .. y .. coord .. "|t"
end
ns.AddTexture = AddTexture

local function GetText_T(bt)
    local text = type(bt) == "table" and bt:GetText() or bt
    return text:gsub("|T.-|t", ""):gsub("|A.-|a", "")
end
ns.GetText_T = GetText_T

local function GetClassRGB(name, player, alpha)
    local _, class
    if player then
        _, class = UnitClass(player)
    else
        _, class = UnitClass(BG.GSN(name))
    end
    local c1, c2, c3 = 1, 1, 1
    if class then
        c1, c2, c3 = GetClassColor(class)
    end
    return c1, c2, c3, alpha
end
ns.GetClassRGB = GetClassRGB

local function SetClassCFF(name, player, keepPlain)
    if keepPlain then return name end
    local _, class
    if player then
        _, class = UnitClass(player)
    else
        _, class = UnitClass(BG.GSN(name))
    end
    if class then
        local color = select(4, GetClassColor(class))
        return "|c" .. color .. name .. "|r"
    end
    return name
end
ns.SetClassCFF = SetClassCFF

local function GetItemID(text)
    if not text then return end
    return tonumber(text:match("item:(%d+):"))
end
ns.GetItemID = GetItemID

ns.GetClassColor = GetClassColor

function BG.GSN(name)
    if not name then return end
    local n = name:match("^([^%-]+)")
    return n or name
end

BG.After = BG.After or C_Timer.After

ns.MediaIcon = {
    logo = "Interface\\Icons\\INV_Misc_Book_09",
    BOX = "Interface\\AddOns\\BGLite\\Media\\icon\\BOX",
    DD = "Interface\\AddOns\\BGLite\\Media\\icon\\DD",
}

local classNameTbl = {
    WARRIOR = GetClassInfo(1),
    PALADIN = GetClassInfo(2),
    HUNTER = GetClassInfo(3),
    ROGUE = GetClassInfo(4),
    PRIEST = GetClassInfo(5),
    DEATHKNIGHT = GetClassInfo(6),
    SHAMAN = GetClassInfo(7),
    MAGE = GetClassInfo(8),
    WARLOCK = GetClassInfo(9),
    MONK = GetClassInfo(10),
    DRUID = GetClassInfo(11),
    DEMONHUNTER = GetClassInfo(12),
    EVOKER = GetClassInfo(13),
}
function ns.GetClassName(classFile)
    return classNameTbl[classFile]
end
