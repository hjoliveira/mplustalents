-- MPlusTalents: Talent recommendations for Midnight Season 1 dungeons
-- Edit the TALENT_DATA table below to configure recommendations per dungeon and class.

local ADDON_PREFIX = "|cff00ccff[M+ Talents]|r"

-- Talent recommendations keyed by instanceID (Map.db2), then by class token,
-- then by spec name. Each leaf entry is either a plain spell-name string or a
-- table { name = "Spell", niceToHave = true } for optional talents.
local TALENT_DATA = {
    ---- Midnight Season 1 Dungeons ----

    -- Magisters' Terrace (Midnight)
    [2811] = {
        dungeonName = "Magisters' Terrace",
        classes = {
            ["SHAMAN"] = {
                ["Elemental"] = {
                    { name = "Tremor Totem", niceToHave = true },
                    "Purge",
                    { name = "Spirit Walk", niceToHave = true },
                },
                ["Enhancement"] = {
                    { name = "Tremor Totem", niceToHave = true },
                    "Purge",
                    { name = "Spirit Walk", niceToHave = true },
                },
                ["Restoration"] = {
                    { name = "Tremor Totem", niceToHave = true },
                    "Purge",
                    { name = "Spirit Walk", niceToHave = true },
                },
            },
        },
    },
    -- Windrunner Spire (Midnight)
    [2805] = {
        dungeonName = "Windrunner Spire",
        classes = {
            ["SHAMAN"] = {
                ["Elemental"] = {
                    "Cleanse Spirit",
                    "Purge",
                    "Poison Cleansing Totem",
                },
                ["Enhancement"] = {
                    "Cleanse Spirit",
                    "Purge",
                    "Poison Cleansing Totem",
                },
                ["Restoration"] = {
                    "Cleanse Spirit",
                    "Purge",
                    "Poison Cleansing Totem",
                },
            },
        },
    },
    -- Maisara Caverns (Midnight)
    [2874] = {
        dungeonName = "Maisara Caverns",
        classes = {
            ["SHAMAN"] = {
                ["Elemental"] = {
                    "Purge",
                    "Spirit Walk",
                },
                ["Enhancement"] = {
                    "Purge",
                    "Spirit Walk",
                },
                ["Restoration"] = {
                    "Purge",
                    "Spirit Walk",
                },
            },
        },
    },
    -- Nexus-Point Xenas (Midnight)
    [2915] = {
        dungeonName = "Nexus-Point Xenas",
        classes = {
            ["SHAMAN"] = {
                ["Elemental"] = {
                    "Cleanse Spirit",
                    "Purge",
                    { name = "Thunderous Paws", niceToHave = true },
                    "Spirit Walk",
                },
                ["Enhancement"] = {
                    "Cleanse Spirit",
                    "Purge",
                    { name = "Thunderous Paws", niceToHave = true },
                    "Spirit Walk",
                },
                ["Restoration"] = {
                    "Cleanse Spirit",
                    "Purge",
                    { name = "Thunderous Paws", niceToHave = true },
                    "Spirit Walk",
                },
            },
        },
    },
    -- Algeth'ar Academy (Dragonflight)
    [2526] = {
        dungeonName = "Algeth'ar Academy",
        classes = {
            ["SHAMAN"] = {
                ["Elemental"] = {
                    "Poison Cleansing Totem",
                },
                ["Enhancement"] = {
                    "Poison Cleansing Totem",
                },
                ["Restoration"] = {
                    "Poison Cleansing Totem",
                },
            },
        },
    },
    -- Seat of the Triumvirate (Legion)
    [1753] = {
        dungeonName = "Seat of the Triumvirate",
        classes = {
            ["SHAMAN"] = {
                ["Elemental"] = {
                    { name = "Purge", niceToHave = true },
                    "Thunderous Paws",
                    "Spirit Walk",
                },
                ["Enhancement"] = {
                    { name = "Purge", niceToHave = true },
                    "Thunderous Paws",
                    "Spirit Walk",
                },
                ["Restoration"] = {
                    { name = "Purge", niceToHave = true },
                    "Thunderous Paws",
                    "Spirit Walk",
                },
            },
        },
    },
    -- Skyreach (Warlords of Draenor)
    [1209] = {
        dungeonName = "Skyreach",
        classes = {
            ["SHAMAN"] = {
                ["Elemental"] = {
                    "Purge",
                    "Gust of Wind",
                },
                ["Enhancement"] = {
                    "Purge",
                    "Gust of Wind",
                },
                ["Restoration"] = {
                    "Purge",
                    "Gust of Wind",
                },
            },
        },
    },
    -- Pit of Saron (Wrath of the Lich King)
    [658] = {
        dungeonName = "Pit of Saron",
        classes = {
            ["SHAMAN"] = {
                ["Elemental"] = {
                    "Cleanse Spirit",
                    "Thunderous Paws",
                    "Spirit Walk",
                },
                ["Enhancement"] = {
                    "Cleanse Spirit",
                    "Thunderous Paws",
                    "Spirit Walk",
                },
                ["Restoration"] = {
                    "Cleanse Spirit",
                    "Thunderous Paws",
                    "Spirit Walk",
                },
            },
        },
    },

}

