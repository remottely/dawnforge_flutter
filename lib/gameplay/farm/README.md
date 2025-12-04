# Farm Module Overview

The farm feature is now organized using three lightweight layers so it stays
simple to understand and easy to maintain:

| Layer       | Location                              | Responsibility                                                              |
| ----------- | ------------------------------------- | --------------------------------------------------------------------------- |
| Data        | `data/farm_tile_store.dart`           | Holds all tiles in memory and exposes serialization helpers.                |
| Domain      | `domain/farm_rule_engine.dart`        | Pure rules that transform tiles (till, water, plant, harvest, advance day). |
| Application | `managers/`, `services/`, `handlers/` | Orchestrates gameplay (input, feedback, integrations with other managers).  |

## Key entry points

- **`FarmManager`** – Facade used by the rest of the game. It delegates storage
  to `FarmTileStore` and all gameplay rules to `FarmRuleEngine`.
- **`FarmActionService`** – High-level use cases triggered by UI/inputs.
- **`FarmTileView`** – Visual representation of a tile that stays decoupled from
  business logic.

### Adding new logic

1. Extend the rule engine with a pure transformation if the change is gameplay
   related.
2. Let `FarmManager` orchestrate data access + the new rule.
3. Use the manager/service from UI or input handlers.

Keeping logic pure in the domain layer makes it straightforward to write unit
tests and to reuse the same rules for other platforms (desktop/mobile) without
duplicating code.
