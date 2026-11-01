# Runs the project's checks without the Godot editor. Close the editor first, or
# it may overwrite these files with its own copies when it next saves.
#   powershell -File tools/run.ps1 smoke          # headless flow test, exit code 1 on failure
#   powershell -File tools/run.ps1 shots [scene]  # rendered screenshots in test_output/
#   powershell -File tools/run.ps1 import         # import new assets only
param(
	[ValidateSet('smoke', 'shots', 'import')][string]$Task = 'smoke',
	[string]$Scene = ''
)

$godot = 'D:\Godot_v4.7.2-stable_win64_console.exe'
$project = Split-Path $PSScriptRoot

& $godot --headless --path $project --import *>&1 | Out-Null
if ($Task -eq 'smoke') {
	& $godot --headless --path $project -s "$PSScriptRoot\smoke.gd" 2>&1 | ForEach-Object { "$_" }
} elseif ($Task -eq 'shots') {
	$sceneArgs = if ($Scene) { @('--', $Scene) } else { @() }
	& $godot --path $project --audio-driver Dummy --resolution 1280x720 -s "$PSScriptRoot\shots.gd" @sceneArgs 2>&1 | ForEach-Object { "$_" }
}
exit $LASTEXITCODE
