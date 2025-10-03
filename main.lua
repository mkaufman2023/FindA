----------------------------------------------------------
--                                                      --
--   main.lua                                           --
--   Main logic for target searching and marking.       --
--                                                      --
----------------------------------------------------------

-- Global variables
FindA.marker = 8
FindA.last_found = ""
FindA.always_hide = 0
FindA.chat_msg_enable = 1
FindA.remember_finding = 1
FindA.macro_button_text = ""

-- Global functions
function CombatLogGetCurrentEventInfo(Timestamp, SubEvent, SrcGUID, SrcName, SrcFlag, DstGUID, DstName, DstFlag, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12)
    if ( Timestamp ) then
        -- Modern payload (Missing)
        local HideCaster, SrcRaidFlag, DstRaidFlag = false, nil, nil

        -- Note: Blizzard could have changed order of payload from 9th onwards.
        return Timestamp, SubEvent, HideCaster, SrcGUID, SrcName, SrcFlag, SrcRaidFlag, DstGUID, DstName, DstFlag, DstRaidFlag, _1, _2, _3, _4, _5, _6, _7, _8, _9, _10, _11, _12
    end
end

function UnitIsTapDenied(Unit)
    return UnitIsTapped(Unit) and not UnitIsTappedByPlayer(Unit) and not UnitIsTappedByAllThreatList(Unit)
end



SLASH_FA1 = "/fa"
SLASH_FINDA1 = "/FindA"
BTN_TEXT_SET_TO = ""

FindA.classes = {}
FindA.database = {}
FindA.constants = {}
FindA.functions = {}

FindA.constants.markerNames = {
    [1] = "Star"     ,
    [2] = "Circle"   ,
    [3] = "Diamond"  ,
    [4] = "Triangle" ,
    [5] = "Moon"     ,
    [6] = "Square"   ,
    [7] = "Cross"    ,
    [8] = "Skull"    ,
}
FindA.constants.markers = {
    [1] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:14:14|t",
    [2] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:14:14|t",
    [3] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:14:14|t",
    [4] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:14:14|t",
    [5] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:14:14|t",
    [6] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:14:14|t",
    [7] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:14:14|t",
    [8] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:14:14|t",
}
FindA.constants.gradient = "Interface\\GLUES\\Models\\UI_MainMenu\\swordgradient2"


FindA.functions.subheading = function(frame, title, x, y)
    local text = frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
    text:SetPoint("TOPLEFT", x, y); text:SetText(title)
    return text
end

FindA.functions.capitalize = function(str)
    local capitalized = (str:gsub("^%l", string.upper))
    capitalized = (capitalized:gsub("%s%l", string.upper))
    return capitalized
end

FindA.functions.printHelpMessage = function()
    print("|cff00ff00>Slash commands:|r")
    print(" ")
    print("    |cff00ff00/fa|r             Opens the Interface Options if you have no target,")
    print("                           else sets current target to the FindA search.")
    print("    |cff00ff00/fa|r  |cff00E3DFhide|r      Hides the FindA button")
    print("    |cff00ff00/fa|r  |cff00E3DFshow|r      Shows the FindA button")
    print("    |cff00ff00/fa|r  |cff00E3DF******|r       Sets FindA to search for |cff00E3DF******|r")
    print(" ")
    print(" ")
    print("|cff00ff00>General usage:|r")
    print(" ")
    print("    1.  Use   |cff00ff00/fa|r   to open the options and set the marker type to use")
    print(" ")
    print("    2.  Use   |cff00ff00/fa|r   |cff00E3DF******|r   to set the thing you want to search for")
    print("                                           example:   |cff00ff00/fa|r  |cff00E3DFsqu|r   to find a Squirrel")
    print(" ")
    print("    3.  Click the FindA button to search for the thing you set")
    print("    Alternatively, create the following macro to emulate the button click:")
    print(" ")
    print("              /click FindAButton")
end






