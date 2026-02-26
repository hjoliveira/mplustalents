-- MPlusTalents: Talent recommendations for Midnight Season 1 dungeons
-- Edit the TALENT_DATA table below to configure recommendations per dungeon and class.

local ADDON_PREFIX = "|cff00ccff[M+ Talents]|r"

-- Talent recommendations keyed by instanceID (Map.db2), then by class token,
-- then by spec name. Each spec entry has a `default` list and an optional
-- `affixes` table keyed by affix name for week-specific overrides.
local TALENT_DATA = {
    ---- Midnight Season 1 Dungeons ----

    -- Magisters' Terrace (Midnight)
    [2811] = {
        dungeonName = "Magisters' Terrace",
        classes = {
            ["SHAMAN"] = {
                ["Elemental"] = {
                    default = {
                        "Stormkeeper",
                        "Liquid Magma Totem",
                        "Ascendance",
                    },
                    affixes = {
                        ["Fortified"] = {
                            "Storm Elemental",
                            "Stormkeeper",
                            "Ascendance",
                        },
                    },
                },
                ["Restoration"] = {
                    default = {
                        "Healing Tide Totem",
                        "Ancestral Vigor",
                    },
                },
            },
        },
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
-- spec data table and list of active affix names.
local function SelectTalents(specData, affixNames)
    if specData.affixes then
        for _, affixName in ipairs(affixNames) do
            if specData.affixes[affixName] then
                return specData.affixes[affixName], affixName
            end
        end
    end
    return specData.default, nil
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
    for i, talentName in ipairs(talents) do
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

        local iconID = 134400 -- default question mark
        local spellInfo = C_Spell and C_Spell.GetSpellInfo and C_Spell.GetSpellInfo(talentName)
        if spellInfo and spellInfo.iconID then
            iconID = spellInfo.iconID
        end
        row.icon:SetTexture(iconID)
        row.text:SetText(talentName)

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
        local specData = classData and classData[specName]

        if not specData then
            print(ADDON_PREFIX .. " " .. dungeonData.dungeonName .. " — no talent recommendations for " .. specName .. " " .. className .. " yet.")
            return
        end

        local affixNames = GetCurrentAffixNames()
        local talents, matchedAffix = SelectTalents(specData, affixNames)

        if not talents or #talents == 0 then
            print(ADDON_PREFIX .. " " .. dungeonData.dungeonName .. " — no talent recommendations for " .. specName .. " " .. className .. " yet.")
            return
        end

        ShowNotification(dungeonData.dungeonName, specName, className, talents, matchedAffix)
    end
end)
