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
            _G._instanceName = "Magisters' Terrace"
            _G._instanceType = "party"
            _G._instanceID = 2811
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
            assert.is_truthy(text:find("Magisters' Terrace"))
            assert.is_truthy(text:find("Elemental"))
            assert.is_truthy(text:find("Shaman"))
        end)

        it("creates a row for each talent with icon and name", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            -- 3 Elemental talents from utility table
            -- Title is fontStrings[1], talent names are fontStrings[2..4]
            assert.is_true(#notif._data.fontStrings >= 4)
            assert.are.equal("Tremor Totem (nice to have)", notif._data.fontStrings[2]._data.text)
            assert.are.equal("Purge", notif._data.fontStrings[3]._data.text)
            assert.are.equal("Spirit Walk (nice to have)", notif._data.fontStrings[4]._data.text)
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
            _G._instanceName = "Magisters' Terrace"
            _G._instanceType = "party"
            _G._instanceID = 2811
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
            -- 3 Restoration talents from utility table
            assert.are.equal("Tremor Totem (nice to have)", notif._data.fontStrings[2]._data.text)
            assert.are.equal("Purge", notif._data.fontStrings[3]._data.text)
            assert.are.equal("Spirit Walk (nice to have)", notif._data.fontStrings[4]._data.text)
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

    describe("when Enhancement shaman enters Magisters' Terrace", function()
        before_each(function()
            _G._instanceName = "Magisters' Terrace"
            _G._instanceType = "party"
            _G._instanceID = 2811
            _G._playerClass = "SHAMAN"
            _G._playerClassName = "Shaman"
            _G._specIndex = 2
            _G._specName = "Enhancement"
        end)

        it("shows utility talents for Enhancement", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            assert.is_true(notif._data.shown)
            assert.are.equal("Tremor Totem (nice to have)", notif._data.fontStrings[2]._data.text)
            assert.are.equal("Purge", notif._data.fontStrings[3]._data.text)
            assert.are.equal("Spirit Walk (nice to have)", notif._data.fontStrings[4]._data.text)
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

    describe("draggable frame", function()
        before_each(function()
            _G._instanceID = 2811
            _G._playerClass = "SHAMAN"
            _G._playerClassName = "Shaman"
            _G._specIndex = 1
            _G._specName = "Elemental"
        end)

        it("is movable and registered for left-button drag", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            assert.is_true(notif._data.movable)
            assert.are.equal("LeftButton", notif._data.registeredForDrag)
        end)

        it("starts dragging on mouse down", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            assert.is_not_nil(notif._data.scripts["OnDragStart"])
        end)

        it("stops dragging on mouse up", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            assert.is_not_nil(notif._data.scripts["OnDragStop"])
        end)
    end)

    describe("when weekly affix is active but no affix overrides exist", function()
        before_each(function()
            _G._instanceID = 2811
            _G._playerClass = "SHAMAN"
            _G._playerClassName = "Shaman"
            _G._specIndex = 1
            _G._specName = "Elemental"
            _G._currentAffixes = { { id = 10 } }
            _G._affixInfoByID = { [10] = { name = "Fortified" } }
        end)

        it("falls back to the default talent list", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            assert.is_true(notif._data.shown)
            assert.are.equal("Tremor Totem (nice to have)", notif._data.fontStrings[2]._data.text)
            assert.are.equal("Purge",                       notif._data.fontStrings[3]._data.text)
            assert.are.equal("Spirit Walk (nice to have)",  notif._data.fontStrings[4]._data.text)
        end)

        it("does not include the affix name in the title", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            assert.is_falsy(notif._data.fontStrings[1]._data.text:find("Fortified"))
        end)
    end)

    describe("when Devour affix is active", function()
        before_each(function()
            _G._instanceID = 2811
            _G._playerClass = "SHAMAN"
            _G._playerClassName = "Shaman"
            _G._specIndex = 2
            _G._specName = "Enhancement"
            _G._currentAffixes = { { id = 160 } }
            _G._affixInfoByID = { [160] = { name = "Xal'atath's Bargain: Devour" } }
        end)

        it("shows Devour-specific talents instead of dungeon defaults", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            assert.is_true(notif._data.shown)
            assert.are.equal("Poison Cleansing Totem", notif._data.fontStrings[2]._data.text)
            assert.are.equal("Cleanse Spirit", notif._data.fontStrings[3]._data.text)
        end)

        it("includes the affix name in the title", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            assert.is_truthy(notif._data.fontStrings[1]._data.text:find("Devour"))
        end)
    end)

    describe("when the M+ affix API is unavailable", function()
        before_each(function()
            _G._instanceID = 2811
            _G._playerClass = "SHAMAN"
            _G._playerClassName = "Shaman"
            _G._specIndex = 1
            _G._specName = "Elemental"
            _G.C_MythicPlus = nil
        end)

        it("shows default talents without error", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            assert.is_true(notif._data.shown)
            assert.are.equal("Tremor Totem (nice to have)", notif._data.fontStrings[2]._data.text)
        end)
    end)

    describe("shaman utility talents per dungeon", function()
        it("shows correct talents for Maisara Caverns", function()
            _G._instanceID = 2874
            _G._playerClass = "SHAMAN"
            _G._playerClassName = "Shaman"
            _G._specIndex = 1
            _G._specName = "Elemental"
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            assert.is_true(notif._data.shown)
            assert.are.equal("Purge", notif._data.fontStrings[2]._data.text)
            assert.are.equal("Spirit Walk", notif._data.fontStrings[3]._data.text)
        end)

        it("shows correct talents for Windrunner Spire", function()
            _G._instanceID = 2805
            _G._playerClass = "SHAMAN"
            _G._playerClassName = "Shaman"
            _G._specIndex = 3
            _G._specName = "Restoration"
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            assert.is_true(notif._data.shown)
            assert.are.equal("Cleanse Spirit", notif._data.fontStrings[2]._data.text)
            assert.are.equal("Purge", notif._data.fontStrings[3]._data.text)
            assert.are.equal("Poison Cleansing Totem", notif._data.fontStrings[4]._data.text)
        end)

        it("shows correct talents for Skyreach", function()
            _G._instanceID = 1209
            _G._playerClass = "SHAMAN"
            _G._playerClassName = "Shaman"
            _G._specIndex = 2
            _G._specName = "Enhancement"
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            assert.is_true(notif._data.shown)
            assert.are.equal("Purge", notif._data.fontStrings[2]._data.text)
            assert.are.equal("Gust of Wind", notif._data.fontStrings[3]._data.text)
        end)

        it("shows correct talents for Pit of Saron", function()
            _G._instanceID = 658
            _G._playerClass = "SHAMAN"
            _G._playerClassName = "Shaman"
            _G._specIndex = 1
            _G._specName = "Elemental"
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            assert.is_true(notif._data.shown)
            assert.are.equal("Cleanse Spirit", notif._data.fontStrings[2]._data.text)
            assert.are.equal("Thunderous Paws", notif._data.fontStrings[3]._data.text)
            assert.are.equal("Spirit Walk", notif._data.fontStrings[4]._data.text)
        end)

        it("shows correct talents for Nexus-Point Xenas", function()
            _G._instanceID = 2915
            _G._playerClass = "SHAMAN"
            _G._playerClassName = "Shaman"
            _G._specIndex = 3
            _G._specName = "Restoration"
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            assert.is_true(notif._data.shown)
            assert.are.equal("Cleanse Spirit", notif._data.fontStrings[2]._data.text)
            assert.are.equal("Purge", notif._data.fontStrings[3]._data.text)
            assert.are.equal("Thunderous Paws (nice to have)", notif._data.fontStrings[4]._data.text)
            assert.are.equal("Spirit Walk", notif._data.fontStrings[5]._data.text)
        end)

        it("shows correct talents for Seat of the Triumvirate", function()
            _G._instanceID = 1753
            _G._playerClass = "SHAMAN"
            _G._playerClassName = "Shaman"
            _G._specIndex = 2
            _G._specName = "Enhancement"
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            assert.is_true(notif._data.shown)
            assert.are.equal("Purge (nice to have)", notif._data.fontStrings[2]._data.text)
            assert.are.equal("Thunderous Paws", notif._data.fontStrings[3]._data.text)
            assert.are.equal("Spirit Walk", notif._data.fontStrings[4]._data.text)
        end)

        it("shows correct talents for Algeth'ar Academy", function()
            _G._instanceID = 2526
            _G._playerClass = "SHAMAN"
            _G._playerClassName = "Shaman"
            _G._specIndex = 1
            _G._specName = "Elemental"
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            assert.is_true(notif._data.shown)
            assert.are.equal("Poison Cleansing Totem", notif._data.fontStrings[2]._data.text)
        end)
    end)

    describe("talent icons for annotated names", function()
        before_each(function()
            _G._instanceID = 2811
            _G._playerClass = "SHAMAN"
            _G._playerClassName = "Shaman"
            _G._specIndex = 1
            _G._specName = "Elemental"
        end)

        it("shows the real spell icon even when the talent name has a parenthetical annotation", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            -- "Tremor Totem (nice to have)" should resolve to Tremor Totem's icon (136108),
            -- not the default question-mark icon (134400).
            local tremorIcon = notif._data.textures[1]._data.texture
            assert.are.equal(136108, tremorIcon)
        end)

        it("shows the real spell icon for a talent without annotation", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local notif = addon.getFrame("MPlusTalentsNotification")
            -- "Purge" (no annotation) should also resolve correctly.
            local purgeIcon = notif._data.textures[2]._data.texture
            assert.are.equal(136075, purgeIcon)
        end)
    end)

    describe("close button", function()
        before_each(function()
            _G._instanceID = 2811
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
