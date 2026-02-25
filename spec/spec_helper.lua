-- spec_helper.lua
-- Mocks for WoW API functions used by MPlusTalents

local eventFrame = nil
local registeredEvents = {}
local printed = {}

-- Create a mock WoW widget (Frame, FontString, Texture, etc.)
-- Unknown methods become noops via __index. Tracked methods store state.
local function createMockWidget()
    local data = {
        shown = true,
        text = nil,
        texture = nil,
        fontStrings = {},
        textures = {},
        scripts = {},
    }
    local widget = { _data = data }
    setmetatable(widget, {
        __index = function(_, k)
            return function() end
        end,
    })

    widget.Show = function(self) data.shown = true end
    widget.Hide = function(self) data.shown = false end
    widget.IsShown = function(self) return data.shown end
    widget.SetText = function(self, text) data.text = text end
    widget.GetText = function(self) return data.text end
    widget.SetTexture = function(self, tex) data.texture = tex end
    widget.SetScript = function(self, scriptType, handler)
        data.scripts[scriptType] = handler
    end
    widget.RegisterEvent = function(self, event)
        registeredEvents[event] = true
    end
    widget.UnregisterEvent = function(self, event)
        registeredEvents[event] = nil
    end
    widget.CreateFontString = function(self, name, layer, inherits)
        local fs = createMockWidget()
        table.insert(data.fontStrings, fs)
        return fs
    end
    widget.CreateTexture = function(self, name, layer)
        local tex = createMockWidget()
        table.insert(data.textures, tex)
        return tex
    end

    return widget
end

-- Reset all global WoW API mocks
local function resetMocks()
    eventFrame = nil
    registeredEvents = {}
    printed = {}

    -- Named frames registry
    _G._frames = {}

    -- Timers registry
    _G._timers = {}

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

    -- UIParent mock
    _G.UIParent = createMockWidget()

    -- CreateFrame mock
    _G.CreateFrame = function(frameType, name, parent, template)
        local frame = createMockWidget()
        if name then
            _G._frames[name] = frame
        end
        -- First frame created becomes the event frame
        if not eventFrame then
            eventFrame = frame
        end
        return frame
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

    -- C_Spell mock
    _G.C_Spell = {
        GetSpellInfo = function(spellIdentifier)
            return { name = spellIdentifier, iconID = 134400 }
        end,
    }

    -- C_Timer mock
    _G.C_Timer = {
        After = function(delay, callback)
            table.insert(_G._timers, { delay = delay, callback = callback })
        end,
    }

    -- print mock that captures output
    _G.print = function(...)
        local args = { ... }
        local line = table.concat(args, " ")
        table.insert(printed, line)
    end
end

-- Fire a WoW event on the addon's event frame
local function fireEvent(event, ...)
    if eventFrame and eventFrame._data.scripts["OnEvent"] then
        eventFrame._data.scripts["OnEvent"](eventFrame, event, ...)
    end
end

-- Load the addon fresh (clears mocks, runs Core.lua)
local function loadAddon()
    resetMocks()
    printed = {}

    -- Load the addon file
    dofile("MPlusTalents/Core.lua")

    return {
        fireEvent = fireEvent,
        getEventFrame = function() return eventFrame end,
        getRegisteredEvents = function() return registeredEvents end,
        getPrinted = function() return printed end,
        clearPrinted = function() printed = {} end,
        getFrame = function(name) return _G._frames[name] end,
        getTimers = function() return _G._timers end,
    }
end

-- Expose helpers globally for tests
_G.loadAddon = loadAddon
_G.resetMocks = resetMocks
_G.fireEvent = fireEvent
