param(
    [string]$LegacyRoot = "$env:USERPROFILE\Contacts\RealZMNrelease",
    [string]$RomPath = '',
    [string]$ManualFolder = '',
    [switch]$NoExplorer
)

$ErrorActionPreference='Stop'
$root=Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $root

# The release ZIP is deliberately built in a new extracted source directory.
# Reusing old out\\ directories is prohibited: it silently selected an R49.9.7 XBE.
if (Test-Path -LiteralPath (Join-Path $root 'out\Release')) {
    throw 'This is not a clean extracted source folder. Extract this ZIP into a NEW, empty directory.'
}

$expected=@(
    'src\platform\xbox\xbox_main.cpp',
    'src\platform\xbox\xbox_title_online.h',
    'src\platform\xbox\xbox_d3d.cpp',
    'BUILD_XBOX_RELEASE.ps1',
    'MAKE_ROM_FREE_XBE_RELEASE.ps1',
    'rxdk.project.json'
)
foreach ($f in $expected) {
    if (!(Test-Path -LiteralPath (Join-Path $root $f))) { throw "Source missing: $f" }
}
$main = [IO.File]::ReadAllText((Join-Path $root 'src\platform\xbox\xbox_main.cpp'))
if (!$main.Contains('"GAME MANUAL"') -or !$main.Contains('R71_ShowGameManual')) {
    throw 'The extracted source does not contain the expected GAME MANUAL menu implementation.'
}

$oldRoot=[IO.Path]::GetFullPath($LegacyRoot)
if (!(Test-Path -LiteralPath $oldRoot -PathType Container)) {
    throw "Existing Xbox workspace not found: $oldRoot. Specify -LegacyRoot or -RomPath."
}

if ([string]::IsNullOrWhiteSpace($RomPath)) {
    # Search only the specified older local workspace; do not search Downloads or
    # the system for ROMs. This copies a ROM already held by the user.
    $found=@(Get-ChildItem -LiteralPath $oldRoot -File -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.Extension -in @('.sfc','.smc') } |
        Sort-Object @{Expression={if ($_.Length -eq 1048576) {0} else {1}}},
                    @{Expression={if ($_.Name -ieq 'zamn.sfc') {0} else {1}}},
                    @{Expression={if ($_.Name -match 'Zombies.*Neighbors') {0} else {1}}})
    if (!$found.Count) { throw "No locally provided .sfc/.smc found in $oldRoot. Supply -RomPath to your own ROM." }
    $RomPath=$found[0].FullName
}
if (!(Test-Path -LiteralPath $RomPath -PathType Leaf)) { throw "ROM file not found: $RomPath" }
Write-Host "Using locally provided ROM: $RomPath" -ForegroundColor Cyan
Copy-Item -LiteralPath $RomPath -Destination (Join-Path $root 'zamn.sfc') -Force

# Manual contents remain entirely user-local, and are never in public release.
# Prefer the original book/10 converted spreads from the old workspace when available.
$manualOut = Join-Path $root 'manual'
$manualSource = $null
if ($ManualFolder) {
    if (!(Test-Path -LiteralPath $ManualFolder -PathType Container)) { throw "Manual folder not found: $ManualFolder" }
    $manualSource = $ManualFolder
} else {
    foreach($candidate in @(
        (Join-Path $oldRoot 'manual'),
        (Join-Path $oldRoot 'out\Zombies Ate My Neighbors!\manual'),
        (Join-Path $oldRoot 'out\Undead Neighbor Eaters\manual')
    )) {
        if (Test-Path -LiteralPath $candidate -PathType Container) {
            $items=@(Get-ChildItem -LiteralPath $candidate -File -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -in @('Zombies Ate My Neighbors.pdf','Zombies Ate My Neighbors.epub','spread00.rgb565') })
            if ($items.Count) { $manualSource=$candidate; break }
        }
    }
}
if ($manualSource) {
    Write-Host "Using optional user-supplied manual assets from: $manualSource" -ForegroundColor Cyan
    foreach($asset in @('Zombies Ate My Neighbors.pdf','Zombies Ate My Neighbors.epub') +
                       @(0..9 | ForEach-Object { 'spread{0:D2}.rgb565' -f $_ })) {
        $p=Join-Path $manualSource $asset
        if (Test-Path -LiteralPath $p -PathType Leaf) { Copy-Item -LiteralPath $p -Destination $manualOut -Force }
    }
} else {
    Write-Host 'No manual booklet/scans found. GAME MANUAL will appear but not open without all ten spreads.' -ForegroundColor Yellow
}

Write-Host 'Building the latest source with RXDK (fresh output)...' -ForegroundColor Cyan
& (Join-Path $root 'BUILD_XBOX_RELEASE.ps1') -NoExplorer
if (!$?) { throw 'BUILD_XBOX_RELEASE.ps1 did not complete successfully.' }
$freshXbe=Join-Path $root 'out\Undead Neighbor Eaters\default.xbe'
if (!(Test-Path -LiteralPath $freshXbe -PathType Leaf)) { throw "Fresh build XBE missing: $freshXbe" }
Write-Host "Fresh XBE: $freshXbe" -ForegroundColor Green

# Explicit path prevents picking an older R49 XBE from a previous build.
& (Join-Path $root 'MAKE_ROM_FREE_XBE_RELEASE.ps1') -XbePath $freshXbe -NoExplorer
if (!$?) { throw 'ROM-free XBE packaging failed.' }
Write-Host 'DONE: Full current Xbox build + verified ROM-free package.' -ForegroundColor Green
if (!$NoExplorer) {
    Start-Process explorer.exe (Join-Path $root 'out\PUBLIC_ROM_FREE_XBE')
}
