local _, ns = ...
local L = ns.L
local LibBG = ns.LibBG
local RR = ns.RR
local RGB = ns.RGB
local AddTexture = ns.AddTexture

BG.options = BG.options or {}

local function SetParent(self, key)
    if BiaoGe.options[key] ~= 1 then
        self:Hide()
    end
    local parent = BG.options["button" .. key]
    if not parent then return end
    parent.child = parent.child or {}
    tinsert(parent.child, self)
    if not parent.hookDisable then
        parent.hookDisable = true
        hooksecurefunc(parent, "Disable", function()
            if parent.Text then
                parent.Text:SetTextColor(.5, .5, .5)
            end
            for _, child in ipairs(parent.child) do
                child:Hide()
            end
        end)
    end
end

local function ClearFrameChildren(frame)
    if not frame then return end
    for _, child in ipairs({ frame:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end
end

local function GetOptionsScrollChild(tabName)
    local outer = BG["Frame" .. tabName]
    if not outer then return end
    for _, child in ipairs({ outer:GetChildren() }) do
        if child.GetScrollChild then
            return child:GetScrollChild(), child
        end
    end
end

local function BuildRoleOverviewTab(roleOverview)
    local O = ns.O
    if not O or not O.CreateSlider then
        return false
    end
    if not roleOverview then
        return false
    end
    ClearFrameChildren(roleOverview)

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


    -- 团本/任务/专业/声望/货币勾选与排序布局等（自 TitanCharOverview 迁入）
    do
        local lastFrame
        local titles = {}
        local frameWidth = ((roleOverview.scroll and roleOverview.scroll:GetWidth()) or 600) - 20
        local frameHeight = 25
            -- 创建多选按钮
            local lastFrame
            local titles = {}
            local frameWidth = roleOverview.scroll:GetWidth() - 20
            local frameHeight = 25
            do
                local function CreateFBCDbutton(n1, n2, collapse, tblName, dbName)
                    local right
                    local first
                    local buttonWidth = 100
                    local buttonHeight = 25
                    local row = 1
                    tblName = tblName or "FBCDall_table"
                    dbName = dbName or "FBCDchoice"
                    for i = n1, n2 do
                        local name = dbName == "FBCDchoice" and BG[tblName][i].name or BG[tblName][i].id
                        local name2 = BG[tblName][i].name2
                        local color = BG[tblName][i].color
                        local fbId = BG[tblName][i].fbId
                        local type = BG[tblName][i].type
                        local diff = BG.GetDiffShortName(BG[tblName][i].diff) or ""
                        local bt = CreateFrame("CheckButton", nil, lastFrame.child2, "ChatConfigCheckButtonTemplate")
                        bt:SetSize(buttonHeight, buttonHeight)
                        bt:SetHitRectInsets(0, -buttonWidth + 45, 0, 0)
                        if not right then
                            bt:SetPoint("TOPLEFT", 0, -5)
                            first = bt
                        elseif roleOverview.scroll:GetRight() - right.Text:GetRight() > buttonWidth then
                            bt:SetPoint("TOPLEFT", right, "TOPLEFT", buttonWidth, 0)
                        else
                            bt:SetPoint("TOPLEFT", first, "BOTTOMLEFT", 0, 0)
                            first = bt
                            row = row + 1
                        end
                        right = bt
                        bt.Text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                        bt.Text:SetText("|cff" .. color .. diff .. (name2 or name):gsub("sod", "") .. RR)
                        bt.Text:SetWidth(buttonWidth - buttonHeight)
                        bt.Text:SetWordWrap(false)
                        if not BiaoGe[dbName][name] or BiaoGe[dbName][name] == 0 then
                            BiaoGe[dbName][name] = nil
                            bt:SetChecked(false)
                        else
                            BiaoGe[dbName][name] = 1
                            bt:SetChecked(true)
                        end
                        bt:SetScript("OnClick", function(self)
                            if self:GetChecked() then
                                BiaoGe[dbName][name] = 1
                            else
                                BiaoGe[dbName][name] = nil
                            end
                            BG.RefreshFBCDFrame()
                            BG.PlaySound(1)
                        end)
                        bt:SetScript("OnEnter", function(self)
                            local text
                            if dbName == "FBCDchoice" then
                                local maxplayers = BG[tblName][i].num and (BG[tblName][i].num .. L["人"]) or ""
                                text = "|cff" .. color .. maxplayers .. diff .. (name2 or GetRealZoneText(fbId)) .. RR
                                if type ~= "fb" then
                                    text = self.Text:GetText()
                                end
                            else
                                text = self.Text:GetText()
                            end
                            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
                            GameTooltip:ClearLines()
                            GameTooltip:SetText(text)
                        end)
                        bt:SetScript("OnLeave", GameTooltip_Hide)
                    end
                    lastFrame.height = buttonHeight * row + 5
                    lastFrame.child:SetHeight(lastFrame.height)
                    if collapse then
                        lastFrame:GetScript("OnMouseDown")(lastFrame)
                    end
                end
                local function CreateMONEYbutton(n1, n2, hide)
                    local right
                    local first
                    local buttonWidth = 65
                    local buttonHeight = 25
                    local row = 1
                    for i = n1, n2 do
                        local name = BG.MONEYall_table[i].name
                        local tex = BG.MONEYall_table[i].tex
                        local color = BG.MONEYall_table[i].color
                        local id = BG.MONEYall_table[i].id
                        local itemType = BG.MONEYall_table[i].type
                        local bt = CreateFrame("CheckButton", nil, lastFrame.child2, "ChatConfigCheckButtonTemplate")
                        bt:SetSize(buttonHeight, buttonHeight)
                        bt:SetHitRectInsets(0, -buttonWidth + 40, 0, 0)
                        if not right then
                            bt:SetPoint("TOPLEFT", 0, -5)
                            first = bt
                        elseif roleOverview.scroll:GetRight() - right.Text:GetRight() > buttonWidth then
                            bt:SetPoint("TOPLEFT", right, "TOPLEFT", buttonWidth, 0)
                        else
                            bt:SetPoint("TOPLEFT", first, "BOTTOMLEFT", 0, 0)
                            first = bt
                            row = row + 1
                        end
                        right = bt
                        bt.Text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                        bt.Text:SetText(AddTexture(tex))
                        if not BiaoGe.MONEYchoice[id] or BiaoGe.MONEYchoice[id] == 0 then
                            BiaoGe.MONEYchoice[id] = nil
                            bt:SetChecked(false)
                        else
                            BiaoGe.MONEYchoice[id] = 1
                            bt:SetChecked(true)
                        end
                        bt:SetScript("OnClick", function(self)
                            if self:GetChecked() then
                                BiaoGe.MONEYchoice[id] = 1
                            else
                                BiaoGe.MONEYchoice[id] = nil
                            end
                            BG.RefreshFBCDFrame()
                            BG.PlaySound(1)
                        end)
                        bt:SetScript("OnEnter", function(self)
                            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
                            GameTooltip:ClearLines()
                            GameTooltip:SetText("|cff" .. color
                                .. (itemType and (itemType:find('item') or itemType:find('equip')) and L['物品：'] or '')
                                .. name .. RR)
                        end)
                        bt:SetScript("OnLeave", GameTooltip_Hide)
                    end
                    lastFrame.height = buttonHeight * row + 5
                    lastFrame.child:SetHeight(lastFrame.height)
                    if hide then
                        lastFrame:GetScript("OnMouseDown")(lastFrame)
                    end
                end
                local function CreateTitle(name, color)
                    local frame = CreateFrame("Frame", nil, roleOverview, "BackdropTemplate")
                    frame:SetBackdrop({
                        bgFile = "Interface/ChatFrame/ChatFrameBackground",
                    })
                    frame:SetBackdropColor(0, 0, 0, 0)
                    if lastFrame then
                        frame:SetPoint("TOPLEFT", lastFrame.child, "BOTTOMLEFT", 0, 0)
                    else
                        frame:SetPoint("TOPLEFT", 15, -h)
                    end
                    frame:SetSize(frameWidth, frameHeight)
                    frame.name = name
                    tinsert(titles, frame)
                    frame.tex = frame:CreateTexture()
                    frame.tex:SetPoint("BOTTOMLEFT", 0, 0)
                    frame.tex:SetSize(18, 18)
                    frame.tex:SetTexture(130821)
                    frame.text = frame:CreateFontString()
                    frame.text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                    frame.text:SetPoint("LEFT", frame.tex, "RIGHT", 2, 0)
                    frame.text:SetText(name)
                    frame.open = true
                    if type(color) == "table" then
                        frame.text:SetTextColor(unpack(color))
                    else
                        frame.text:SetTextColor(RGB(color))
                    end
                    local l = frame:CreateLine()
                    l:SetColorTexture(.5, .5, .5)
                    l:SetStartPoint("BOTTOMLEFT", 0, 0)
                    l:SetEndPoint("BOTTOMLEFT", frameWidth, 0)
                    l:SetThickness(1.5)
                    local child = CreateFrame("Frame", nil, frame)
                    child:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, 0)
                    child:SetSize(frameWidth, 20)
                    frame.child = child
                    local child2 = CreateFrame("Frame", nil, child)
                    child2:SetAllPoints()
                    frame.child2 = child2
                    frame:SetScript("OnMouseDown", function(self, button)
                        if self.open then
                            self.child2:Hide()
                            self.child:SetHeight(1)
                            self.tex:SetTexture(130838)
                            self.open = nil
                            BiaoGe.options['roleOverviewTitleCollapse' .. name] = true
                        else
                            self.child2:Show()
                            self.child:SetHeight(self.height)
                            self.tex:SetTexture(130821)
                            self.open = true
                            BiaoGe.options['roleOverviewTitleCollapse' .. name] = nil
                        end
                        if button then
                            BG.PlaySound(1)
                        end
                    end)
                    frame:SetScript("OnEnter", function(self)
                        self:SetBackdropColor(1, 1, 0, .1)
                    end)
                    frame:SetScript("OnLeave", function(self)
                        self:SetBackdropColor(0, 0, 0, 0)
                    end)
                    return frame
                end
                if BG.IsVanilla_Sod then
                    local z = { 10, 3 } -- 3是专业
                    local x = {}
                    for i, v in ipairs(z) do
                        x[i] = (x[i - 1] or 0) + v
                    end
                    local startNum = 1
                    lastFrame = CreateTitle(L["团本"], "00BFFF")
                    CreateFBCDbutton(1, x[startNum])
                    lastFrame = CreateTitle(L["专业CD"], "ADFF2F")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
                elseif BG.IsVanilla_60 then
                    local z = { 7, BG.skillCount, #BG.factionTbl } -- 3是专业
                    local x = {}
                    for i, v in ipairs(z) do
                        x[i] = (x[i - 1] or 0) + v
                    end
                    local startNum = 1
                    lastFrame = CreateTitle(L["团本"], "00BFFF")
                    CreateFBCDbutton(1, x[startNum])
                    lastFrame = CreateTitle(L["专业CD"], "ADFF2F")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
                    startNum = startNum + 1
                    lastFrame = CreateTitle(L["声望"], "FFFF00")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
                elseif BG.IsTBC then
                    local z = { BG.FBCount, BG.dayQuestCount, #BG.factionTbl }
                    local x = {}
                    for i, v in ipairs(z) do
                        x[i] = (x[i - 1] or 0) + v
                    end
                    local startNum = 1
                    lastFrame = CreateTitle(L["团本"], "00BFFF")
                    CreateFBCDbutton(1, x[startNum])
                    lastFrame = CreateTitle(QUESTS_LABEL, "FF8C00")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
                    startNum = startNum + 1
                    lastFrame = CreateTitle(L["声望"], "FFFF00")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
                elseif BG.IsWLK_80 then
                    local z = { 18, 11, 5, 6, 10, #BG.factionTbl } -- 6是日常，10是专业
                    local x = {}
                    for i, v in ipairs(z) do
                        x[i] = (x[i - 1] or 0) + v
                    end
                    local startNum = 1
                    lastFrame = CreateTitle(EXPANSION_NAME2, "00BFFF")
                    CreateFBCDbutton(1, x[startNum])
                    lastFrame = CreateTitle(EXPANSION_NAME1, "FF69B4")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1], true)
                    startNum = startNum + 1
                    lastFrame = CreateTitle(LFG_LIST_LEGACY, "40c040")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1], true)
                    startNum = startNum + 1
                    lastFrame = CreateTitle(QUESTS_LABEL, "FF8C00")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
                    startNum = startNum + 1
                    lastFrame = CreateTitle(L["专业CD"], "ADFF2F")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
                    startNum = startNum + 1
                    lastFrame = CreateTitle(L["声望"], "FFFF00")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
                elseif BG.IsTitan then
                    local z = { BG.FBCount, BG.dayQuestCount, BG.skillCount, #BG.factionTbl }
                    local x = {}
                    for i, v in ipairs(z) do
                        x[i] = (x[i - 1] or 0) + v
                    end
                    local startNum = 1
                    lastFrame = CreateTitle(L["团本"], "00BFFF")
                    CreateFBCDbutton(1, x[startNum])
                    lastFrame = CreateTitle(QUESTS_LABEL, "FF8C00")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
                    startNum = startNum + 1
                    lastFrame = CreateTitle(L["专业CD"], "ADFF2F")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
                    startNum = startNum + 1
                    lastFrame = CreateTitle(L["声望"], "FFFF00")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
                elseif BG.IsCTM then
                    local z = { 7, 18, 11, 5, 3, #BG.factionTbl } -- 3是日常
                    local x = {}
                    for i, v in ipairs(z) do
                        x[i] = (x[i - 1] or 0) + v
                    end
                    local startNum = 1
                    lastFrame = CreateTitle(EXPANSION_NAME3, "FF4500")
                    CreateFBCDbutton(1, x[startNum])
                    lastFrame = CreateTitle(EXPANSION_NAME2, "00BFFF")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1], true)
                    startNum = startNum + 1
                    lastFrame = CreateTitle(EXPANSION_NAME1, "FF69B4")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1], true)
                    startNum = startNum + 1
                    lastFrame = CreateTitle(LFG_LIST_LEGACY, "40c040")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1], true)
                    startNum = startNum + 1
                    lastFrame = CreateTitle(QUESTS_LABEL, "FF8C00")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
                    startNum = startNum + 1
                    lastFrame = CreateTitle(L["声望"], "FFFF00")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
                elseif BG.IsMOP then
                    local z = { BG.FBCount, 7, 18, 11, 5, BG.dayQuestCount, BG.skillCount, #BG.factionTbl }
                    local x = {}
                    for i, v in ipairs(z) do
                        x[i] = (x[i - 1] or 0) + v
                    end
                    local startNum = 1
                    lastFrame = CreateTitle(EXPANSION_NAME4, "00FF00")
                    CreateFBCDbutton(1, x[startNum])
                    lastFrame = CreateTitle(EXPANSION_NAME3, "FF4500")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1], true)
                    startNum = startNum + 1
                    lastFrame = CreateTitle(EXPANSION_NAME2, "00BFFF")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1], true)
                    startNum = startNum + 1
                    lastFrame = CreateTitle(EXPANSION_NAME1, "FF69B4")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1], true)
                    startNum = startNum + 1
                    lastFrame = CreateTitle(LFG_LIST_LEGACY, "40c040")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1], true)
                    startNum = startNum + 1
                    lastFrame = CreateTitle(QUESTS_LABEL, "FF8C00")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
                    startNum = startNum + 1
                    lastFrame = CreateTitle(L["专业CD"], "ADFF2F")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
                    startNum = startNum + 1
                    lastFrame = CreateTitle(L["声望"], "FFFF00")
                    CreateFBCDbutton(x[startNum] + 1, x[startNum + 1])
                elseif BG.IsRetail then
                    local z = { BG.FBCount, }
                    local x = {}
                    for i, v in ipairs(z) do
                        x[i] = (x[i - 1] or 0) + v
                    end
                    local startNum = 1
                    lastFrame = CreateTitle(L["团本"], "00BFFF")
                    CreateFBCDbutton(1, x[startNum])
                end
                if not BG.IsRetail then
                    lastFrame = CreateTitle(L["专业技能点"], BG.SKILLall_table[1].color)
                    CreateFBCDbutton(1, #BG.SKILLall_table, nil, "SKILLall_table", "SKILLchoice")
                end
                lastFrame = CreateTitle(L["货币"], "FFFFFF")
                CreateMONEYbutton(1, #BG.MONEYall_table)

                for i, title in ipairs(titles) do
                    if BiaoGe.options['roleOverviewTitleCollapse' .. title.name] and title.open then
                        title:GetScript("OnMouseDown")(title)
                    end
                end
            end

            -- 排序
            do
                local name = "roleOverviewSort1"
                BG.options[name .. "reset"] = "iLevel-class-player"
                BiaoGe.options[name] = BiaoGe.options[name] or BG.options[name .. "reset"]
                if BiaoGe.options[name] == "iLevel-player-class" then
                    BiaoGe.options[name] = "iLevel-player"
                elseif BiaoGe.options[name] == "class-player-iLevel" then
                    BiaoGe.options[name] = "class-player"
                elseif BiaoGe.options[name] == "player-iLevel-class" then
                    BiaoGe.options[name] = "player"
                elseif BiaoGe.options[name] == "player-class-iLevel" then
                    BiaoGe.options[name] = "player"
                end
                local tbl = {
                    { key = "iLevel-class-player", text = L["装等-职业-名字"] },
                    { key = "class-iLevel-player", text = L["职业-装等-名字"] },
                    { key = "iLevel-player", text = L["装等-名字"] },
                    { key = "class-player", text = L["职业-名字"] },
                    { key = "player", text = L["名字"] },
                    { key = "custom", text = L["自定义排序"] },
                }

                local frame = CreateFrame("Frame", nil, roleOverview, "BackdropTemplate")
                frame:SetPoint("TOPLEFT", lastFrame.child, "BOTTOMLEFT", 0, -15)
                frame:SetSize(frameWidth, frameHeight)
                lastFrame = frame
                local t = frame:CreateFontString()
                t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                t:SetPoint("LEFT")
                t:SetTextColor(1, 1, 1)
                t:SetText(L["角色总览的排序方式："])
                BG.options["Text" .. name] = t

                -- 选项
                BG.Init2(function()
                    local function SetText(key)
                        for i, v in ipairs(tbl) do
                            if v.key == key then
                                return v.text
                            end
                        end
                    end

                    local dropDown = LibBG:Create_UIDropDownMenu(nil, roleOverview)
                    dropDown:SetPoint("LEFT", BG.options["Text" .. name], "RIGHT", -10, -2)
                    LibBG:UIDropDownMenu_SetWidth(dropDown, 150)
                    LibBG:UIDropDownMenu_SetText(dropDown, SetText(BiaoGe.options[name]))
                    LibBG:UIDropDownMenu_SetAnchor(dropDown, 0, 0, "TOP", dropDown, "BOTTOM")
                    BG.dropDownToggle(dropDown)
                    BG.options["button" .. name] = dropDown

                    LibBG:UIDropDownMenu_Initialize(dropDown, function(self, level)
                        for i, v in ipairs(tbl) do
                            local info = LibBG:UIDropDownMenu_CreateInfo()
                            info.text = v.text
                            info.func = function()
                                if v.key == "custom" and BG.InitializeRoleOverviewCustomSort then
                                    BG.InitializeRoleOverviewCustomSort()
                                end
                                BiaoGe.options[name] = v.key
                                LibBG:UIDropDownMenu_SetText(dropDown, SetText(BiaoGe.options[name]))
                                if BiaoGe.options[name] ~= "custom" then
                                    if BG.RoleOverviewSortFrame and BG.RoleOverviewSortFrame:IsVisible() then
                                        BG.RoleOverviewSortFrame:Hide()
                                    end
                                end
                                dropDown.bt:SetShown(BiaoGe.options[name] == "custom")
                                BG.RefreshFBCDFrame()
                            end
                            if BiaoGe.options[name] == v.key then
                                info.checked = true
                            end
                            LibBG:UIDropDownMenu_AddButton(info)
                        end
                    end)

                    dropDown.bt = BG.CreateButton(dropDown)
                    dropDown.bt:SetSize(100, 25)
                    dropDown.bt:SetPoint("LEFT", dropDown, "RIGHT", 0, 3)
                    dropDown.bt:SetText(L["修改排序"])
                    dropDown.bt:SetShown(BiaoGe.options[name] == "custom")
                    dropDown.bt:SetScript("OnClick", function(self)
                        BG.PlaySound(1)
                        if BG.RoleOverviewSortFrame and BG.RoleOverviewSortFrame:IsVisible() then
                            BG.RoleOverviewSortFrame:Hide()
                        else
                            BG.CreateRoleOverviewSortFrame(self)
                        end
                    end)
                end)
            end

            -- 默认显示
            do
                local name = "roleOverviewDefaultShow"
                BG.options[name .. "reset"] = "one"
                BiaoGe.options[name] = BiaoGe.options[name] or BG.options[name .. "reset"]

                local tbl = {
                    { key = "one", text = L["当前服务器角色"] },
                    { key = "all", text = L["全部服务器角色"] },
                }

                local frame = CreateFrame("Frame", nil, roleOverview, "BackdropTemplate")
                frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -10)
                frame:SetSize(frameWidth, frameHeight)
                lastFrame = frame
                local t = frame:CreateFontString()
                t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                t:SetPoint("LEFT")
                t:SetTextColor(1, 1, 1)
                t:SetText(L["角色总览的默认显示："])
                BG.options["Text" .. name] = t
                -- 选项
                do
                    local function SetText(key)
                        for i, v in ipairs(tbl) do
                            if v.key == key then
                                return v.text
                            end
                        end
                    end

                    local dropDown = LibBG:Create_UIDropDownMenu(nil, roleOverview)
                    dropDown:SetPoint("LEFT", BG.options["Text" .. name], "RIGHT", -10, -2)
                    LibBG:UIDropDownMenu_SetWidth(dropDown, 150)
                    LibBG:UIDropDownMenu_SetText(dropDown, SetText(BiaoGe.options[name]))
                    LibBG:UIDropDownMenu_SetAnchor(dropDown, 0, 0, "TOP", dropDown, "BOTTOM")
                    BG.dropDownToggle(dropDown)
                    BG.options["button" .. name] = dropDown

                    LibBG:UIDropDownMenu_Initialize(dropDown, function(self, level)
                        for i, v in ipairs(tbl) do
                            local info = LibBG:UIDropDownMenu_CreateInfo()
                            info.text = v.text
                            info.func = function()
                                BiaoGe.options[name] = v.key
                                LibBG:UIDropDownMenu_SetText(dropDown, SetText(BiaoGe.options[name]))
                                BG.RefreshFBCDFrame()
                            end
                            if BiaoGe.options[name] == v.key then
                                info.checked = true
                            end
                            LibBG:UIDropDownMenu_AddButton(info)
                        end
                    end)
                end
            end

            -- 布局
            do
                local name = "roleOverviewLayout"
                if BG.IsRetail then
                    BG.options[name .. "reset"] = "new"
                else
                    BG.options[name .. "reset"] = "up_down"
                end
                BiaoGe.options[name] = BiaoGe.options[name] or BG.options[name .. "reset"]

                local tbl = {
                    { key = "up_down", text = L["横向布局1"] },
                    { key = "left_right", text = L["横向布局2"] },
                    { key = "new", text = L["竖向布局"] },
                }

                local frame = CreateFrame("Frame", nil, roleOverview, "BackdropTemplate")
                frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -10)
                frame:SetSize(frameWidth, frameHeight)
                lastFrame = frame
                local t = frame:CreateFontString()
                t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                t:SetPoint("LEFT")
                t:SetTextColor(1, 1, 1)
                t:SetText(L["角色总览的布局方式："])
                BG.options["Text" .. name] = t
                -- 选项
                do
                    local function SetText(key)
                        for i, v in ipairs(tbl) do
                            if v.key == key then
                                return v.text
                            end
                        end
                    end

                    local dropDown = LibBG:Create_UIDropDownMenu(nil, roleOverview)
                    dropDown:SetPoint("LEFT", BG.options["Text" .. name], "RIGHT", -10, -2)
                    LibBG:UIDropDownMenu_SetWidth(dropDown, 150)
                    LibBG:UIDropDownMenu_SetText(dropDown, SetText(BiaoGe.options[name]))
                    LibBG:UIDropDownMenu_SetAnchor(dropDown, 0, 0, "TOP", dropDown, "BOTTOM")
                    BG.dropDownToggle(dropDown)
                    BG.options["button" .. name] = dropDown

                    LibBG:UIDropDownMenu_Initialize(dropDown, function(self, level)
                        for i, v in ipairs(tbl) do
                            local info = LibBG:UIDropDownMenu_CreateInfo()
                            info.text = v.text
                            info.func = function()
                                BiaoGe.options[name] = v.key
                                LibBG:UIDropDownMenu_SetText(dropDown, SetText(BiaoGe.options[name]))
                                BG.RefreshFBCDFrame()
                            end
                            if BiaoGe.options[name] == v.key then
                                info.checked = true
                            end
                            LibBG:UIDropDownMenu_AddButton(info)
                        end
                    end)
                end
            end

            -- 屏蔽等级
            do
                local name = "roleOverviewNotShowLevel"
                BG.options[name .. "reset"] = 0
                BiaoGe.options[name] = BiaoGe.options[name] or BG.options[name .. "reset"]

                local frame = CreateFrame("Frame", nil, roleOverview, "BackdropTemplate")
                frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -10)
                frame:SetSize(frameWidth, frameHeight)
                lastFrame = frame
                local t = frame:CreateFontString()
                t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                t:SetPoint("LEFT")
                t:SetTextColor(1, 1, 1)
                t:SetText(L["仅显示高于该等级的角色："])

                local edit = CreateFrame("EditBox", nil, roleOverview, BG.editTemplate)
                edit:SetSize(50, 20)
                edit:SetPoint("LEFT", t, "RIGHT", 10, 0)
                edit:SetText(BiaoGe.options[name] or 0)
                edit:SetAutoFocus(false)
                edit:SetNumeric(true)
                BG.SetEditBaseClass(edit)
                edit:SetScript("OnTextChanged", function(self)
                    BiaoGe.options[name] = tonumber(self:GetText()) or 0
                end)
            end

            -- 屏蔽装等
            do
                local name = "roleOverviewNotShowiLevel"
                BG.options[name .. "reset"] = 0
                BiaoGe.options[name] = BiaoGe.options[name] or BG.options[name .. "reset"]

                local frame = CreateFrame("Frame", nil, roleOverview, "BackdropTemplate")
                frame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -10)
                frame:SetSize(frameWidth, frameHeight)
                lastFrame = frame
                local t = frame:CreateFontString()
                t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                t:SetPoint("LEFT")
                t:SetTextColor(1, 1, 1)
                t:SetText(L["仅显示高于该装等的角色："])

                local edit = CreateFrame("EditBox", nil, roleOverview, BG.editTemplate)
                edit:SetSize(50, 20)
                edit:SetPoint("LEFT", t, "RIGHT", 10, 0)
                edit:SetText(BiaoGe.options[name] or 0)
                edit:SetAutoFocus(false)
                edit:SetNumeric(true)
                BG.SetEditBaseClass(edit)
                edit:SetScript("OnTextChanged", function(self)
                    BiaoGe.options[name] = tonumber(self:GetText()) or 0
                end)
            end

            -- 团本CD显示为BOSS击杀数量
            do
                local name = "showRaidCDKillNum"
                BG.options[name .. "reset"] = BG.IsRetail and 1 or 0
                BiaoGe.options[name] = BiaoGe.options[name] or BG.options[name .. "reset"]
                local ontext = {
                    L["团本CD显示为BOSS击杀数量"],
                    L["没全通的副本，现在会显示击杀的BOSS数量，而不是显示一个绿色钩子。"],
                }
                local f = O.CreateCheckButton(name, L["团本CD显示为BOSS击杀数量"], roleOverview, 15, 0, ontext, true, { BG.RefreshFBCDFrame })
                f:ClearAllPoints()
                f:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, -10)
                BG.options["button" .. name] = f
                lastFrame = f
            end

            -- 显示牌子总上限
            if BG.IsMOP then
                local name = "showCurrencyTop"
                local ontext = {
                    L["显示牌子总上限"],
                    L["像勇气点数、征服点数有总上限的牌子，在角色总览里会显示其总上限。"],
                }
                local f = O.CreateCheckButton(name, L["显示牌子总上限"] .. L["（需重载）"], roleOverview, 15, 0, ontext, true, { BG.RefreshFBCDFrame })
                f:ClearAllPoints()
                f:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0)
                BG.options["button" .. name] = f
                lastFrame = f
            end

            -- 显示其他装备部位
            do
                local name = "roleOverviewShowOtherEquip"
                BiaoGe.options[name] = BiaoGe.options[name] or 0
                local choiceName = "roleOverviewOtherEquipSlots"
                if type(BiaoGe.options[choiceName]) ~= "table" then
                    BiaoGe.options[choiceName] = {}
                end
                local ontext = {
                    L["显示其他装备部位"],
                    L["在饰品后面增加显示其他装备部位。"],
                }
                local f = O.CreateCheckButton(name, AddTexture('QUEST') .. L["显示其他装备部位"], roleOverview, 15, 0, ontext, true, { BG.RefreshFBCDFrame })
                f:ClearAllPoints()
                f:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0)
                BG.options["button" .. name] = f
                lastFrame = f

                local chooseBT = BG.CreateButton(f)
                chooseBT:SetSize(120, 22)
                chooseBT:SetPoint("LEFT", f.Text, "RIGHT", 0, 0)
                SetParent(chooseBT, name)

                local function UpdateChooseButtonText()
                    local count = 0
                    for _, equipInfo in ipairs(BG.RoleOverviewOtherEquipSlots) do
                        if BiaoGe.options[choiceName][equipInfo.id] == 1 then
                            count = count + 1
                        end
                    end
                    local color = count == 0 and "808080" or "00ff00"
                    chooseBT:SetText(format("%s(|cff%s%d|r)", L["选择部位"], color, count))
                end
                UpdateChooseButtonText()

                local chooseFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
                chooseFrame:SetPoint("TOPLEFT", chooseBT, "BOTTOMLEFT", 0, -5)
                chooseFrame:SetSize(230, 195)
                chooseFrame:SetFrameStrata("DIALOG")
                chooseFrame:SetClampedToScreen(true)
                chooseFrame:SetBackdrop({
                    bgFile = "Interface/ChatFrame/ChatFrameBackground",
                    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
                    edgeSize = 16,
                    insets = { left = 3, right = 3, top = 3, bottom = 3 },
                })
                chooseFrame:SetBackdropColor(0, 0, 0, .95)
                chooseFrame:SetBackdropBorderColor(.5, .5, .5)
                chooseFrame:Hide()

                local closeBT = CreateFrame("Button", nil, chooseFrame, "UIPanelCloseButton")
                closeBT:SetPoint("TOPRIGHT", 2, 2)

                local title = chooseFrame:CreateFontString()
                title:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                title:SetPoint("TOP", 0, -7)
                title:SetText(L["显示其他装备部位"])
                title:SetTextColor(1, 1, 1)

                for i, equipInfo in ipairs(BG.RoleOverviewOtherEquipSlots) do
                    local bt = CreateFrame("CheckButton", nil, chooseFrame, "ChatConfigCheckButtonTemplate")
                    local column = floor((i - 1) / 6)
                    local row = (i - 1) % 6
                    bt:SetPoint("TOPLEFT", 10 + column * 110, -30 - row * 25)
                    bt:SetSize(25, 25)
                    bt.Text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                    bt.Text:SetText(equipInfo.name)
                    bt.Text:SetTextColor(1, .82, 0)
                    bt:SetHitRectInsets(0, -75, 0, 0)
                    bt:SetChecked(BiaoGe.options[choiceName][equipInfo.id] == 1)
                    bt:SetScript("OnClick", function(self)
                        if self:GetChecked() then
                            BiaoGe.options[choiceName][equipInfo.id] = 1
                        else
                            BiaoGe.options[choiceName][equipInfo.id] = nil
                        end
                        UpdateChooseButtonText()
                        BG.RefreshFBCDFrame()
                        BG.PlaySound(1)
                    end)
                end

                chooseBT:SetScript("OnClick", function()
                    BG.PlaySound(1)
                    chooseFrame:SetShown(not chooseFrame:IsShown())
                end)
                chooseBT:HookScript("OnHide", function()
                    chooseFrame:Hide()
                end)
            end

            -- 备注
            do
                local name = "roleOverviewShowNote"
                BiaoGe.options[name] = BiaoGe.options[name] or 0
                local ontext = {
                    L["显示角色备注"],
                    L["在角色名字后面，增加显示一段自定义文本。"],
                    " ",
                    L["使用方法：/bgp ro，把角色总览面板固定，然后鼠标点击角色对应的备注栏即可修改备注。"]
                }
                local f = O.CreateCheckButton(name, L["显示角色备注"], roleOverview, 15, 0, ontext, true, { BG.RefreshFBCDFrame })
                f:ClearAllPoints()
                f:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0)
                BG.options["button" .. name] = f
                lastFrame = f

                local t = f:CreateFontString()
                t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                t:SetPoint("LEFT", f.Text, "RIGHT", 10, 0)
                t:SetTextColor(1, 1, 1)
                t:SetText(L["文本宽度："])
                SetParent(t, "roleOverviewShowNote")

                local miniWidth = 60
                local name2 = "roleOverviewShowNote_width"
                BiaoGe.options[name2] = BiaoGe.options[name2] or 100
                local edit = CreateFrame("EditBox", nil, f, BG.editTemplate)
                edit:SetSize(100, 20)
                edit:SetPoint("LEFT", t, "RIGHT", 5, 0)
                edit:SetText(BiaoGe.options[name2])
                edit:SetAutoFocus(false)
                edit:SetNumeric(true)
                BG.SetEditBaseClass(edit)
                SetParent(edit, "roleOverviewShowNote")
                edit:SetScript("OnTextChanged", function(self)
                    BiaoGe.options[name2] = max(miniWidth, tonumber(self:GetText()) or 0)
                end)

                local t = f:CreateFontString()
                t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                t:SetPoint("LEFT", edit, "RIGHT", 20, 0)
                t:SetTextColor(1, 1, 1)
                t:SetText(L["文本使用职业颜色："])
                SetParent(t, "roleOverviewShowNote")

                local name3 = "roleOverviewShowNote_useClassColor"
                BiaoGe.options[name3] = BiaoGe.options[name3] or 1
                local buttons = {}
                local numOptions = {
                    { name = L["是"], key = 1, },
                    { name = L["否"], key = 0, },
                }
                for i = 1, #numOptions do
                    local bt = CreateFrame("CheckButton", nil, f, "UIRadioButtonTemplate")
                    bt:SetPoint("LEFT", t, "RIGHT", (i - 1) * 40 + 2, -1)
                    bt:SetSize(15, 15)
                    SetParent(bt, "roleOverviewShowNote")
                    tinsert(buttons, bt)
                    bt.Text = bt:CreateFontString()
                    bt.Text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                    bt.Text:SetPoint("LEFT", bt, "RIGHT", 0, 0)
                    bt.Text:SetText(numOptions[i].name)
                    bt.Text:SetTextColor(1, .82, 0)
                    bt:SetHitRectInsets(0, -bt.Text:GetWidth(), -5, -5)
                    if numOptions[i].key == BiaoGe.options[name3] then
                        bt:SetChecked(true)
                        bt.Text:SetTextColor(0, 1, 0)
                    end
                    bt:SetScript("OnClick", function(self)
                        BG.PlaySound(1)
                        for _, radioButton in ipairs(buttons) do
                            if radioButton ~= self then
                                radioButton:SetChecked(false)
                                radioButton.Text:SetTextColor(1, .82, 0)
                            end
                        end
                        self:SetChecked(true)
                        self.Text:SetTextColor(0, 1, 0)
                        BiaoGe.options.roleOverviewShowNote_useClassColor = numOptions[i].key
                    end)
                end
            end

            -- 显示专精图标
            do
                local name = "roleOverviewShowTalent"
                BiaoGe.options[name] = BiaoGe.options[name] or 1
                local ontext = {
                    L["显示角色专精"],
                    L["在角色名字前面增加显示专精图标。"],
                }
                local f = O.CreateCheckButton(name, L["显示角色专精"], roleOverview, 15, 0, ontext, true, { BG.RefreshFBCDFrame })
                f:ClearAllPoints()
                f:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0)
                BG.options["button" .. name] = f
                lastFrame = f
            end

            -- 显示阵营
            do
                local name = "roleOverviewShowFaction"
                BiaoGe.options[name] = BiaoGe.options[name] or 0
                local ontext = {
                    L["显示角色阵营"],
                    L["角色装等和等级会根据阵营染色为浅蓝色（联盟）或浅红色（部落），用来区分该角色是哪个阵营。"],
                }
                local f = O.CreateCheckButton(name, L["显示角色阵营"], roleOverview, 15, 0, ontext, true, { BG.RefreshFBCDFrame })
                f:ClearAllPoints()
                f:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0)
                BG.options["button" .. name] = f
                lastFrame = f
            end

            -- 使用黑白着色
            do
                local name = "roleOverviewblackWhite"
                BiaoGe.options[name] = BiaoGe.options[name] or 0
                local ontext = {
                    L["使用黑白着色"],
                    L["勾选后每行使用黑白着色。否则使用下横线作分割。该选项仅对横向布局有效。"],
                }
                local f = O.CreateCheckButton(name, L["使用黑白着色"], roleOverview, 15, 0, ontext, true, { BG.RefreshFBCDFrame })
                f:ClearAllPoints()
                f:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0)
                BG.options["button" .. name] = f
                lastFrame = f
            end
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

