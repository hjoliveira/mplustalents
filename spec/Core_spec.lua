require("spec.spec_helper")

describe("MPlusTalents", function()
    local addon

    before_each(function()
        addon = loadAddon()
    end)

    describe("event registration", function()
        it("registers for PLAYER_ENTERING_WORLD", function()
            local events = addon.getRegisteredEvents()
            assert.is_true(events["PLAYER_ENTERING_WORLD"] == true)
        end)
    end)

    describe("when entering a known zone with spec data", function()
        before_each(function()
            _G._instanceName = "Khaz Algar"
            _G._instanceType = "none"
            _G._instanceID = 2552
            _G._playerClass = "SHAMAN"
            _G._playerClassName = "Shaman"
            _G._specIndex = 1
            _G._specName = "Elemental"
        end)

        it("shows the notification frame", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            assert.is_not_nil(notif)
            assert.is_true(notif._data.shown)
        end)

        it("sets the title with dungeon, spec and class", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            local title = notif._data.fontStrings[1]
            assert.is_not_nil(title)
            local text = title._data.text
            assert.is_truthy(text:find("Dornogal"))
            assert.is_truthy(text:find("Elemental"))
            assert.is_truthy(text:find("Shaman"))
        end)

        it("creates a row for each talent with icon and name", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            -- 3 Elemental talents: Stormkeeper, Liquid Magma Totem, Ascendance
            -- Each talent has an icon texture and a name font string
            -- Title is fontStrings[1], talent names are fontStrings[2..4]
            assert.is_true(#notif._data.fontStrings >= 4)
            assert.are.equal("Stormkeeper", notif._data.fontStrings[2]._data.text)
            assert.are.equal("Liquid Magma Totem", notif._data.fontStrings[3]._data.text)
            assert.are.equal("Ascendance", notif._data.fontStrings[4]._data.text)
        end)

        it("sets an icon texture for each talent", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            -- 3 talent icons
            assert.is_true(#notif._data.textures >= 3)
            for i = 1, 3 do
                assert.is_not_nil(notif._data.textures[i]._data.texture)
            end
        end)

        it("does not schedule an auto-hide timer", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local timers = addon.getTimers()
            assert.are.equal(0, #timers)
        end)

        it("creates a close button", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local closeBtn = addon.getFrame("MPlusTalentsCloseButton")
            assert.is_not_nil(closeBtn)
            assert.is_true(closeBtn._data.shown)
        end)

        it("hides the notification when the close button is clicked", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            local closeBtn = addon.getFrame("MPlusTalentsCloseButton")
            assert.is_true(notif._data.shown)
            -- Simulate clicking the close button
            closeBtn._data.scripts["OnClick"](closeBtn)
            assert.is_false(notif._data.shown)
        end)

        it("does not print to chat", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local output = addon.getPrinted()
            assert.are.equal(0, #output)
        end)
    end)

    describe("when the player has a different spec for the same dungeon", function()
        before_each(function()
            _G._instanceName = "Khaz Algar"
            _G._instanceType = "none"
            _G._instanceID = 2552
            _G._playerClass = "SHAMAN"
            _G._playerClassName = "Shaman"
            _G._specIndex = 3
            _G._specName = "Restoration"
        end)

        it("shows the talents for that spec", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            assert.is_true(notif._data.shown)
            local title = notif._data.fontStrings[1]
            assert.is_truthy(title._data.text:find("Restoration"))
            -- 2 Restoration talents
            assert.are.equal("Healing Tide Totem", notif._data.fontStrings[2]._data.text)
            assert.are.equal("Ancestral Vigor", notif._data.fontStrings[3]._data.text)
        end)
    end)

    describe("when entering an unknown zone", function()
        before_each(function()
            _G._instanceName = ""
            _G._instanceType = "none"
            _G._instanceID = 0
        end)

        it("does not show any notification", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            assert.is_nil(notif)
        end)

        it("prints nothing", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local output = addon.getPrinted()
            assert.are.equal(0, #output)
        end)
    end)

    describe("when in a known dungeon but no data for player class", function()
        before_each(function()
            _G._instanceName = "Magisters' Terrace"
            _G._instanceType = "party"
            _G._instanceID = 2811
            _G._playerClass = "DEMONHUNTER"
            _G._playerClassName = "Demon Hunter"
            _G._specIndex = 1
            _G._specName = "Havoc"
        end)

        it("prints a fallback message to chat", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local output = table.concat(addon.getPrinted(), "\n")
            assert.is_truthy(output:find("no talent recommendations"))
        end)
    end)

    describe("when in a known dungeon with class data but not for current spec", function()
        before_each(function()
            _G._instanceName = "Khaz Algar"
            _G._instanceType = "none"
            _G._instanceID = 2552
            _G._playerClass = "SHAMAN"
            _G._playerClassName = "Shaman"
            _G._specIndex = 2
            _G._specName = "Enhancement"
        end)

        it("prints a fallback message to chat", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local output = table.concat(addon.getPrinted(), "\n")
            assert.is_truthy(output:find("no talent recommendations"))
        end)
    end)

    describe("when entering an unlisted zone", function()
        before_each(function()
            _G._instanceName = "Some Raid"
            _G._instanceType = "raid"
            _G._instanceID = 9999
        end)

        it("prints nothing", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local output = addon.getPrinted()
            assert.are.equal(0, #output)
        end)
    end)

    describe("close button", function()
        before_each(function()
            _G._instanceID = 2552
            _G._playerClass = "SHAMAN"
            _G._playerClassName = "Shaman"
            _G._specIndex = 1
            _G._specName = "Elemental"
        end)

        it("hides the notification when clicked", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            local closeBtn = addon.getFrame("MPlusTalentsCloseButton")
            assert.is_true(notif._data.shown)

            closeBtn._data.scripts["OnClick"](closeBtn)
            assert.is_false(notif._data.shown)
        end)
    end)
end)
