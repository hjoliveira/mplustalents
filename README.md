# M+ Talents

A World of Warcraft addon for Midnight that shows talent recommendations when you zone into a seasonal dungeon.

## How It Works

When you enter a Midnight Season 1 dungeon, a notification frame appears in the center of your screen showing which talents to pick for your current spec. Each talent is displayed with its spell icon and name. The frame auto-hides after 10 seconds or can be dismissed by clicking it.

## Supported Dungeons

- Magisters' Terrace
- Windrunner Spire
- Maisara Caverns
- Nexus-Point Xenas
- Algeth'ar Academy
- Seat of the Triumvirate
- Skyreach
- Pit of Saron

## Adding Talent Recommendations

Edit the `TALENT_DATA` table in `MPlusTalents/Core.lua`. Each dungeon entry is keyed by its instance ID and contains per-class, per-spec talent lists:

```lua
[2811] = {
    dungeonName = "Magisters' Terrace",
    classes = {
        ["SHAMAN"] = {
            ["Elemental"] = {
                "Stormkeeper",
                "Liquid Magma Totem",
                "Ascendance",
            },
        },
    },
},
```

## Installation

Copy the `MPlusTalents` folder into your WoW addons directory:

```
World of Warcraft/_retail_/Interface/AddOns/MPlusTalents/
```

## Development

### Prerequisites

- Lua 5.4
- LuaRocks
- Busted testing framework

```bash
# Ubuntu/Debian
apt-get install -y lua5.4 liblua5.4-dev luarocks
luarocks install busted

# macOS
brew install lua luarocks
luarocks install busted
```

### Running Tests

```bash
busted
```

## License

[MIT](LICENSE)