local OPTIONS_UI_VER = 3

local function InstallPlusOptionsTabs()
    if ns.EnsureOptionsUI then
        ns.EnsureOptionsUI()
    end
    if not BG.OptionsCreateTab or not ns.O or not ns.O.CreateSlider then
        return false
    end

    if not BG.ButtonOptions_roleOverview then
        local roleOverview = BG.OptionsCreateTab("Options_roleOverview", L["角色总览"])
        local wishlist = BG.OptionsCreateTab("Options_wishlist", L["心愿清单"])
        BG.BGP_RoleOverviewOptionsFrame = roleOverview
        BG.BGP_WishlistOptionsFrame = wishlist
        BuildRoleOverviewTab(roleOverview)
        BuildWishlistTab(wishlist)
        BG.BGP_RoleOverviewOptionsVer = OPTIONS_UI_VER
        return BG.ButtonOptions_roleOverview ~= nil
    end

    if BG.BGP_RoleOverviewOptionsVer == OPTIONS_UI_VER then
        return true
    end

    local roleOverview = BG.BGP_RoleOverviewOptionsFrame
    local wishlist = BG.BGP_WishlistOptionsFrame
    if not roleOverview then
        local content, scroll = GetOptionsScrollChild("Options_roleOverview")
        if content then
            content.scroll = content.scroll or scroll
            roleOverview = content
        end
    end
    if not wishlist then
        local content, scroll = GetOptionsScrollChild("Options_wishlist")
        if content then
            content.scroll = content.scroll or scroll
            wishlist = content
        end
    end
    if roleOverview then
        BG.BGP_RoleOverviewOptionsFrame = roleOverview
        BuildRoleOverviewTab(roleOverview)
    end
    if wishlist then
        BG.BGP_WishlistOptionsFrame = wishlist
        ClearFrameChildren(wishlist)
        BuildWishlistTab(wishlist)
    end
    BG.BGP_RoleOverviewOptionsVer = OPTIONS_UI_VER
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
