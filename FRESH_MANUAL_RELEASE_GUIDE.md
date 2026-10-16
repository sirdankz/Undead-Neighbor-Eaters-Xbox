# Fresh Original Xbox build and ROM-free release

`BUILD_FRESH_XBE_RELEASE.ps1` starts a clean RXDK build from the current source and prepares a ROM-free distribution ZIP. The build validates the `GAME MANUAL` label in the compiled XBE to prevent accidentally packaging an old executable.

## Requirements

- Windows with [Team Resurgent RXDK](https://github.com/Team-Resurgent)
- A locally supplied compatible *Zombies Ate My Neighbors* SNES ROM
- Optional locally supplied original manual scans or valid RGB565 spreads

The developer supplies ROM/manual files locally. They must not be committed to the repository or included in binary releases.

## Fresh build

Extract or clone this repository to a new directory and run:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\BUILD_FRESH_XBE_RELEASE.ps1 -LegacyRoot 'C:\path\to\existing-local-game-workspace'
```

`-LegacyRoot` is used only to locate developer-supplied ROM/manual data. The script compiles the source in the current working tree and explicitly packages the newly built XBE.

Alternatively, with your compatible `.sfc`/`.smc` ROM placed at the repository root, build and package in two commands:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\BUILD_XBOX_RELEASE.ps1 -NoExplorer
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\MAKE_ROM_FREE_XBE_RELEASE.ps1 -XbePath '.\out\Undead Neighbor Eaters\default.xbe' -NoExplorer
```

## Outputs

- `out/Undead Neighbor Eaters/default.xbe`: locally built XBE
- `out/PUBLIC_ROM_FREE_XBE/Undead_Neighbor_Eaters_Xbox_ROM_FREE_XBE.zip`: ROM-free installer archive

The locally created ISO may include your own ROM and must not be distributed as a ROM-free release. Optional manual page data is deliberately excluded from the public ZIP. To use the manual in an installed game, an individual user supplies their own pages beside the installed XBE.

## Manual and licensing

The source includes the `GAME MANUAL` menu entry; the actual reader needs all ten compatible locally supplied spreads. See `README.md` and `manual/README.md`.

The ROM-free release workflow and project rename do not establish redistribution permission for upstream-derived code. See `LICENSING.md` and `RELEASE_READINESS.md` before publishing any binary or source archive.
