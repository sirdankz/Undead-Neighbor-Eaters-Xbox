# Public release readiness — Undead Neighbor Eaters (Original Xbox)

## Technical workflow

The developer builds one XBE locally with RXDK. Other players can then install a **prebuilt `default.xbe`** and add their own compatible SNES ROM as `zamn.sfc`, without compiling anything.

`MAKE_ROM_FREE_XBE_RELEASE.ps1` packages a compiled XBE and deliberately **does not include any ROM, manuals, save files, remastered banks, ISO, private backend, logs, or debug symbols**. It patches only the Xbox dashboard title within the release copy of the XBE certificate; the source executable remains unmodified. The server, title ID, netplay build/protocol, and game/save identifiers are untouched.

**Important:** This does *not* change the game's own original title graphic, which comes from the user's SNES ROM. Updating the Xbox dashboard's title is not equivalent to replacing copyrighted ROM graphics.

## Source and code rights — blocker before a public download

Neither a ROM-free XBE nor the project rename automatically grants the right to distribute compiled code. The repository includes substantial translated/native game logic derived from the upstream Moshferatu PC port. That upstream project's repository had no clear project-wide redistribution license at the time of this release documentation. Separately, the copyright status of code derived from the original game's program needs review. Secure explicit permission where necessary or obtain qualified legal advice before publishing the complete binary or source.

MPL 2.0 applies **only to the specifically identified Xbox netplay source files**, not the entire project. LakeSnes is subject to its preserved MIT notice. `LICENSING.md` and `CREDITS.md` must accompany source and binary releases. The `LICENSES/LICENSE-MPL-2.0.txt` file was added to match the already-existing MPL 2.0 notice. This inclusion **does not** relicense upstream game code.

## Release QA checklist

- [ ] Rights/permissions for upstream-derived and translated code established; attribution complete.
- [ ] Build Release on Windows using RXDK; no diagnostic logging.
- [ ] Test same build on a real modified Original Xbox, including offline and Android ↔ Xbox netplay.
- [ ] Run `MAKE_ROM_FREE_XBE_RELEASE.ps1` on the developer's machine to create public ZIP.
- [ ] Check ZIP `default.xbe`, `READ_ME_FIRST.txt`, notices, hashes, and **no ROM**.
- [ ] Verify Xbox dashboard displays `Undead Neighbor Eaters`; check that re-saved XBE certificate is accepted on target device. Keep a backup of the original XBE for rollback.
- [ ] Test user-added `zamn.sfc` ROM beside XBE and enhanced audio.
- [ ] Check online account infrastructure capacity and privacy requirements for public access.
- [ ] Publish a matching GitHub release note, SHA-256, supported version and compatibility statement.

**Validation scope:** The ROM-free XBE packaging workflow has been exercised with a working build on a modified Original Xbox. Other builds and target consoles require independent validation. Rights clearance is separate from technical test success.
