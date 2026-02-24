-- MPlusTalents: Talent recommendations for Midnight Season 1 dungeons
-- Edit the TALENT_DATA table below to configure recommendations per dungeon and class.

local ADDON_PREFIX = "|cff00ccff[M+ Talents]|r"

-- Talent recommendations keyed by instanceID, then by class token.
-- Each entry is a list of talent names/notes to display to the player.
local TALENT_DATA = {
    -- Ara-Kara, City of Echoes
    [2773] = {
        dungeonName = "Ara-Kara, City of Echoes",
        classes = {
            ["WARRIOR"] = {
                "Avatar",
                "Thunderous Roar",
                "Shockwave",
            },
        },
    },
    -- City of Threads
    [2839] = {
        dungeonName = "City of Threads",
        classes = {},
    },
    -- Grim Batol
    [670] = {
        dungeonName = "Grim Batol",
        classes = {},
    },
    -- Mists of Tirna Scithe
    [2290] = {
        dungeonName = "Mists of Tirna Scithe",
        classes = {},
    },
    -- The Necrotic Wake
    [2286] = {
        dungeonName = "The Necrotic Wake",
        classes = {},
    },
    -- Siege of Boralus
    [2233] = {
        dungeonName = "Siege of Boralus",
        classes = {},
    },
    -- The Stonevault
    [2652] = {
        dungeonName = "The Stonevault",
        classes = {},
    },
    -- The Dawnbreaker
    [2662] = {
        dungeonName = "The Dawnbreaker",
        classes = {},
    },
}

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local _, instanceType, _, _, _, _, _, instanceID = GetInstanceInfo()

        if instanceType ~= "party" then
            return
        end

        local dungeonData = TALENT_DATA[instanceID]
        if not dungeonData then
            return
        end

        local className, classToken = UnitClass("player")
        local talents = dungeonData.classes[classToken]

        if not talents or #talents == 0 then
            print(ADDON_PREFIX .. " " .. dungeonData.dungeonName .. " — no talent recommendations for " .. className .. " yet.")
            return
        end

        print(ADDON_PREFIX .. " Talents for " .. className .. " in " .. dungeonData.dungeonName .. ":")
        for _, talent in ipairs(talents) do
            print("  • " .. talent)
        end
    end
end)