------------------------------------------ LOGIN EVENT FUNCTION AND FRAME -----------------------------------------
-------------------------------------------------------------------------------------------------------------------
local function onEvent(self, event, addOnName)
    if addOnName == "FindA" then
        FindADB = FindADB or {}
        FindADB.sessions = (FindADB.sessions or 0) + 1
        if FindADB.sessions == 1 then
            FindADB.xDefault   = 0
            FindADB.yDefault   = 0
            FindADB.msgEnable  = 1
            FindADB.alwaysHide = 0
            FindADB.isShowing  = 0
            FindADB.defaultMarker = 8
            FindADB.rememberFinding = 1
            FindADB.lastFound = ""
        end
        LastFound = FindADB.lastFound
        Marker = FindADB.defaultMarker
        AlwaysHide = FindADB.alwaysHide
        ChatMsgEnable = FindADB.msgEnable
        RememberFinding = FindADB.rememberFinding
        if LastFound ~= "" then BTN_TEXT_SET_TO = LastFound end
        C_Timer.After(4,function()
            print('|cff00FF00FindA Target loaded. Type  |r'..'|cff00E3DF/fa help  |r'..'|cff00FF00for help.|r')
        end)
    end
end

local LoginFrame = CreateFrame("Frame")
LoginFrame:RegisterEvent("ADDON_LOADED")
LoginFrame:SetScript("OnEvent", onEvent)
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------





--------------------------------------------- MAIN FUNCTION AND FRAME ---------------------------------------------
-------------------------------------------------------------------------------------------------------------------
function Find(thing)
    local target = UnitName("target")                                   -- Get the name of the target
    if target then                                                      -- If there is a target
        thing = FindA.functions.capitalize(thing)                           -- Capitalize the target's name
        if string.find(string.lower(target), string.lower(thing)) then      -- Check to see if user arg 'thing' is in target's name
            local dead = UnitIsDead("target")                                   -- Check if target is dead
            local tapped = UnitIsTapDenied("target")                            -- Check if target is tapped
            local marked = GetRaidTargetIndex("target")                         -- Check if target is marked
            if not dead and not tapped and not marked then                      -- If none of the above
                SetRaidTarget("target", Marker)                                     -- Mark target with selected marker
            end
            if tapped and marked then
                SetRaidTarget("target", 0)                                      -- Remove mark if target is marked but tapped by another player
            end
            if dead and marked then
                SetRaidTarget("target", 0)                                      -- Remove mark if target is marked but dead
            end
        end
    end
end

local KillFrame = CreateFrame("Frame")                              -- Create a frame to watch for marked target's death
KillFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")              -- Register the frame for combat log events
KillFrame:SetScript("OnEvent", function(self, event, ...)           -- When the frame receives an event
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then                      -- Ensure the event is a combat log event
        local _, eventType = CombatLogGetCurrentEventInfo()                 -- Get the event type
        if eventType == "PARTY_KILL" then                                   -- If the event is a kill from the player or a party member
            SetRaidTarget("target", 0)                                          -- Remove the marker from the target
        end
    end
end)
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------





--------------------------------------------- MAIN MACRO-BUTTON FRAME ---------------------------------------------
-------------------------------------------------------------------------------------------------------------------
local MacroButton = CreateFrame("Button", "FindAButton", UIParent, "SecureActionButtonTemplate")
MacroButton:SetMovable(true)
MacroButton:RegisterForDrag("LeftButton")
MacroButton:SetScript("OnDragStart",function(self) self:StartMoving() end)
MacroButton:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    FindADB.xDefault = MacroButton:GetLeft()
    FindADB.yDefault = MacroButton:GetTop()
end)

MacroButton:SetWidth(128)
MacroButton:SetHeight(64)
MacroButton:SetFrameStrata("LOW")
MacroButton:SetPoint("CENTER", UIParent, "CENTER")

MacroButton:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
MacroButton:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")
MacroButton:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")

MacroButton:SetAttribute("type1", "macro")
MacroButton:SetAttribute("macrotext1", "/target ")
MacroButton:Show()

local text = MacroButton:CreateFontString(nil, "OVERLAY", "GameTooltipText")
text:SetText("Find:  ")
text:SetPoint("CENTER", -40, 10)
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------





