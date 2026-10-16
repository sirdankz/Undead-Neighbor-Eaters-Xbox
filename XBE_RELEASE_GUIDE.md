# ROM-free precompiled XBE release

## Package an existing XBE (no rebuild)

In PowerShell, from this source folder:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\MAKE_ROM_FREE_XBE_RELEASE.ps1 -XbePath ".\out\Undead Neighbor Eaters\default.xbe"
```

A source XBE must be explicitly selected with `-XbePath`, or freshly rebuilt with `-Build`. This avoids mistakenly packaging a stale executable.

For an XBE at another path:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\MAKE_ROM_FREE_XBE_RELEASE.ps1 -XbePath 'C:\path\to\default.xbe'
```

## Build and package locally

Place a compatible locally supplied `.sfc`/`.smc` ROM in the repository root, install RXDK, then run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\MAKE_ROM_FREE_XBE_RELEASE.ps1 -Build
```

This builds in the local developer tree, **but only copies the ROM-free XBE** into the public release ZIP. The local build folder contains locally supplied game data; this build folder must **not** be published or any local ISO.

Public ZIP:

```text
out/PUBLIC_ROM_FREE_XBE/Undead_Neighbor_Eaters_Xbox_ROM_FREE_XBE.zip
    Undead Neighbor Eaters/
        default.xbe
        READ_ME_FIRST.txt
        LICENSING.md
        CREDITS.md
        SHA256.txt
        LICENSES/LICENSE-MPL-2.0.txt
        LICENSES/LICENSE-LakeSnes-MIT.txt
```

## End users

1. Extract the ZIP. No RXDK, Windows build, or compiler is required.
2. Provide a compatible original game ROM. Rename it `zamn.sfc` and place next to `default.xbe`.
3. Copy folder to console, e.g. `E:\Games\Undead Neighbor Eaters\` and run `default.xbe`.

The packaged XBE is the compiled port. The game ROM is **not** embedded and remains required at runtime.

## Branding / compatibility

The *packaged copy* of the XBE has its certificate title changed to `Undead Neighbor Eaters` to appear under that name in the Xbox dashboard. The original compiled XBE and code are unchanged; build/protocol, Title ID, netplay identifiers, game saves and cross-play behavior are not deliberately altered. The original in-game SNES title artwork stays original. Run on a modified console and test before public release.

## Rights

Refer to `RELEASE_READINESS.md`. A ROM-free bundle and rename are **not sufficient** to confirm rights to publish compiled upstream-derived game code. Distribution requires that the relevant rights and permissions be established.
