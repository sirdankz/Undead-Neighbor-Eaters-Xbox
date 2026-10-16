# Licensing — Undead Neighbor Eaters (Original Xbox)

This repository contains code from multiple sources subject to different terms. It has no project-wide open-source license. A license applicable to one component does not apply to other components unless expressly stated.

## Original Xbox netplay — MPL 2.0

The original Original Xbox netplay implementation developed for this port is licensed under the Mozilla Public License 2.0 (MPL-2.0), to the extent the project maintainers hold the relevant rights. The designated source files are:

- `src/netplay/netplay_core.c`
- `src/netplay/netplay_core.h`
- `src/platform/xbox/xbox_netplay.cpp`
- `src/platform/xbox/xbox_netplay.h`

The license text is at [`LICENSES/LICENSE-MPL-2.0.txt`](LICENSES/LICENSE-MPL-2.0.txt).

This component-specific license **does not grant rights to upstream-derived gameplay code, the commercial game, or unrelated source files**.

## Upstream PC port — rights not established by this repository

Portions of the runtime and translated gameplay logic are derived from or based on **[Zombies Ate My Neighbors PC Port by Moshferatu](https://github.com/moshferatu/zombies-ate-my-neighbors-pc-port)**. That project did not contain a clear project-wide redistribution license when this port was created. Its public source availability does not itself provide permission to copy, modify, redistribute, or sublicense it. The applicable rights need to be established independently; the MPL notice above cannot grant them.

## LakeSnes — MIT

`third_party/lakesnes/` contains code derived from LakeSnes and its forks, licensed under MIT. Notices are retained in:

- `third_party/lakesnes/LICENSE.txt`
- [`LICENSES/LICENSE-LakeSnes-MIT.txt`](LICENSES/LICENSE-LakeSnes-MIT.txt)

Upstream references: [angelo-wf/LakeSnes](https://github.com/angelo-wf/LakeSnes) and [dinkc64/LakeSnes](https://github.com/dinkc64/LakeSnes). Copyright (c) 2021–2023 angelo_wf and contributors.

## RXDK

The Original Xbox build toolchain, RXDK, is developed by [Team Resurgent](https://github.com/Team-Resurgent). Its toolchain and SDK files are not distributed in this repository; they have their own applicable terms.

## Original game and user-provided materials

*Zombies Ate My Neighbors* was developed by LucasArts and published by Konami. The original game's code, graphics, sounds, music, manual, title and trademarks remain subject to the rights of their respective owners. No commercial ROM or manual scans are included. The runtime requires a separately supplied compatible ROM.

The public-facing project name **Undead Neighbor Eaters** is a community port title, not an assertion of ownership of the original game. Changing a title or omitting a ROM does not determine the copyright status of the ported or compiled code.

Original manual scans and generated reader pages, if used locally, have their own rights and are not included in this source repository. Code licenses do not license that material.

## Disclaimer

Undead Neighbor Eaters is an unofficial fan-made Original Xbox port. It is not affiliated with or endorsed by LucasArts/Lucasfilm Games, Konami, Microsoft, Team Resurgent, LakeSnes contributors, or the upstream PC port. Distribution of source or compiled binaries must comply with the rights applicable to **all** included components. See [`CREDITS.md`](CREDITS.md) and [`RELEASE_READINESS.md`](RELEASE_READINESS.md).