--------------------------------------------- INTERFACE OPTIONS PANEL ---------------------------------------------
-------------------------------------------------------------------------------------------------------------------
local function isChecked(checkbox)
    if checkbox:GetChecked() then return true
    else return false end
end

FindA.panel = CreateFrame("Frame", "FindAPanel")                        -- Create a frame to hold the panel
FindA.panel.name = "FindA"                                              -- Set the Category name for the panel

FindAPanel_MainTitle = FindA.functions.subheading(FindA.panel, "FindA", 0, 0)               -- Create a title for the panel
FindAPanel_MainTitle:SetFont(FindAPanel_MainTitle:GetFont(), 64)
FindAPanel_MainTitle:ClearAllPoints(); FindAPanel_MainTitle:SetPoint("TOP", 0, -32)

FindAPanel_OptionsTitle = FindA.functions.subheading(FindA.panel, "Options", 0, 0)          -- Create a subtitle for the panel
FindAPanel_OptionsTitle:SetFont(FindAPanel_OptionsTitle:GetFont(), 32)
FindAPanel_OptionsTitle:ClearAllPoints(); FindAPanel_OptionsTitle:SetPoint("TOP", 0, -112)

FindAPanel_PanelTexture = FindA.panel:CreateTexture(nil, "BACKGROUND")      -- Create a background texture for the panel
FindAPanel_PanelTexture:SetAllPoints(); FindAPanel_PanelTexture:SetTexture(FindA.constants.gradient)
FindAPanel_PanelTexture:SetAlpha(0.2); FindAPanel_PanelTexture:SetTexCoord(0, 1, 1, 0)

FindAPanel_ShowChatMessagesCheckbox = CreateFrame("CheckButton", "FindAPanel_ShowChatMessagesCheckbox", FindA.panel, "InterfaceOptionsCheckButtonTemplate")
FindAPanel_ShowChatMessagesCheckbox:SetPoint("CENTER", -250, 50)
getglobal(FindAPanel_ShowChatMessagesCheckbox:GetName().."Text"):SetText("Show chat messages")
if ChatMsgEnable == 1 then
     FindAPanel_ShowChatMessagesCheckbox:SetChecked(true)
else FindAPanel_ShowChatMessagesCheckbox:SetChecked(false) end
FindAPanel_ShowChatMessagesCheckbox:SetScript("OnClick", function (self, button, down)
    if isChecked(self) then
         ChatMsgEnable = 1
    else ChatMsgEnable = 0 end
end)

FindAPanel_AlwaysHideCheckbox = CreateFrame("CheckButton", "FindAPanel_AlwaysHideCheckbox", FindA.panel, "InterfaceOptionsCheckButtonTemplate")
FindAPanel_AlwaysHideCheckbox:SetPoint("CENTER", -250, 0)
getglobal(FindAPanel_AlwaysHideCheckbox:GetName().."Text"):SetText("Always hide the macro button")
if AlwaysHide == 1 then
     FindAPanel_AlwaysHideCheckbox:SetChecked(true)
else FindAPanel_AlwaysHideCheckbox:SetChecked(false) end
FindAPanel_AlwaysHideCheckbox:SetScript("OnClick", function (self, button, down)
    if isChecked(self) then
         AlwaysHide = 1
    else AlwaysHide = 0 end
end)

FindAPanel_RememberFindingCheckbox = CreateFrame("CheckButton", "FindAPanel_RememberFindingCheckbox", FindA.panel, "InterfaceOptionsCheckButtonTemplate")
FindAPanel_RememberFindingCheckbox:SetPoint("CENTER", -250, -250)
getglobal(FindAPanel_RememberFindingCheckbox:GetName().."Text"):SetText("Remember FindA search between reloads")
if RememberFinding == 1 then
     FindAPanel_RememberFindingCheckbox:SetChecked(true)
else FindAPanel_RememberFindingCheckbox:SetChecked(false) end
FindAPanel_RememberFindingCheckbox:SetScript("OnClick", function (self, button, down)
    if isChecked(self) then
         RememberFinding = 1
    else RememberFinding = 0 end
end)

