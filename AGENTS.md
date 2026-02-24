# Agent Guidelines for MPlusTalents

This document provides instructions for AI agents working on this codebase.

## Project Overview

MPlusTalents is a World of Warcraft addon for Midnight that shows which talents should be taken when the player zones in to a seasonal dungeon. The main code is in `MPlusTalents/Core.lua`.

## Installing Dependencies

Install Lua, LuaRocks, and the Busted testing framework before working on this project.

### On Ubuntu/Debian

```bash
apt-get update
apt-get install -y lua5.4 liblua5.4-dev luarocks
luarocks install busted
```

### On macOS

```bash
brew install lua luarocks
luarocks install busted
```

### On Windows

1. Download and install Lua from https://www.lua.org/download.html
2. Install LuaRocks from https://luarocks.org/
3. Run: `luarocks install busted`

## Tests

Tests use [busted](https://lunarmodules.github.io/busted/) and live in `spec/`. Run them with:

```bash
busted
```

**Always run `busted` before writing any code** to establish a green baseline.

Follow red/green TDD:

1. **Red** - Write a failing test for the new behavior or bug
2. **Green** - Write the minimum code to make it pass
3. **Refactor** - Clean up while keeping tests green

Never commit with failing tests. CI runs on all pushes and PRs.

## Git Workflow

**Never push directly to main.** All changes must go through a pull request.

1. Create a feature branch for your changes
2. Commit your work to the feature branch
3. Push the feature branch to origin
4. Create a pull request targeting `main`
5. Ensure CI checks pass before requesting review

## Project Structure

```
mplustalents/
├── .busted              # Busted configuration
├── .github/
│   └── workflows/
│       ├── check.yml    # CI workflow that runs tests
│       └── release.yml  # Release workflow
├── AGENTS.md            # This file
├── CLAUDE.md            # Claude Code instructions
├── MPlusTalents/
│   ├── Core.lua         # Main addon code
│   └── MPlusTalents.toc # WoW addon manifest
├── LICENSE
├── README.md
└── spec/
    ├── spec_helper.lua  # Test helpers and WoW API mocks
    └── Core_spec.lua    # Unit tests for Core.lua
```

## Writing Tests

Tests are written using the [busted](https://lunarmodules.github.io/busted/) framework. The `spec/spec_helper.lua` file provides:

- Mocked WoW API functions
- Helper functions for loading the addon in a test environment
- Utilities for simulating events and slash commands

Example test structure:

```lua
require("spec.spec_helper")

describe("Feature", function()
    local addon

    before_each(function()
        addon = loadAddon()
    end)

    it("should do something", function()
        -- Test code
        assert.is_true(condition)
    end)
end)
```
