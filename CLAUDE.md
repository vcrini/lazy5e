# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

`lazy5e` is a terminal UI (TUI) application for D&D 5e Dungeon Masters. It provides a keyboard-driven interface for browsing monsters, items, spells, classes, races, feats, books, and adventures, as well as managing combat encounters, rolling dice, generating random content, and tracking character builds.

## Commands

```bash
# Build
go build ./...

# Run
go run .

# Run tests
go test ./...

# Run a single test
go test -run TestFunctionName ./...

# Filter data to SRD-only (requires yq)
make srd-only
```

## Architecture

The entire application lives in a single file: `main.go` (~14,500 lines). There is one test file: `main_test.go`. There are no packages beyond `main`.

**Key architectural decisions:**

- All data (monsters, items, spells, classes, subclasses, class feature details, races, feats, books, adventures) is embedded at compile time via `//go:embed data/*.yaml`. The `data/` directory is the active dataset; `data.free/` (SRD only) and `data.full/` (complete) are alternate dataset snapshots.

- The `Monster` struct is used as a universal container for all browsable entities (items, spells, classes, races, feats, books, adventures), with `Raw map[string]any` holding the full YAML payload. This means type-specific fields are extracted at render time from `Raw`.

- The `UI` struct is the central god-object holding all application state: browse mode, filter state, encounter list, dice history, random entries, all tview widgets, and undo stacks.

- `newUI(...)` constructs the entire widget tree and wires all keyboard handlers. The `run()` method starts the tview event loop.

- Browse modes (`BrowseMode` enum: `BrowseMonsters`, `BrowseItems`, `BrowseSpells`, `BrowseCharacters`, `BrowseRaces`, `BrowseFeats`, `BrowseBooks`, `BrowseAdventures`, `BrowseRandom`) determine which data `activeEntries()` returns and which `renderDetailBy*` function is called.

- Persistence is via YAML files in `~/.lazy5e/`. State saved: encounters, dice results, random lists, character builds, filter state, description scroll positions. The last-used file path for each list type is stored in a dot-file (e.g., `.encounters_last_path`).

- The `data.full/` directory can hold extended non-SRD content. `full5eDataRoot()` looks for it at `~/.lazy5e/data.full/` (from env `LAZY5E_DATA_FULL`) and `load5eEntryBody()` reads extended book/adventure body text from it at runtime.

- Environment variable overrides: `MONSTERS_YAML` (custom monster YAML path), `ENCOUNTERS_YAML`, `DICE_YAML`, `RANDOM_LIST_YAML`, `CHARACTER_BUILD_YAML`, `LAZY5E_DATA_FULL`.

**Data loading pattern:** Each content type has a `load*FromBytes(b []byte) ([]Monster, []string, []string, []string, error)` function returning entries plus filter option slices (e.g., environments/ability scores, CR/size values, types/lineages).

**Description rendering:** Each content type has a `build*DescriptionText(entry Monster) string` function that extracts fields from `Raw` and formats them as tview-tagged markup strings.
