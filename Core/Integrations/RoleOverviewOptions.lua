local _, ns = ...
local L = ns.L
local LibBG = ns.LibBG
local RR = ns.RR
local RGB = ns.RGB
local AddTexture = ns.AddTexture

BG.options = BG.options or {}

local function BuildRoleOverviewTab(roleOverview)
    local O = ns.O
    if not O or not O.CreateSlider then
        return false
    end

    local height = 0
    local h = 30
    local openButton

    -- UI 缩放
    do
        local name = "roleOverviewScale"
        BG.options[name .. "reset"] = 1
        BiaoGe.options[name] = BiaoGe.options[name] or BG.options[name .. "reset"]
        if not tonumber(BiaoGe.options[name]) then
            BiaoGe.options[name] = BG.options[name .. "reset"]
        end
        local ontext = {
            L["角色总览UI缩放"] .. L["|cff808080（右键还原设置）|r"],
            L["调整角色总览UI的大小。"],
        }
        local f = O.CreateSlider(name, "|cffFFFFFF" .. L["角色总览UI缩放"] .. "|r", roleOverview, 0.5, 1.5, 0.01, 15, height - h, ontext, 150)
        BG.options["button" .. name] = f
        f:SetScript("OnValueChanged", function(self, value)
            f.edit:ClearFocus()
            value = tonumber(string.format("%.2f", value))
            BiaoGe.options[name] = value
            f.edit:SetText(value)
            if BG.UpdateFBCDFrameScale then
                BG.UpdateFBCDFrameScale()
            end
        end)
        f.button:SetScript("OnClick", function(self, enter)
            if enter == "RightButton" and BG.options[name .. "reset"] then
                local value = BG.options[name .. "reset"]
                BiaoGe.options[name] = value
                f:SetValue(value)
                f.edit:SetText(value)
                if BG.UpdateFBCDFrameScale then
                    BG.UpdateFBCDFrameScale()
                end
                BG.PlaySound(1)
            end
        end)
    end

    -- 背景透明度
    do
        local name = "roleOverviewAlpha"
        BG.options[name .. "reset"] = 0.9
        BiaoGe.options[name] = BiaoGe.options[name] or BG.options[name .. "reset"]
        if not tonumber(BiaoGe.options[name]) then
            BiaoGe.options[name] = BG.options[name .. "reset"]
        end
        local ontext = {
            L["角色总览背景透明度"] .. L["|cff808080（右键还原设置）|r"],
            L["调整角色总览背景的透明度。"],
        }
        local f = O.CreateSlider(name, "|cffFFFFFF" .. L["角色总览背景透明度"] .. "|r", roleOverview, 0, 1, 0.05, 190, height - h, ontext, 150)
        BG.options["button" .. name] = f
        f:SetScript("OnValueChanged", function(self, value)
            f.edit:ClearFocus()
            value = tonumber(string.format("%.2f", value))
            BiaoGe.options[name] = value
            f.edit:SetText(value)
            if BG.FBCDFrame then
                BG.FBCDFrame:SetBackdropColor(0, 0, 0, value)
            end
        end)
        f.button:SetScript("OnClick", function(self, enter)
            if enter == "RightButton" and BG.options[name .. "reset"] then
                local value = BG.options[name .. "reset"]
                BiaoGe.options[name] = value
                f:SetValue(value)
                f.edit:SetText(value)
                if BG.FBCDFrame then
                    BG.FBCDFrame:SetBackdropColor(0, 0, 0, value)
                end
                BG.PlaySound(1)
            end
        end)
    end
    h = h + 50

    if O.CreateBindKey then
        O.CreateBindKey(roleOverview, 360, -28, 130, "RoleOverview", L["角色总览快捷键"])
    end

    if BG.optionsBackground then
        local bt = BG.CreateButton(roleOverview)
        bt:SetSize(100, 25)
        bt:SetPoint("TOPRIGHT", BG.optionsBackground:GetWidth() - 45, -10)
        bt:SetText(L["打开总览"])
        openButton = bt
        bt:SetScript("OnClick", function()
            if BG.SetFBCD then
                BG.SetFBCD(nil, nil, true)
            end
        end)

        local delBt = BG.CreateButton(roleOverview)
        delBt:SetSize(openButton:GetWidth(), 25)
        delBt:SetPoint("TOP", openButton, "BOTTOM", 0, -5)
        delBt:SetText(L["删除角色"])
        delBt:SetScript("OnClick", function()
            if BG.ShowDeleteCharacterDialog then
                BG.ShowDeleteCharacterDialog()
            end
        end)
    end

    return true
end

