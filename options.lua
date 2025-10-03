---@diagnostic disable: duplicate-set-field
----------------------------------------------------------
--                                                      --
--   options.lua                                        --
--   Configuration and interface options panel.         --
--                                                      --
----------------------------------------------------------

FindA.Options.InitInterfaceOptions = function()
    FindA.Options.panel = CreateFrame("Frame", "FindA_Options_Panel")
    FindA.Options.panel.name = "FindA"
    FindA.Options.panel.checkboxes = {}
    FindA.Options.panel.marker_selection = {}

    FindA.Options.panel.main_title = FindA.Helpers.CreateFontString(FindA.Options.panel, "FindA", 0, 0)
    FindA.Options.panel.main_title : SetFont(FindA.Options.panel.main_title:GetFont(), 64)
    FindA.Options.panel.main_title : ClearAllPoints()
    FindA.Options.panel.main_title : SetPoint("TOP", 0, -32)

    FindA.Options.panel.sub_title = FindA.Helpers.CreateFontString(FindA.Options.panel, "Options", 0, 0)
    FindA.Options.panel.sub_title : SetFont(FindA.Options.panel.sub_title:GetFont(), 32)
    FindA.Options.panel.sub_title : ClearAllPoints()
    FindA.Options.panel.sub_title : SetPoint("TOP", 0, -112)

    FindA.Options.panel.background_texture = FindA.Options.panel:CreateTexture(nil, "BACKGROUND")
    FindA.Options.panel.background_texture : SetAllPoints()
    FindA.Options.panel.background_texture : SetTexture("Interface\\GLUES\\Models\\UI_MainMenu\\swordgradient2")
    FindA.Options.panel.background_texture : SetAlpha(0.2)
    FindA.Options.panel.background_texture : SetTexCoord(0, 1, 1, 0)

    FindA.Options.panel.checkboxes.show_chat_messages = CreateFrame("CheckButton", "FindA_Options_Panel_ShowChatMessagesCheckbox", FindA.Options.panel, "InterfaceOptionsCheckButtonTemplate")
    FindA.Options.panel.checkboxes.show_chat_messages : SetPoint("CENTER", -250, 50)
    getglobal(FindA.Options.panel.checkboxes.show_chat_messages:GetName().."Text"):SetText("Show chat messages")
    FindA.Options.panel.checkboxes.show_chat_messages.IsChecked = function(self)
        if self:GetChecked() then return true end
        return false
    end

    FindA.Options.panel.checkboxes.always_hide_macro_button = CreateFrame("CheckButton", "FindA_Options_Panel_AlwaysHideMacroButtonCheckbox", FindA.Options.panel, "InterfaceOptionsCheckButtonTemplate")
    FindA.Options.panel.checkboxes.always_hide_macro_button : SetPoint("CENTER", -250, 0)
    getglobal(FindA.Options.panel.checkboxes.always_hide_macro_button:GetName().."Text"):SetText("Always hide the macro button")
    FindA.Options.panel.checkboxes.always_hide_macro_button.IsChecked = function(self)
        if self:GetChecked() then return true end
        return false
    end

    FindA.Options.panel.checkboxes.remember_finding = CreateFrame("CheckButton", "FindA_Options_Panel_RememberFindingCheckbox", FindA.Options.panel, "InterfaceOptionsCheckButtonTemplate")
    FindA.Options.panel.checkboxes.remember_finding : SetPoint("CENTER", -250, -250)
    getglobal(FindA.Options.panel.checkboxes.remember_finding:GetName().."Text"):SetText("Remember FindA search between reloads")
    FindA.Options.panel.checkboxes.remember_finding.IsChecked = function(self)
        if self:GetChecked() then return true end
        return false
    end

    FindA.Options.panel.marker_selection.text = FindA.Helpers.CreateFontString(FindA.Options.panel, "Marker Selection", 0, 0)
    FindA.Options.panel.marker_selection.text : SetFont(FindA.Options.panel.marker_selection.text:GetFont(), 12)
    FindA.Options.panel.marker_selection.text : ClearAllPoints()
    FindA.Options.panel.marker_selection.text : SetPoint("TOP", -200, -330)

    FindA.Options.panel.marker_selection.menu = CreateFrame("Frame", "FindA_Options_Panel_MarkerSelectionMenu", FindA.Options.panel, "UIDropDownMenuTemplate")
    FindA.Options.panel.marker_selection.menu : SetPoint("CENTER", -200, -75)
    UIDropDownMenu_SetWidth(FindA.Options.panel.marker_selection.menu, 100)
    UIDropDownMenu_SetText(FindA.Options.panel.marker_selection.menu, FindA.Constants.markers[FindA.marker].name)
    UIDropDownMenu_JustifyText(FindA.Options.panel.marker_selection.menu, "LEFT")


    if FindA.chat_msg_enable == 1 then
        FindA.Options.panel.checkboxes.show_chat_messages:SetChecked(true)
    else
        FindA.Options.panel.checkboxes.show_chat_messages:SetChecked(false)
    end
    FindA.Options.panel.checkboxes.show_chat_messages:SetScript("OnClick", function(self)
        if self:IsChecked() then
            FindA.chat_msg_enable = 1
        else
            FindA.chat_msg_enable = 0
        end
    end)

    if FindA.always_hide == 1 then
        FindA.Options.panel.checkboxes.always_hide_macro_button:SetChecked(true)
    else
        FindA.Options.panel.checkboxes.always_hide_macro_button:SetChecked(false)
    end
    FindA.Options.panel.checkboxes.always_hide_macro_button:SetScript("OnClick", function(self)
        if self:IsChecked() then
            FindA.always_hide = 1
        else
            FindA.always_hide = 0
        end
    end)

    if FindA.remember_finding == 1 then
        FindA.Options.panel.checkboxes.remember_finding:SetChecked(true)
    else
        FindA.Options.panel.checkboxes.remember_finding:SetChecked(false)
    end
    FindA.Options.panel.checkboxes.remember_finding:SetScript("OnClick", function(self)
        if self:IsChecked() then
            FindA.remember_finding = 1
        else
            FindA.remember_finding = 0
        end
    end)

    UIDropDownMenu_Initialize(FindA.Options.panel.marker_selection.menu, function()
        local info = UIDropDownMenu_CreateInfo()
        info.func = function(self)
            UIDropDownMenu_SetSelectedID(FindA.Options.panel.marker_selection.menu, self:GetID())
            FindA.marker = self:GetID()
            UIDropDownMenu_SetSelectedValue(FindA.Options.panel.marker_selection.menu, FindA.Constants.markers[FindA.marker].name)
        end
        for index, marker in pairs(FindA.Constants.markers) do
            info.text = marker.name
            info.icon = marker.icon
            info.checked = function()
                return FindA.marker == index
            end
        end
        -- info.text = "Star"
        -- info.checked = function()
        --     if FindA.marker == 1 then return true end
        --     return false
        -- end
        -- info.icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1"
        -- UIDropDownMenu_AddButton(info)
        -- info.text = "Circle"
        -- info.checked = function()
        --     if FindA.marker == 2 then return true end
        --     return false
        -- end
        -- info.icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2"
        -- UIDropDownMenu_AddButton(info)
        -- info.text = "Diamond"
        -- info.checked = function()
        --     if FindA.marker == 3 then return true end
        --     return false
        -- end
        -- info.icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3"
        -- UIDropDownMenu_AddButton(info)
        -- info.text = "Triangle"
        -- info.checked = function()
        --     if FindA.marker == 4 then return true end
        --     return false
        -- end
        -- info.icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4"
        -- UIDropDownMenu_AddButton(info)
        -- info.text = "Moon"
        -- info.checked = function()
        --     if FindA.marker == 5 then return true end
        --     return false
        -- end
        -- info.icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5"
        -- UIDropDownMenu_AddButton(info)
        -- info.text = "Square"
        -- info.checked = function()
        --     if FindA.marker == 6 then return true end
        --     return false
        -- end
        -- info.icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6"
        -- UIDropDownMenu_AddButton(info)
        -- info.text = "Cross"
        -- info.checked = function()
        --     if FindA.marker == 7 then return true end
        --     return false
        -- end
        -- info.icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7"
        -- UIDropDownMenu_AddButton(info)
        -- info.text = "Skull"
        -- info.checked = function()
        --     if FindA.marker == 8 then return true end
        --     return false
        -- end
        -- info.icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8"
        UIDropDownMenu_AddButton(info)
    end)
