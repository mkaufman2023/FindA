----------------------------------------------------------
--                                                      --
--   helpers.lua                                        --
--   Definitions for several helper functions.          --
--                                                      --
----------------------------------------------------------

FindA.Helpers.CapitalizeString = function(str)
    local capitalized = (str:gsub("^%l", string.upper))
    capitalized = (capitalized:gsub("%s%l", string.upper))
    return capitalized
end

FindA.Helpers.CreateFontString = function(frame, text, x, y, draw_layer, template_name)
    if not x then x = 0 end
    if not y then y = 0 end
    if not draw_layer then draw_layer = 'ARTWORK' end
    if not template_name then template_name = 'GameFontNormal' end
    local font_string = frame:CreateFontString(nil, draw_layer, template_name)
    font_string:SetPoint("TOPLEFT", x, y)
    font_string:SetText(text)
    return font_string
end

FindA.Helpers.PrintHelpMessage = function()
    print(FindA.Constants.help_message)
end

FindA.Helpers.PrintLoginMessage = function()
    print(FindA.Constants.login_message)
end

FindA.Helpers.SplitTargets = function(input)
    local out = {}
    if not input or input == "" then return out end
    for part in string.gmatch(input, "([^,]+)") do
        part = part:gsub("^%s+", ""):gsub("%s+$", "")
        if part ~= "" then
            table.insert(out, FindA.Helpers.CapitalizeString(part))
        end
    end
    return out
end
