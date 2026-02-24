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

    describe("when entering a known dungeon with class data", function()
        before_each(function()
            -- Dornogal (Khaz Algar, instanceID 2552) has Shaman data
            _G._instanceName = "Khaz Algar"
            _G._instanceType = "none"
            _G._instanceID = 2552
            _G._playerClass = "SHAMAN"
            _G._playerClassName = "Shaman"
        end)

        it("prints talent recommendations for the player's class", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local output = addon.getPrinted()
            assert.is_true(#output > 0, "Expected talent output but got none")
        end)

        it("includes the dungeon name in the output", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local output = table.concat(addon.getPrinted(), "\n")
            assert.is_truthy(output:find("Dornogal"))
        end)

        it("includes the class name in the output", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local output = table.concat(addon.getPrinted(), "\n")
            assert.is_truthy(output:find("Shaman"))
        end)

        it("prints each talent on its own line", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local output = addon.getPrinted()
            -- Header line + at least one talent line
            assert.is_true(#output >= 2, "Expected header + talent lines")
        end)
    end)

    describe("when entering an unknown zone", function()
        before_each(function()
            _G._instanceName = ""
            _G._instanceType = "none"
            _G._instanceID = 0
        end)

        it("prints nothing", function()
            addon.fireEvent("PLAYER_ENTERING_WORLD", true, false)
            local output = addon.getPrinted()
            assert.are.equal(0, #output)
        end)
    end)

    describe("when in a known dungeon but no data for player class", function()
        before_each(function()
            -- Magisters' Terrace (instanceID 2811), no class data yet
            _G._instanceName = "Magisters' Terrace"
            _G._instanceType = "party"
            _G._instanceID = 2811
            _G._playerClass = "DEMONHUNTER"
            _G._playerClassName = "Demon Hunter"
        end)

        it("prints a message saying no recommendations are available", function()
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
end)
