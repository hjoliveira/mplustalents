-- MPlusTalents: Talent recommendations for Midnight Season 1 dungeons
-- Edit the TALENT_DATA table below to configure recommendations per dungeon and class.

local ADDON_PREFIX = "|cff00ccff[M+ Talents]|r"

-- Talent recommendations keyed by instanceID (Map.db2), then by class token,
-- then by spec name. Each leaf entry is a list of talent names/notes.
local TALENT_DATA = {
    ---- Midnight Season 1 Dungeons ----

    -- Magisters' Terrace (Midnight)
    [2811] = {
        dungeonName = "Magisters' Terrace",
        classes = {},
    },
    -- Windrunner Spire (Midnight)
    [2805] = {
        dungeonName = "Windrunner Spire",
        classes = {},
    },
    -- Maisara Caverns (Midnight)
    [2874] = {
        dungeonName = "Maisara Caverns",
        classes = {},
    },
    -- Nexus-Point Xenas (Midnight)
    [2915] = {
        dungeonName = "Nexus-Point Xenas",
        classes = {},
    },
    -- Algeth'ar Academy (Dragonflight)
    [2526] = {
        dungeonName = "Algeth'ar Academy",
        classes = {},
    },
    -- Seat of the Triumvirate (Legion)
    [1753] = {
        dungeonName = "Seat of the Triumvirate",
        classes = {},
    },
    -- Skyreach (Warlords of Draenor)
    [1209] = {
        dungeonName = "Skyreach",
        classes = {},
    },
    -- Pit of Saron (Wrath of the Lich King)
    [658] = {
        dungeonName = "Pit of Saron",
        classes = {},
    },

    ---- Test Zones ----

    -- Dornogal (Khaz Algar continent, instanceID 2552)
    [2552] = {
        dungeonName = "Dornogal",
        classes = {
            ["SHAMAN"] = {
                ["Elemental"] = {
                    "Stormkeeper",
                    "Liquid Magma Totem",
                    "Ascendance",
                },
                ["Restoration"] = {
                    "Healing Tide Totem",
                    "Ancestral Vigor",
                },
            },
        },
    },
}

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()

        local dungeonData = TALENT_DATA[instanceID]
        if not dungeonData then
            return
        end

        local className, classToken = UnitClass("player")
        local specIndex = GetSpecialization()
        local _, specName = GetSpecializationInfo(specIndex)

        local classData = dungeonData.classes[classToken]
        local talents = classData and classData[specName]

        if not talents or #talents == 0 then
            print(ADDON_PREFIX .. " " .. dungeonData.dungeonName .. " — no talent recommendations for " .. specName .. " " .. className .. " yet.")
            return
        end

        print(ADDON_PREFIX .. " Talents for " .. specName .. " " .. className .. " in " .. dungeonData.dungeonName .. ":")
        for _, talent in ipairs(talents) do
            print("  • " .. talent)
        end
    end
end)