local function BuildWishlistTab(wishlist)
    local O = ns.O
    if not O or not O.CreateCheckButton then
        return false
    end

    local height = 0
    local h = 30

    if O.CreateLine then
        O.CreateLine(wishlist, height - h)
        h = h + 15
    end

    do
        local name = "tipsSound"
        BG.options[name .. "reset"] = 1
        BiaoGe.options[name] = BiaoGe.options[name] or BG.options[name .. "reset"]
        local ontext = {
            L["心愿达成语音"],
            L["当团队里有人拾取（或获得）心愿清单中的装备时，播放语音并显示屏幕提醒。"],
        }
        local f = O.CreateCheckButton(name, L["心愿达成语音"], wishlist, 15, height - h, ontext, true)
        BG.options["buttonBGP_" .. name] = f
    end
    h = h + 35

    do
        local name = "hopeAuctionSound"
        BG.options[name .. "reset"] = 1
        BiaoGe.options[name] = BiaoGe.options[name] or BG.options[name .. "reset"]
        local ontext = {
            L["心愿拍卖语音"],
            L["当团长在团队频道拍卖心愿清单中的装备时，播放「拍卖啦」语音提醒。"],
        }
        local f = O.CreateCheckButton(name, L["心愿拍卖语音"], wishlist, 15, height - h, ontext, true)
        BG.options["buttonBGP_" .. name] = f
    end

    return true
end

function BG.ShowDeleteCharacterDialog()
    local chars = {}
    if BiaoGe and BiaoGe.MONEY then
        for rid, players in pairs(BiaoGe.MONEY) do
            if type(rid) == "number" and type(players) == "table" then
                for pname in pairs(players) do
                    if type(pname) == "string" then
                        tinsert(chars, { realmID = rid, player = pname })
                    end
                end
            end
        end
    end
    table.sort(chars, function(a, b)
        if a.realmID ~= b.realmID then
            return a.realmID < b.realmID
        end
        return a.player < b.player
    end)
    if #chars == 0 then
        if BG.SendSystemMessage then
            BG.SendSystemMessage(L["暂无角色数据"] or "暂无角色数据")
        end
        return
    end

    if not BG.deleteCharFrame then
        local f = CreateFrame("Frame", "BGPDeleteCharFrame", UIParent, "BackdropTemplate")
        f:SetSize(280, 320)
        f:SetPoint("CENTER")
        f:SetBackdrop({
            bgFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        f:SetBackdropColor(0, 0, 0, 0.9)
        f:EnableMouse(true)
        f:SetMovable(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", f.StartMoving)
        f:SetScript("OnDragStop", f.StopMovingOrSizing)

        local title = f:CreateFontString(nil, "OVERLAY")
        title:SetFont(BIAOGE_TEXT_FONT, 16, "OUTLINE")
        title:SetPoint("TOP", 0, -12)
        title:SetText(L["删除角色"])

        local close = BG.CreateButton(f)
        close:SetSize(60, 22)
        close:SetPoint("BOTTOM", 0, 12)
        close:SetText(CLOSE)
        close:SetScript("OnClick", function()
            f:Hide()
        end)

        local scroll = CreateFrame("ScrollFrame", nil, f, BG.scrollTemplate or "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 12, -40)
        scroll:SetPoint("BOTTOMRIGHT", -28, 44)
        if BG.CreateSrollBarBackdrop then
            BG.CreateSrollBarBackdrop(scroll.ScrollBar)
        end
        if BG.HookScrollBarShowOrHide then
            BG.HookScrollBarShowOrHide(scroll)
        end

        local content = CreateFrame("Frame", nil, scroll)
        content:SetSize(220, 1)
        scroll:SetScrollChild(content)
        f.content = content
        BG.deleteCharFrame = f
    end

    local f = BG.deleteCharFrame
    local content = f.content
    for _, child in pairs({ content:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end

    local y = -4
    for _, c in ipairs(chars) do
        local bt = BG.CreateButton(content)
        bt:SetSize(220, 24)
        bt:SetPoint("TOPLEFT", 0, y)
        bt:SetText(c.player)
        bt:SetScript("OnClick", function()
            if BG.DeletePlayerData then
                BG.DeletePlayerData(c.realmID, c.player)
            end
            f:Hide()
            if GetRealmID() == c.realmID and BG.playerName == c.player then
                ReloadUI()
            elseif BG.RefreshFBCDFrame then
                BG.RefreshFBCDFrame()
            end
        end)
        y = y - 28
    end
    content:SetHeight(math.max(1, #chars * 28 + 8))
    f:Show()
end

local function InstallPlusOptionsTabs()
    if BG.ButtonOptions_roleOverview then
        return true
    end
    if not BG.OptionsCreateTab or not ns.O or not ns.O.CreateSlider then
        return false
    end

    local roleOverview = BG.OptionsCreateTab("Options_roleOverview", L["角色总览"])
    local wishlist = BG.OptionsCreateTab("Options_wishlist", L["心愿清单"])
    BuildRoleOverviewTab(roleOverview)
    BuildWishlistTab(wishlist)
    return true
end

function BG.BGP_OpenRoleOverviewOptions()
    if BG.OpenOption then
        BG.OpenOption()
    end
    if BG.ButtonOptions_roleOverview then
        BG.ButtonOptions_roleOverview:Click()
    end
end

ns.RunWhenReady(function()
    if InstallPlusOptionsTabs() then
        return
    end
    C_Timer.After(0.5, InstallPlusOptionsTabs)
    C_Timer.After(1, InstallPlusOptionsTabs)
    C_Timer.After(2, InstallPlusOptionsTabs)
end)