end



-- ADD TO main.lua
-- function FindA.Options.panel.okay()
--     local last_marker = FindA.Constants.markers[FindADB.default_marker].name
--     FindADB.msg_enable = FindA.chat_msg_enable
--     FindADB.always_hide = FindA.always_hide
--     FindADB.default_marker = FindA.marker
--     FindADB.remember_finding = FindA.remember_finding
--     if FindA.always_hide == 1 then
--         MacroButton:Hide()
--     else
--         MacroButton:Show()
--     end
--     if FindA.marker then
--         local selected_marker = UIDropDownMenu_GetText(FindA.Options.panel.marker_selection.menu)
--         if selected_marker ~= last_marker then
--             if FindA.chat_msg_enable == 1 then
--                 print("|cff00ff00Finda:  |r Marker set to  " .. FindA.Constants.markers[FindA.marker].name)
--             end
--         end
--     end
-- end

-- function FindA.Options.panel.refresh()
--     if FindA.chat_msg_enable == 1 then
--         FindA.Options.panel.checkboxes.show_chat_messages:SetChecked(true)
--     else
--         FindA.Options.panel.checkboxes.show_chat_messages:SetChecked(false)
--     end
--     if FindA.always_hide == 1 then
--         FindA.Options.panel.checkboxes.always_hide_macro_button:SetChecked(true)
--     else
--         FindA.Options.panel.checkboxes.always_hide_macro_button:SetChecked(false)
--     end
--     if FindA.remember_finding == 1 then
--         FindA.Options.panel.checkboxes.remember_finding:SetChecked(true)
--     else
--         FindA.Options.panel.checkboxes.remember_finding:SetChecked(false)
--     end
--     UIDropDownMenu_SetText(FindA.Options.panel.marker_selection.menu, FindA.Constants.markers[FindA.marker].name)
-- end

-- InterfaceOptions_AddCategory(FindA.Options.panel)