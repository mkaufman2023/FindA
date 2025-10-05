----------------------------------------------------------
--                                                      --
--   main.lua                                           --
--   Main logic for target searching and marking.       --
--                                                      --
----------------------------------------------------------

-- Global variables
FindA.marker = 8
FindA.last_found = ""
FindA.always_hide = 1
FindA.chat_msg_enable = 1
FindA.remember_finding = 1
FindA.macro_button_text = ""
FindA.button_text_set_to = ""
FindA.MacroButton = CreateFrame("Button", "FindAButton", UIParent, "SecureActionButtonTemplate")


-- Global functions
function CombatLogGetCurrentEventInfo(timestamp, sub_event, src_guid, src_name, src_flag, dest_guid, dest_name, dest_flag, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12)
    if timestamp then
        local hide_caster, src_raid_flag, dest_raid_flag = false, nil, nil
        return timestamp, sub_event, hide_caster, src_guid, src_name, src_flag, src_raid_flag, dest_guid, dest_name, dest_flag, dest_raid_flag, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12
    end
end
function UnitIsTapDenied(unit)
    return UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit)
end


-- Slash commands
SLASH_FA1 = "/fa"
SLASH_FINDA1 = "/FindA"


-- Login logic
FindA.Frames.login = CreateFrame("Frame")
FindA.Frames.login:RegisterEvent("ADDON_LOADED")
FindA.Frames.login:SetScript("OnEvent", function(self, event, addon_name)
    if addon_name == "FindA" then
        FindASV = FindASV or {}
        FindASV.sessions = (FindASV.sessions or 0) + 1
        -- Initialize saved variables on first load
        if FindASV.sessions == 1 then
            FindASV.marker = 8
            FindASV.x_default = 0
            FindASV.y_default = 0
            FindASV.is_showing = 0
            FindASV.always_hide = 1
            FindASV.last_found = ""
            FindASV.chat_msg_enable = 1
            FindASV.remember_finding = 1
        end
        -- Update global variables from saved variables
        FindA.last_found = FindASV.last_found
        FindA.marker = FindASV.marker
        FindA.always_hide = FindASV.always_hide
        FindA.chat_msg_enable = FindASV.chat_msg_enable
        FindA.remember_finding = FindASV.remember_finding
        if FindA.last_found ~= "" then
            FindA.button_text_set_to = FindA.last_found
        end
        -- Print login message after a short delay
        C_Timer.After(4, FindA.Helpers.PrintLoginMessage)
    end
end)


-- Target marker removal on death
FindA.Frames.marked_kill = CreateFrame("Frame")
FindA.Frames.marked_kill:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
FindA.Frames.marked_kill:SetScript("OnEvent", function(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, event_type = CombatLogGetCurrentEventInfo()
        if event_type == "PARTY_KILL" then
            SetRaidTarget("target", 0)
        end
    end
end)


-- Macro button setup
FindA.MacroButton:SetMovable(true)
FindA.MacroButton:RegisterForDrag("LeftButton")
FindA.MacroButton:SetScript("OnDragStart",function(self) self:StartMoving() end)
FindA.MacroButton:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    FindASV.y_default = FindA.MacroButton:GetTop()
    FindASV.x_default = FindA.MacroButton:GetLeft()
end)

FindA.MacroButton:SetWidth(128)
FindA.MacroButton:SetHeight(64)
FindA.MacroButton:SetFrameStrata("LOW")
FindA.MacroButton:SetPoint("CENTER", UIParent, "CENTER")

FindA.MacroButton:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
FindA.MacroButton:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")
FindA.MacroButton:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")

FindA.MacroButton:SetAttribute("type1", "macro")
FindA.MacroButton:SetAttribute("macrotext1", "/target ")
FindA.MacroButton:Show()

FindA.MacroButton.current_text = FindA.MacroButton:CreateFontString(nil, "OVERLAY", "GameTooltipText")
FindA.MacroButton.current_text:SetText("Find:  ")
FindA.MacroButton.current_text:SetPoint("CENTER", -40, 10)

