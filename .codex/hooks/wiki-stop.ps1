param()

$ErrorActionPreference = "Stop"
$inputText = [Console]::In.ReadToEnd()
$hookInput = $null
if ($inputText.Trim()) {
    try { $hookInput = $inputText | ConvertFrom-Json } catch { $hookInput = $null }
}

$repoRoot = "D:\SPPPAAACCCEEE\Contrail"
$validator = Join-Path $repoRoot ".agents\skills\wiki-finalize\scripts\validate-wiki.ps1"
$resultText = & $validator -Root $repoRoot -AsJson
$result = $resultText | ConvertFrom-Json

if (-not $result.ok) {
    $summary = "Contrail Wiki validation failed: " + (($result.errors | Select-Object -First 5) -join "; ")
    if ($hookInput -and $hookInput.stop_hook_active) {
        @{ systemMessage = $summary } | ConvertTo-Json -Compress
    } else {
        @{ decision = "block"; reason = $summary + ". Fix in-scope errors, then run wiki-finalize again." } | ConvertTo-Json -Compress
    }
    exit 0
}

if ($result.warnings.Count -gt 0) {
    @{ systemMessage = ("Contrail Wiki validation warnings: " + (($result.warnings | Select-Object -First 5) -join "; ")) } | ConvertTo-Json -Compress
} else {
    @{} | ConvertTo-Json -Compress
}
