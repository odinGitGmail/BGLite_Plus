local _, ns = ...
local L = ns.L
local RGB = ns.RGB

-- BGLite 的 Options 控件工厂在 BGLite 自己的 ns.O 上，Plus 的 ns 拿不到。
-- 这里提供兼容的 O，用于往 BGLite 设置里挂「角色总览 / 心愿清单」页。
local function EnsureOptionsUI()
    if ns.O and ns.O.CreateSlider and ns.O.CreateCheckButton then
        return ns.O
    end

    local O = ns.O or {}
    ns.O = O

    if not O.CreateSlider then
        local function updateSliderEditBox(self)
            local slider = self.__owner
            local minValue, maxValue = slider:GetMinMaxValues()
            local text = tonumber(self:GetText())
            if not text then return end
            text = min(maxValue, text)
            text = max(minValue, text)
            slider:SetValue(text)
            self:SetText(text)
            BiaoGe.options[slider.name] = text
            self:ClearFocus()
            if BG.PlaySound then BG.PlaySound(1) end
        end
        local function OnValueChanged(self, value)
            self.edit:ClearFocus()
            value = tonumber(value)
            BiaoGe.options[self.name] = value
            self.edit:SetText(value)
        end
        local function OnClick(self, enter)
            local slider = self.__owner
            if enter == "RightButton" and BG.options[slider.name .. "reset"] then
                local value = BG.options[slider.name .. "reset"]
                BiaoGe.options[slider.name] = value
                slider:SetValue(value)
                slider.edit:SetText(value)
                if BG.PlaySound then BG.PlaySound(1) end
            end
        end
        local function OnEnter(self)
            local slider = self.__owner
            if not slider.ontext then return end
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 5)
            GameTooltip:ClearLines()
            if type(slider.ontext) == "table" then
                for i, text in ipairs(slider.ontext) do
                    if i == 1 then
                        GameTooltip:AddLine(text, 1, 1, 1, true)
                    else
                        GameTooltip:AddLine(text, 1, 0.82, 0, true)
                    end
                end
            else
                GameTooltip:SetText(slider.ontext)
            end
            GameTooltip:Show()
        end
        local function OnLeave()
            GameTooltip:Hide()
        end

        function O.CreateSlider(name, text, parent, minValue, maxValue, step, x, y, ontext, width)
            BiaoGe.options = BiaoGe.options or {}
            local savedValue = tonumber(BiaoGe.options[name]) or minValue
            local value = min(maxValue, savedValue)
            value = max(minValue, value)
            BiaoGe.options[name] = value

            local template = BG.IsWLK_80 and "TextToSpeechSliderTemplate" or "OptionsSliderTemplate"
            local slider = CreateFrame("Slider", nil, parent, template)
            slider:SetPoint("TOPLEFT", parent, x, y)
            slider:SetWidth(width or 180)
            slider:SetMinMaxValues(minValue, maxValue)
            slider:SetValueStep(step)
            slider:SetObeyStepOnDrag(true)
            slider:SetHitRectInsets(0, 0, 0, 0)
            slider:SetValue(BiaoGe.options[name])
            slider.name = name
            slider.ontext = ontext
            slider:SetScript("OnValueChanged", OnValueChanged)

            if slider.Low then
                slider.Low:SetFont(BIAOGE_TEXT_FONT, 14, "OUTLINE")
                slider.Low:SetText(minValue)
                slider.Low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 10, -2)
            end
            if slider.High then
                slider.High:SetFont(BIAOGE_TEXT_FONT, 14, "OUTLINE")
                slider.High:SetText(maxValue)
                slider.High:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", -10, -2)
            end
            if slider.Text then
                slider.Text:SetFont(BIAOGE_TEXT_FONT, 14, "OUTLINE")
                slider.Text:ClearAllPoints()
                slider.Text:SetPoint("CENTER", 0, 25)
                slider.Text:SetText(text)
                slider.Text:SetTextColor(1, .8, 0)
                slider.Text:SetSize(slider:GetWidth(), 40)
            end

            slider.edit = CreateFrame("EditBox", nil, slider, BG.editTemplate or "InputBoxTemplate")
            slider.edit:SetSize(50, 20)
            slider.edit:SetPoint("TOP", slider, "BOTTOM")
            slider.edit:SetJustifyH("CENTER")
            slider.edit:SetAutoFocus(false)
            slider.edit:SetText(BiaoGe.options[name])
            slider.edit:SetCursorPosition(0)
            slider.edit.__owner = slider
            slider.edit:SetScript("OnEnterPressed", updateSliderEditBox)
            slider.edit:SetScript("OnEditFocusLost", updateSliderEditBox)

            slider.button = CreateFrame("Button", nil, slider)
            if slider.Text then
                slider.button:SetAllPoints(slider.Text)
            else
                slider.button:SetSize(slider:GetWidth(), 20)
                slider.button:SetPoint("BOTTOM", slider, "TOP", 0, 0)
            end
            slider.button:RegisterForClicks("RightButtonUp")
            slider.button.__owner = slider
            slider.button:SetScript("OnClick", OnClick)
            slider.button:SetScript("OnEnter", OnEnter)
            slider.button:SetScript("OnLeave", OnLeave)
            return slider
        end
    end

    if not O.CreateCheckButton then
        local function OnClick(self)
            BiaoGe.options[self.name] = self:GetChecked() and 1 or 0
            if self.callback then
                local func, arg1, arg2, arg3, arg4, arg5 = unpack(self.callback)
                func(arg1, arg2, arg3, arg4, arg5)
            end
            if BG.PlaySound then BG.PlaySound(1) end
        end
        local function OnEnter(self)
            if not self.ontext then return end
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            if type(self.ontext) == "table" then
                for i, text in ipairs(self.ontext) do
                    if i == 1 then
                        GameTooltip:AddLine(text, 1, 1, 1, true)
                    else
                        GameTooltip:AddLine(text, 1, 0.82, 0, true)
                    end
                end
            else
                GameTooltip:SetText(self.ontext)
            end
            GameTooltip:Show()
        end
        function O.CreateCheckButton(name, text, parent, x, y, ontext, long, callback)
            BiaoGe.options = BiaoGe.options or {}
            local bt = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
            bt:SetSize(30, 30)
            bt:SetPoint("TOPLEFT", parent, x, y)
            bt.Text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            bt.Text:SetText(text)
            bt.Text:SetWordWrap(false)
            bt.Text:SetWidth(min(bt.Text:GetStringWidth() + 20, (type(long) == "number" and long) or (long and 500 or 160)))
            bt:SetHitRectInsets(0, -bt.Text:GetWidth(), 0, 0)
            bt.name = name
            bt.ontext = ontext
            bt.callback = callback
            BG.options = BG.options or {}
            BG.options["button" .. name] = bt
            bt:SetChecked(BiaoGe.options[name] == 1)
            bt:SetScript("OnClick", OnClick)
            bt:SetScript("OnEnter", OnEnter)
            bt:SetScript("OnLeave", function() GameTooltip:Hide() end)
            bt:SetScript("OnShow", function(self)
                self:SetChecked(BiaoGe.options[self.name] == 1)
            end)
            return bt
        end
    end

    if not O.CreateLine then
        function O.CreateLine(parent, y, height)
            local l = parent:CreateLine()
            l:SetColorTexture(RGB("808080", 1))
            local right = 600
            if SettingsPanel and SettingsPanel.Container then
                right = SettingsPanel.Container:GetWidth() - 20
            end
            l:SetStartPoint("TOPLEFT", 5, y)
            l:SetEndPoint("TOPLEFT", right, y)
            l:SetThickness(height or 1.5)
            return l
        end
    end

    if not O.CreateBindKey then
        function O.CreateBindKey(parent, x, y, wdith, bindKey, name)
            local bt = BG.CreateButton(parent)
            bt:SetSize(wdith or 150, 25)
            bt:SetPoint("TOPLEFT", x, y)
            bt.bindKey = bindKey
            bt:SetScript("OnClick", function()
                if not SettingsPanel then return end
                for _, v in pairs(SettingsPanel:GetAllCategories()) do
                    if v.name == SETTINGS_KEYBINDINGS_LABEL then
                        SettingsPanel:SelectCategory(v)
                        break
                    end
                end
            end)
            bt:SetScript("OnShow", function(self)
                local key1, key2 = GetBindingKey(self.bindKey)
                self:SetText(key1 or key2 or (L["无"] or "无"))
            end)
            local t = bt:CreateFontString()
            t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            t:SetPoint("BOTTOM", bt, "TOP", 0, 5)
            t:SetText(name)
            return bt
        end
    end

    return O
end

ns.EnsureOptionsUI = EnsureOptionsUI
EnsureOptionsUI()
