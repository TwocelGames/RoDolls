# RoDolls

RoDolls is a Roblox library for simulating ragdoll physics on character models. It provides utilities to enable, disable, and customize ragdoll behavior for humanoid characters in your Roblox games.

## Features

- Enable ragdoll physics on any character
- Restore characters from ragdoll state
- Simple API for integration

## Installation

install using wally
```toml


```

## API Reference

### `RoDoll` Object

The main API is the `RoDoll` object, which represents a ragdoll instance for a character.

#### Constructor

```luau
RoDoll.new(character: Model, rigType: "R6" | "R15"): RoDoll
```
#### Methods

- `RoDoll:Enable()`
	- Enables ragdoll physics on the character.

- `RoDoll:Disable()`
	- Restores the character from ragdoll state.

- `RoDoll:bodyOnDeath(isEnabled: boolean, bodyLifeTime: number)`
	- Spawns a body when the rig dies

- `RoDoll:Destroy()`
	- Cleans up the ragdoll instance and disconnects events.

## Example

```lua
local RoDoll = require(path.to.RoDoll)

local ragdoll = RoDoll.new(character)

ragdoll:bodyOnDeath(true, 3)

-- should check if .rig exists since ragdoll will be destroyed if bodyondeath = true and rig is dead
if ragdoll.rig then
	ragdoll:enable()
end

task.wait(10)

if ragdoll.rig then
	ragdoll:disable()
end

ragdoll:destroy()
```
