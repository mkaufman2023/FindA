----------------------------------------------------------
--                                                      --
--   constants.lua                                      --
--   Definitions for several constant variables.        --
--                                                      --
----------------------------------------------------------

FindA.Constants.markers = {
    [1] = {
        name = "Star",
        icon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:14:14|t",
    },
    [2] = {
        name = "Circle",
        icon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:14:14|t",
    },
    [3] = {
        name = "Diamond",
        icon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:14:14|t",
    },
    [4] = {
        name = "Triangle",
        icon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:14:14|t",
    },
    [5] = {
        name = "Moon",
        icon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:14:14|t",
    },
    [6] = {
        name = "Square",
        icon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:14:14|t",
    },
    [7] = {
        name = "Cross",
        icon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:14:14|t",
    },
    [8] = {
        name = "Skull",
        icon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:14:14|t",
    },
}

FindA.Constants.help_message = (
    "|cff00ff00>Slash commands:|r" .. "\n" ..
    "    |cff00ff00/fa|r             Opens the Interface Options if you have no target," .. "\n" ..
    "                           else sets current target to the FindA search." .. "\n" ..
    "    |cff00ff00/fa|r  |cff00E3DFhide|r      Hides the FindA button" .. "\n" ..
    "    |cff00ff00/fa|r  |cff00E3DFshow|r      Shows the FindA button" .. "\n" ..
    "    |cff00ff00/fa|r  |cff00E3DF******|r       Sets FindA to search for |cff00E3DF******|r" .. "\n\n" ..
    "|cff00ff00>General usage:|r" .. "\n" ..
    "    1.  Use   |cff00ff00/fa|r   to open the options and set the marker type to use" .. "\n" ..
    "    2.  Use   |cff00ff00/fa|r   |cff00E3DF******|r   to set the thing you want to search for" .. "\n" ..
    "                                           example:   |cff00ff00/fa|r  |cff00E3DFsqu|r   to find a Squirrel" .. "\n" ..
    "    3.  Click the FindA button to search for the thing you set" .. "\n" ..
    "    Alternatively, create the following macro to emulate the button click:" .. "\n" ..
    "              /click FindAButton"
)
