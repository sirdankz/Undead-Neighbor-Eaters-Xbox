param(
    [string]$XbePath = '',
    [switch]$Build,
    [switch]$NoExplorer
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $root
$releaseName = 'Undead Neighbor Eaters'
$outRoot = Join-Path $root 'out'
$pubRoot = Join-Path $outRoot 'PUBLIC_ROM_FREE_XBE'
$stage = Join-Path $pubRoot $releaseName
$zipPath = Join-Path $pubRoot 'Undead_Neighbor_Eaters_Xbox_ROM_FREE_XBE.zip'

if ($Build) {
    Write-Host 'Building the Xbox XBE using your locally supplied ROM and RXDK...' -ForegroundColor Cyan
    & (Join-Path $root 'BUILD_XBOX_RELEASE.ps1') -NoExplorer
    if ($LASTEXITCODE -and $LASTEXITCODE -ne 0) { throw 'Xbox build failed.' }
    $XbePath = Join-Path $outRoot 'Undead Neighbor Eaters\default.xbe'
}

# Public release safety: never silently select an arbitrary older compiled binary.
# Use -Build for a fresh local build or explicitly identify an already compiled XBE.
if ([string]::IsNullOrWhiteSpace($XbePath)) {
    throw 'No XBE selected. Use -Build to compile the current source or -XbePath to name a known-good build explicitly.'
}

if (!(Test-Path -LiteralPath $XbePath -PathType Leaf)) { throw "XBE does not exist: $XbePath" }
$source = (Resolve-Path -LiteralPath $XbePath).Path
if ($source.StartsWith($pubRoot + [IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) {
    throw 'Do not use an existing staged public XBE as a source; use the original compiled build.'
}

# Verify the *source* XBE before touching output folders. The marker is stored
# as ASCII because the menu draws it via a C-string label.
# Reading $source here also prevents accidental reuse of uninitialized $data.
[byte[]]$data = [IO.File]::ReadAllBytes($source)
if ($data.Length -lt 0x200 -or [Text.Encoding]::ASCII.GetString($data, 0, 4) -cne 'XBEH') {
    throw "Invalid Original Xbox XBE header: $source"
}
$manualMarker = [Text.Encoding]::ASCII.GetBytes('GAME MANUAL')
$hasManual = $false
for ($i = 0; $i -le $data.Length - $manualMarker.Length; ++$i) {
    if ($data[$i] -ne $manualMarker[0]) { continue }
    $matches = $true
    for ($j = 1; $j -lt $manualMarker.Length; ++$j) {
        if ($data[$i + $j] -ne $manualMarker[$j]) { $matches = $false; break }
    }
    if ($matches) { $hasManual = $true; break }
}
if (!$hasManual) {
    throw "XBE does not contain the GAME MANUAL menu label: $source. Verify the XBE came from a current clean source build."
}
Write-Host 'Verified: XBE contains the compiled GAME MANUAL title label.' -ForegroundColor Green

# Never copy user ROMs, title cache, private saves, or manual scans to the public package.
if (Test-Path -LiteralPath $stage) { Remove-Item -LiteralPath $stage -Recurse -Force }
New-Item -Path $stage -ItemType Directory -Force | Out-Null
$destXbe = Join-Path $stage 'default.xbe'
Copy-Item -LiteralPath $source -Destination $destXbe -Force

# XBE certificate title is UTF-16LE, at certificate address + 0x0C.
# Patch the staging COPY only. Keep title ID and every other certificate field unchanged.
# Reload the staging copy before applying the dashboard-title patch.
[byte[]]$data = [IO.File]::ReadAllBytes($destXbe)
if ($data.Length -lt 0x200 -or [Text.Encoding]::ASCII.GetString($data,0,4) -cne 'XBEH') {
    throw "Invalid XBE header; not a compiled Original Xbox executable: $source"
}
[long]$base = [BitConverter]::ToUInt32($data,0x104)
[long]$certificateVa = [BitConverter]::ToUInt32($data,0x118)
[long]$certificateOffset = $certificateVa - $base
if ($certificateOffset -lt 0x178 -or ($certificateOffset + 0x5C) -gt $data.Length) {
    throw "XBE certificate virtual address is not within the file (base=$base cert=$certificateVa)."
}
[uint32]$certSize = [BitConverter]::ToUInt32($data,[int]$certificateOffset)
if ($certSize -lt 0x5C -or ($certificateOffset + $certSize) -gt $data.Length) {
    throw "XBE certificate size is invalid: $certSize"
}
$titleBytes = [Text.Encoding]::Unicode.GetBytes($releaseName)
if ($titleBytes.Length -gt 78) { throw 'Title too long for XBE certificate.' }
[Array]::Clear($data,[int]($certificateOffset + 0x0C),80)
[Array]::Copy($titleBytes,0,$data,[int]($certificateOffset + 0x0C),$titleBytes.Length)
[IO.File]::WriteAllBytes($destXbe,$data)
$embedded = [Text.Encoding]::Unicode.GetString($data,[int]($certificateOffset + 0x0C),80).TrimEnd([char]0)
if ($embedded -cne $releaseName) { throw "XBE title verification failed ($embedded)" }

$playerReadme = @'
Undead Neighbor Eaters — Original Xbox (ROM-free release)

This package does not contain the commercial game ROM, soundtrack,
manual pages, or other game data files.

INSTALLATION
1. Use your own compatible USA Zombies Ate My Neighbors SNES ROM.
2. Rename your local ROM to: zamn.sfc
3. Put zamn.sfc in this folder, beside default.xbe.
4. Copy the whole folder to your modded Original Xbox, for example:
     E:\Games\Undead Neighbor Eaters\
5. Launch default.xbe through your dashboard.

A modded Original Xbox capable of running homebrew XBEs is required.
The developer used Team Resurgent RXDK to compile the XBE, but players do not
need RXDK or any build tools.

Dashboard title: Undead Neighbor Eaters
Game data and original in-game title are supplied by your ROM.
The homebrew XBE certificate title has been changed only for the staged ZIP.

This unofficial project is not affiliated with or endorsed by the original
rights holders. See LICENSING.md and CREDITS.md for code provenance.

Do not upload ROMs, original instruction scans, or imported soundtrack banks.
'@
[IO.File]::WriteAllText((Join-Path $stage 'READ_ME_FIRST.txt'),$playerReadme, (New-Object Text.UTF8Encoding($false)))
foreach ($file in @('CREDITS.md','LICENSING.md')) {
    $path = Join-Path $root $file
    if (!(Test-Path -LiteralPath $path)) { throw "Required release notice not found: $path" }
    Copy-Item -LiteralPath $path -Destination $stage
}
$licenseOut = Join-Path $stage 'LICENSES'
New-Item -Path $licenseOut -ItemType Directory -Force | Out-Null
foreach ($file in @('LICENSE-MPL-2.0.txt','LICENSE-LakeSnes-MIT.txt')) {
    $path = Join-Path $root (Join-Path 'LICENSES' $file)
    if (!(Test-Path -LiteralPath $path)) { throw "Required license file not found: $path" }
    Copy-Item -LiteralPath $path -Destination $licenseOut
}

# Defense-in-depth denylist: no ROM, manual, save, user secret or bank material.
$forbidden = @(Get-ChildItem -LiteralPath $stage -Recurse -File | Where-Object {
    $_.Extension -match '^(?i:\.(sfc|smc|zip|iso|pdf|epub|rgb565|zsb|zsv|key|pem|pfx|p12|log))$'
})
if ($forbidden.Count -gt 0) { throw ('Forbidden release files: ' + ($forbidden.FullName -join ', ')) }
$xbeHash = (Get-FileHash -LiteralPath $destXbe -Algorithm SHA256).Hash
[IO.File]::WriteAllText((Join-Path $stage 'SHA256.txt'),("SHA256 default.xbe: {0}`r`n" -f $xbeHash),(New-Object Text.UTF8Encoding($false)))
New-Item -Path $pubRoot -ItemType Directory -Force | Out-Null
if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force }
Compress-Archive -Path $stage -DestinationPath $zipPath -CompressionLevel Optimal -Force
if (!(Test-Path -LiteralPath $zipPath)) { throw 'ZIP creation failed.' }
Write-Host "Xbox dashboard title: $embedded" -ForegroundColor Green
Write-Host "Source XBE (unchanged): $source" -ForegroundColor Green
Write-Host "ROM-FREE PUBLIC ZIP: $zipPath" -ForegroundColor Green
Write-Host "Staged XBE SHA-256: $xbeHash" -ForegroundColor Green
Write-Host 'No game ROM, original manual, or optional game data included.' -ForegroundColor Green
Write-Warning 'Packaging does not grant redistribution rights. Read RELEASE_READINESS.md and verify permissions before publishing.'
if (!$NoExplorer) { Start-Process explorer.exe $pubRoot }
