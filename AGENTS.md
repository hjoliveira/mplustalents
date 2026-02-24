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

## Running Tests

From the repository root directory, run:

```bash
busted
```

The tests are located in the `spec/` directory and use the busted testing framework with mocked WoW API functions.

**Always run the existing test suite before making any code changes.** This ensures you have a passing baseline and can detect if your changes introduce regressions.

## Test Requirements

**Any code change requires corresponding tests and a passing test suite.**

When modifying code:

1. **Run `busted` first** to confirm the existing tests pass before writing any code
2. **Add or update tests** for any new or changed behavior in `spec/Core_spec.lua`
3. Run `busted` again to execute all tests
4. Ensure all tests pass (exit code 0)
5. If tests fail, fix the issues before committing

When adding a new feature or fixing a bug:

- Run the full test suite before starting work to establish a green baseline
- Write tests that cover the new behavior or reproduce the bug before fixing it
- Verify the new tests fail without the code change and pass with it

The GitHub Actions workflow will automatically run tests on all pushes and pull requests. PRs with failing tests should not be merged.

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
