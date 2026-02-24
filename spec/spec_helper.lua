-- spec_helper.lua
-- Mocks for WoW API functions used by MPlusTalents

-- Store registered event handlers so tests can fire events
local eventFrame = nil
local registeredEvents = {}
local printed = {}

-- Reset all global WoW API mocks
local function resetMocks()
    eventFrame = nil
    registeredEvents = {}
    printed = {}

    -- Instance info defaults (not in a dungeon)
    _G._instanceName = ""
    _G._instanceType = "none"
    _G._difficultyID = 0
    _G._difficultyName = ""
    _G._maxPlayers = 0
    _G._dynamicDifficulty = 0
    _G._isDynamic = false
    _G._instanceID = 0
    _G._instanceGroupSize = 0
    _G._lfgDungeonID = 0

    -- Player class defaults
    _G._playerClass = "WARRIOR"
    _G._playerClassName = "Warrior"

    -- Player spec defaults
    _G._specIndex = 1
    _G._specName = "Arms"

    -- CreateFrame mock
    _G.CreateFrame = function(frameType, name, parent, template)
        eventFrame = {
            _scripts = {},
            RegisterEvent = function(self, event)
                registeredEvents[event] = true
            end,
            UnregisterEvent = function(self, event)
                registeredEvents[event] = nil
            end,
            SetScript = function(self, scriptType, handler)
                self._scripts[scriptType] = handler
            end,
        }
        return eventFrame
    end

    -- GetInstanceInfo mock
    _G.GetInstanceInfo = function()
        return _G._instanceName,
            _G._instanceType,
            _G._difficultyID,
            _G._difficultyName,
            _G._maxPlayers,
            _G._dynamicDifficulty,
            _G._isDynamic,
            _G._instanceID,
            _G._instanceGroupSize,
            _G._lfgDungeonID
    end

    -- UnitClass mock
    _G.UnitClass = function(unit)
        return _G._playerClassName, _G._playerClass
    end

    -- GetSpecialization mock
    _G.GetSpecialization = function()
        return _G._specIndex
    end

    -- GetSpecializationInfo mock
    _G.GetSpecializationInfo = function(specIndex)
        return nil, _G._specName
    end

    -- print mock that captures output
    _G.print = function(...)
        local args = { ... }
        local line = table.concat(args, " ")
        table.insert(printed, line)
    end
end

-- Fire a WoW event on the addon's event frame
local function fireEvent(event, ...)
    if eventFrame and eventFrame._scripts["OnEvent"] then
        eventFrame._scripts["OnEvent"](eventFrame, event, ...)
    end
end

-- Load the addon fresh (clears mocks, runs Core.lua)
local function loadAddon()
    resetMocks()
    printed = {}

    -- Load the addon file
    local addonName = "MPlusTalents"
    local addonTable = {}
    dofile("MPlusTalents/Core.lua")

    return {
        fireEvent = fireEvent,
        getEventFrame = function() return eventFrame end,
        getRegisteredEvents = function() return registeredEvents end,
        getPrinted = function() return printed end,
        clearPrinted = function() printed = {} end,
    }
end

-- Expose helpers globally for tests
_G.loadAddon = loadAddon
_G.resetMocks = resetMocks
_G.fireEvent = fireEvent