-- Weekly-affix talent overrides keyed by class token, then spec name, then affix name.
-- When a matching affix is active this list is shown instead of the dungeon default.
-- These apply across all dungeons.
local AFFIX_TALENT_DATA = {
    ["SHAMAN"] = {
        ["Elemental"] = {
            ["Xal'atath's Bargain: Devour"] = {
                "Poison Cleansing Totem",
                "Cleanse Spirit",
            },
        },
        ["Enhancement"] = {
            ["Xal'atath's Bargain: Devour"] = {
                "Poison Cleansing Totem",
                "Cleanse Spirit",
            },
        },
        ["Restoration"] = {
            ["Xal'atath's Bargain: Devour"] = {
                "Poison Cleansing Totem",
                "Cleanse Spirit",
            },
        },
    },
}

----------------------------------------------------------------
-- Affix helpers
----------------------------------------------------------------

-- Returns the names of all active M+ affixes this week, in order.
local function GetCurrentAffixNames()
    if not C_MythicPlus or not C_MythicPlus.GetCurrentAffixes then
        return {}
    end
    local affixes = C_MythicPlus.GetCurrentAffixes()
    if not affixes then return {} end
    local names = {}
    for _, affixInfo in ipairs(affixes) do
        if C_ChallengeMode and C_ChallengeMode.GetAffixInfo then
            local name = C_ChallengeMode.GetAffixInfo(affixInfo.id)
            if name then
                table.insert(names, name)
            end
        end
    end
    return names
end

-- Returns the talent list and matched affix name (or nil) for the given
-- class/spec and list of active affix names, checking AFFIX_TALENT_DATA
-- first and falling back to the dungeon-specific default list.
local function SelectTalents(dungeonTalents, classToken, specName, affixNames)
    local affixSpecData = AFFIX_TALENT_DATA[classToken] and AFFIX_TALENT_DATA[classToken][specName]
    if affixSpecData then
        for _, affixName in ipairs(affixNames) do
            if affixSpecData[affixName] then
                return affixSpecData[affixName], affixName
            end
        end
    end
    return dungeonTalents, nil
end

----------------------------------------------------------------
-- Notification frame
----------------------------------------------------------------

local notifFrame = nil
local talentRows = {}

local function CreateNotificationFrame()
    local f = CreateFrame("Frame", "MPlusTalentsNotification", UIParent, "BackdropTemplate")
    f:SetSize(300, 100)
    f:SetPoint("CENTER", UIParent, "CENTER", 0, 150)
    f:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    f:SetBackdropColor(0, 0, 0, 0.8)
    f:SetFrameStrata("HIGH")
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self) self:StartMoving() end)
    f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    f:Hide()

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOP", f, "TOP", 0, -12)
    f.title:SetWidth(270)

    local closeBtn = CreateFrame("Button", "MPlusTalentsCloseButton", f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -2, -2)
    closeBtn:SetScript("OnClick", function() f:Hide() end)
    f.closeButton = closeBtn

    return f
end

local function ShowNotification(dungeonName, specName, className, talents, affixName)
    if not notifFrame then
        notifFrame = CreateNotificationFrame()
    end

    -- Hide previously visible talent rows
    for _, row in ipairs(talentRows) do
        row.icon:Hide()
        row.text:Hide()
    end

    local title = specName .. " " .. className .. " — " .. dungeonName
    if affixName then
        title = title .. " (" .. affixName .. ")"
    end
    notifFrame.title:SetText(title)

    local yOffset = -40
    for i, entry in ipairs(talents) do
        local row = talentRows[i]
        if not row then
            row = {}
            row.icon = notifFrame:CreateTexture(nil, "ARTWORK")
            row.icon:SetSize(24, 24)
            row.text = notifFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            talentRows[i] = row
        end

        row.icon:SetPoint("TOPLEFT", notifFrame, "TOPLEFT", 16, yOffset)
        row.text:SetPoint("LEFT", row.icon, "RIGHT", 8, 0)

        local spellName = type(entry) == "table" and entry.name or entry
        local niceToHave = type(entry) == "table" and entry.niceToHave

        local iconID = 134400 -- default question mark
        local spellInfo = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(spellName)
        local playerHasSpell = false
        if spellInfo and spellInfo.iconID then
            iconID = spellInfo.iconID
            if spellInfo.spellID and IsPlayerSpell and IsPlayerSpell(spellInfo.spellID) then
                playerHasSpell = true
            end
        end
        row.icon:SetTexture(iconID)

        local displayText = spellName
        if niceToHave then
            displayText = spellName .. " (nice to have)"
        end
        row.text:SetText(displayText)

        row.icon:SetDesaturated(not playerHasSpell)
        row.icon:Show()
        row.text:Show()

        yOffset = yOffset - 30
    end

    notifFrame:SetSize(300, 50 + (#talents * 30))
    notifFrame:Show()
end

----------------------------------------------------------------
-- Event handling
----------------------------------------------------------------

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
        local dungeonTalents = classData and classData[specName]

        if not dungeonTalents or #dungeonTalents == 0 then
            print(ADDON_PREFIX .. " " .. dungeonData.dungeonName .. " — no talent recommendations for " .. specName .. " " .. className .. " yet.")
            return
        end

        local affixNames = GetCurrentAffixNames()
        local talents, matchedAffix = SelectTalents(dungeonTalents, classToken, specName, affixNames)

        ShowNotification(dungeonData.dungeonName, specName, className, talents, matchedAffix)
    end
end)