FindAPanel_MarkerSelectionText = FindA.functions.subheading(FindA.panel, "Marker Selection", 0, 0)        -- Create a subtitle for the panel
FindAPanel_MarkerSelectionText:SetFont(FindAPanel_MarkerSelectionText:GetFont(), 12)
FindAPanel_MarkerSelectionText:ClearAllPoints(); FindAPanel_MarkerSelectionText:SetPoint("TOP", -200, -330)

FindAPanel_MarkerSelectionMenu = CreateFrame("Frame", "FindAPanel_MarkerSelectionMenu", FindA.panel, "UIDropDownMenuTemplate")
FindAPanel_MarkerSelectionMenu:SetPoint("CENTER", -200, -75)
UIDropDownMenu_SetWidth(FindAPanel_MarkerSelectionMenu, 100)
UIDropDownMenu_SetText(FindAPanel_MarkerSelectionMenu, FindA.constants.markerNames[Marker])
UIDropDownMenu_JustifyText(FindAPanel_MarkerSelectionMenu, "LEFT")
UIDropDownMenu_Initialize(FindAPanel_MarkerSelectionMenu, function(self, level, menuList)
    local info = UIDropDownMenu_CreateInfo()
    info.func = function(self)
        UIDropDownMenu_SetSelectedID(FindAPanel_MarkerSelectionMenu, self:GetID())
        Marker = self:GetID()
        UIDropDownMenu_SetSelectedValue(FindAPanel_MarkerSelectionMenu, FindA.constants.markerNames[Marker])
    end
    info.text = "Star"
---@diagnostic disable-next-line: duplicate-set-field
    info.checked = function()
        if Marker == 1 then return true
        else return false end
    end
    info.icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1"
    UIDropDownMenu_AddButton(info)
    info.text = "Circle"
---@diagnostic disable-next-line: duplicate-set-field
    info.checked = function()
        if Marker == 2 then return true
        else return false end
    end
    info.icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2"
    UIDropDownMenu_AddButton(info)
    info.text = "Diamond"
---@diagnostic disable-next-line: duplicate-set-field
    info.checked = function()
        if Marker == 3 then return true
        else return false end
    end
    info.icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3"
    UIDropDownMenu_AddButton(info)
    info.text = "Triangle"
---@diagnostic disable-next-line: duplicate-set-field
    info.checked = function()
        if Marker == 4 then return true
        else return false end
    end
    info.icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4"
    UIDropDownMenu_AddButton(info)
    info.text = "Moon"
---@diagnostic disable-next-line: duplicate-set-field
    info.checked = function()
        if Marker == 5 then return true
        else return false end
    end
    info.icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5"
    UIDropDownMenu_AddButton(info)
    info.text = "Square"
---@diagnostic disable-next-line: duplicate-set-field
    info.checked = function()
        if Marker == 6 then return true
        else return false end
    end
    info.icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6"
    UIDropDownMenu_AddButton(info)
    info.text = "Cross"
---@diagnostic disable-next-line: duplicate-set-field
    info.checked = function()
        if Marker == 7 then return true
        else return false end
    end
    info.icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7"
    UIDropDownMenu_AddButton(info)
    info.text = "Skull"
---@diagnostic disable-next-line: duplicate-set-field
    info.checked = function()
        if Marker == 8 then return true
        else return false end
    end
    info.icon = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8"
    UIDropDownMenu_AddButton(info)
end)

function FindA.panel.okay()
    local lastMarker = FindA.constants.markerNames[FindADB.defaultMarker]
    FindADB.msgEnable = ChatMsgEnable
    FindADB.alwaysHide = AlwaysHide
    FindADB.defaultMarker = Marker
    FindADB.rememberFinding = RememberFinding
    if AlwaysHide == 1 then
         MacroButton:Hide()
    else MacroButton:Show() end
    if Marker then
        local selectedMarker = UIDropDownMenu_GetText(FindAPanel_MarkerSelectionMenu)
        if selectedMarker ~= lastMarker then
            if ChatMsgEnable == 1 then
                print("|cff00ff00Finda:  |r Marker set to  "..FindA.constants.markers[Marker])
            end
        end
    end