FindA.MacroButton.UpdateText = function(text)
    FindA.MacroButton.current_text:SetText("Find:  \n" .. text)
end

FindA.MacroButton.UpdateAttribute = function(text)
    FindA.MacroButton:SetAttribute("macrotext1", "/target " .. text .. "\n/run FindA.find(" .. '"' .. text .. '"' .. ");")
end


-- UI reload logic
FindA.Frames.reload = CreateFrame("Frame")
FindA.Frames.reload:RegisterEvent("PLAYER_ENTERING_WORLD")
FindA.Frames.reload:SetScript("OnEvent", function(self, event, ...)
    for k,v in pairs(({...})) do
        print(k,v)
    end
    if FindA.always_hide == 1 then
        FindA.MacroButton:Hide()
    end
    if FindA.remember_finding == 1 and FindASV.last_found then
        FindA.MacroButton.UpdateAttribute(FindASV.last_found)
    end
end)


-- Initialize interface options
FindA.Options.InitInterfaceOptions()


-- Main finding function
FindA.find = function(thing)
    local target = UnitName("target")
    if target then
        thing = FindA.Helpers.CapitalizeString(thing)
        if string.find(string.lower(target), string.lower(thing)) then
            local dead = UnitIsDead("target")
            local tapped = UnitIsTapDenied("target")
            local marked = GetRaidTargetIndex("target")
            if not dead and not tapped and not marked then
                SetRaidTarget("target", FindA.marker)
            end
            if tapped and marked then
                SetRaidTarget("target", 0)
            end
            if dead and marked then
                SetRaidTarget("target", 0)
            end
        end
    end
end


-- Slash command logic
local function HandleGlobalActions(text)
    FindA.button_text_set_to = text
    if FindA.chat_msg_enable == 1 then
        print("|cff00ff00Finding target:|r  " .. text)
    end
    if FindA.remember_finding == 1 then
        FindASV.last_found = text
    end
end

local function SlashFinda(input)
    if input == "" then
        local target = UnitName("target")
        if target == nil then
            InterfaceOptionsFrame_OpenToCategory(FindA.Options.panel)
            InterfaceOptionsFrame_OpenToCategory(FindA.Options.panel)
            return
        else
            if FindA.button_text_set_to ~= target then
                FindA.MacroButton.UpdateText(target)
                FindA.MacroButton.UpdateAttribute(target)
                HandleGlobalActions(target)
            else
                if FindA.chat_msg_enable == 1 then
                    print("|cff00ff00Finda:|r  Target already set to " .. target .. ".")
                end
            end
            return
        end
    end
    if input == "hide" then
        FindA.MacroButton:Hide()
        return
    end
    if input == "show" then
        if FindA.remember_finding == 1 and FindASV.last_found then
            FindA.MacroButton.UpdateText(FindASV.last_found)
        end
        FindA.MacroButton:Show()
        return
    end
    if input == "help" then
        FindA.Helpers.PrintHelpMessage()
        return
    end
    if FindA.button_text_set_to ~= FindA.Helpers.CapitalizeString(input) then
        input = FindA.Helpers.CapitalizeString(input)
        FindA.MacroButton.UpdateText(input)
        FindA.MacroButton.UpdateAttribute(input)
        HandleGlobalActions(input)
        return
    else
        if FindA.chat_msg_enable == 1 then
            print("|cff00ff00Finda:|r  Target already set to " .. FindA.Helpers.CapitalizeString(input) .. ".")
        end
        return
    end
end

SlashCmdList["FA"] = function(input)
    if InCombatLockdown() then
        print("|cff00ff00Finda:|r  Failed due to combat. Try again when out of combat.")
        return
    end
    SlashFinda(input)
end

SlashCmdList["FINDA"] = function(input)
    if InCombatLockdown() then
        print("|cff00ff00Finda:|r  Failed due to combat. Try again when out of combat.")
        return
    end
    SlashFinda(input)
end