end

function FindA.panel.refresh()
    if ChatMsgEnable == 1 then
         FindAPanel_ShowChatMessagesCheckbox:SetChecked(true)
    else FindAPanel_ShowChatMessagesCheckbox:SetChecked(false) end
    if AlwaysHide == 1 then
         FindAPanel_AlwaysHideCheckbox:SetChecked(true)
    else FindAPanel_AlwaysHideCheckbox:SetChecked(false) end
    if RememberFinding == 1 then
         FindAPanel_RememberFindingCheckbox:SetChecked(true)
    else FindAPanel_RememberFindingCheckbox:SetChecked(false) end
    UIDropDownMenu_SetText(FindAPanel_MarkerSelectionMenu, FindA.constants.markerNames[Marker])
end

InterfaceOptions_AddCategory(FindA.panel)

local function SetMacroAttribute(txt)
    MacroButton:SetAttribute("macrotext1", "/target " .. txt .. "\n/run Find(" .. '"' .. txt .. '"' .. ");")
end

local ReloadFrame = CreateFrame("Frame")
ReloadFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
ReloadFrame:SetScript("OnEvent", function(self, event)
    if AlwaysHide == 1 then
        MacroButton:Hide()
    end
    if RememberFinding == 1 then
        if FindADB.lastFound then
            SetMacroAttribute(FindADB.lastFound)
        end
    end
end)
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------





------------------------------------------ /FindA & /fa COMMAND FUNCTIONS -----------------------------------------
-------------------------------------------------------------------------------------------------------------------
local function SetBtnText(txt)
    text:SetText("Find:  \n" .. txt)
end

local function HandleGlobalActions(txt)
    BTN_TEXT_SET_TO = txt
    if ChatMsgEnable == 1 then
        print("|cff00ff00Finding target:|r  " ..txt)
    end
    if RememberFinding == 1 then
        FindADB.lastFound = txt
    end
end

local function SlashFinda(msg)
    if msg == "" then
        local target = UnitName("target")
        if target == nil then
            InterfaceOptionsFrame_OpenToCategory(FindA.panel)
            InterfaceOptionsFrame_OpenToCategory(FindA.panel)
            return
        else
            if BTN_TEXT_SET_TO ~= target then
                SetBtnText(target)
                SetMacroAttribute(target)
                HandleGlobalActions(target)
            else
                if ChatMsgEnable == 1 then
                    print("|cff00ff00Finda:|r  Target already set to " .. target .. ".")
                end
            end
            return
        end
    end
    if msg == "hide" then
        MacroButton:Hide()
        return
    end
    if msg == "show" then
        if RememberFinding == 1 and FindADB.lastFound then
            SetBtnText(FindADB.lastFound)
        end
        MacroButton:Show()
        return
    end
    if msg == "help" then
        FindA.functions.printHelpMessage()
        return
    end
    if BTN_TEXT_SET_TO ~= FindA.functions.capitalize(msg) then
        msg = FindA.functions.capitalize(msg)
        SetBtnText(msg)
        SetMacroAttribute(msg)
        HandleGlobalActions(msg)
        return
    else
        if ChatMsgEnable == 1 then
            print("|cff00ff00Finda:|r  Target already set to " .. FindA.functions.capitalize(msg) .. ".")
        end
        return
    end
    print('\n at bottom (not good) \n')
end

---@diagnostic disable-next-line: duplicate-set-field
SlashCmdList["FA"] = function (msg)
    if InCombatLockdown() then
        print("|cff00ff00Finda:|r  Failed due to combat. Try again when out of combat.")
        return
    else SlashFinda(msg) end
end

---@diagnostic disable-next-line: duplicate-set-field
SlashCmdList["FINDA"] = function (msg)
    if InCombatLockdown() then
        print("|cff00ff00Finda:|r  Failed due to combat. Try again when out of combat.")
        return
    else SlashFinda(msg) end
end
-------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------


