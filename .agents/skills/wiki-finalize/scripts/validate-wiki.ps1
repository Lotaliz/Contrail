param(
    [string]$Root = "",
    [switch]$AsJson
)

$ErrorActionPreference = "Stop"
$errors = [System.Collections.Generic.List[string]]::new()
$warnings = [System.Collections.Generic.List[string]]::new()

if (-not $Root) {
    $cursor = Get-Item -LiteralPath ([IO.Path]::GetFullPath((Get-Location).Path))
    while ($cursor) {
        if (Test-Path -LiteralPath (Join-Path $cursor.FullName "LLM-Wiki") -PathType Container) {
            $Root = $cursor.FullName
            break
        }
        $cursor = $cursor.Parent
    }
    if (-not $Root) { $Root = (Get-Location).Path }
}

$Root = [IO.Path]::GetFullPath($Root)
$wiki = Join-Path $Root "LLM-Wiki"
if (-not (Test-Path -LiteralPath $wiki -PathType Container)) {
    $errors.Add("LLM-Wiki directory not found at $wiki")
}

function Get-Frontmatter {
    param([string]$Text)
    $match = [regex]::Match($Text, "\A---\r?\n(?<fm>.*?)\r?\n---", [Text.RegularExpressions.RegexOptions]::Singleline)
    if (-not $match.Success) { return $null }
    return $match.Groups["fm"].Value
}

function Get-Scalar {
    param([string]$Frontmatter, [string]$Key)
    $match = [regex]::Match($Frontmatter, "(?m)^" + [regex]::Escape($Key) + ":\s*(?<v>[^\r\n#]*)")
    if (-not $match.Success) { return $null }
    return $match.Groups["v"].Value.Trim().Trim('"').Trim("'")
}

$required = @{
    "concept" = @("id","type","category","title","tags","status","created","updated")
    "index" = @("id","type","title","tags","status")
    "metadata" = @("id","type","title","tags","status")
    "source-note" = @("id","type","title","tags","source_id","status","created","updated")
    "paper-note" = @("id","type","title","tags","source_id","reading_level","verification","status","created","updated")
    "experiment" = @("id","type","title","tags","status","created","updated")
    "research-overview" = @("id","type","title","tags","status","created","updated")
    "synthesis" = @("id","type","title","tags","project_id","sources","status","created","updated")
    "change" = @("id","type","title","tags","date","change_type")
}
$allowedStatuses = @("seed","draft","active","deprecated","archived")
$allowedLevels = @("discovered","skimmed","deep-read")
$allowedVerification = @("unverified","source-checked","reproduced")

$sourceRegistry = Join-Path $wiki "raw\sources.yaml"
$sourceText = if (Test-Path -LiteralPath $sourceRegistry) { Get-Content -LiteralPath $sourceRegistry -Raw } else { "" }
$sourceIds = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($m in [regex]::Matches($sourceText, "(?m)^\s{2}- id:\s*['""]?(?<id>[^'""\r\n#]+)")) {
    $id = $m.Groups["id"].Value.Trim()
    if (-not $sourceIds.Add($id)) { $errors.Add("Duplicate source id: $id") }
}
$registeredPaths = [System.Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
foreach ($m in [regex]::Matches($sourceText, "(?m)^\s+local_path:\s*['""]?(?<p>[^'""\r\n#]+)")) {
    [void]$registeredPaths.Add(($m.Groups["p"].Value.Trim() -replace "\\","/"))
}

if (Test-Path -LiteralPath $wiki) {
    $mdFiles = Get-ChildItem -LiteralPath $wiki -Recurse -File -Filter "*.md"
    foreach ($file in $mdFiles) {
        $rel = $file.FullName.Substring($Root.Length + 1) -replace "\\","/"
        if ($rel -like "LLM-Wiki/templates/*") { continue }

        $text = Get-Content -LiteralPath $file.FullName -Raw
        $fm = Get-Frontmatter $text
        $requiresFrontmatter = $rel -like "LLM-Wiki/concepts/*" -or $rel -like "LLM-Wiki/research/*/*.md" -or $rel -like "LLM-Wiki/research/*/papers/*"
        if (-not $fm) {
            if ($requiresFrontmatter) { $errors.Add("${rel}: missing frontmatter") }
            continue
        }

        $type = Get-Scalar $fm "type"
        if (-not $type) {
            $errors.Add("${rel}: missing type")
            continue
        }
        if (-not $required.ContainsKey($type)) {
            $warnings.Add("${rel}: unknown document type '$type'")
        } else {
            foreach ($key in $required[$type]) {
                $value = Get-Scalar $fm $key
                if ($null -eq $value -or $value -eq "") { $errors.Add("${rel}: missing required field '$key'") }
            }
        }

        $status = Get-Scalar $fm "status"
        if ($status -and $status -notin $allowedStatuses) { $errors.Add("${rel}: invalid status '$status'") }

        if ($type -eq "paper-note") {
            $level = Get-Scalar $fm "reading_level"
            $verification = Get-Scalar $fm "verification"
            $sourceId = Get-Scalar $fm "source_id"
            if ($level -and $level -notin $allowedLevels) { $errors.Add("${rel}: invalid reading_level '$level'") }
            if ($verification -and $verification -notin $allowedVerification) { $errors.Add("${rel}: invalid verification '$verification'") }
            if ($sourceId -and -not $sourceIds.Contains($sourceId)) { $errors.Add("${rel}: source_id '$sourceId' not found in raw/sources.yaml") }
        }

        $linkText = [regex]::Replace($text, '(?s)```.*?```', '')
        $linkText = [regex]::Replace($linkText, '`[^`\r\n]*`', '')
        foreach ($link in [regex]::Matches($linkText, "\[\[(?<target>[^\]|#]+)")) {
            $target = $link.Groups["target"].Value.Trim() -replace "\\$",""
            if (-not $target -or $target -match "^[a-z]+://") { continue }
            if ($target -like "LLM-Wiki/*") { $candidate = Join-Path $Root ($target -replace "/","\") }
            else { $candidate = Join-Path $file.DirectoryName ($target -replace "/","\") }
            if (-not [IO.Path]::GetExtension($candidate)) { $candidate += ".md" }
            if (-not (Test-Path -LiteralPath $candidate)) { $warnings.Add("${rel}: unresolved WikiLink '$target'") }
        }
    }

    $papers = Join-Path $wiki "raw\papers"
    if (Test-Path -LiteralPath $papers) {
        foreach ($paper in Get-ChildItem -LiteralPath $papers -File | Where-Object Name -ne ".gitkeep") {
            $relRaw = "papers/" + $paper.Name
            if (-not $registeredPaths.Contains($relRaw)) { $errors.Add("raw/$relRaw is not registered in raw/sources.yaml") }
        }
    }

    $changelogPath = Join-Path $wiki "CHANGELOG.md"
    if (-not (Test-Path -LiteralPath $changelogPath -PathType Leaf)) {
        $errors.Add("LLM-Wiki/CHANGELOG.md is missing")
    } else {
        $changelogText = Get-Content -LiteralPath $changelogPath -Raw
        if ($changelogText -match "(?m)^##\s+Unreleased\s*$") {
            $errors.Add("CHANGELOG must not contain an Unreleased section")
        }

        $dateMatches = [regex]::Matches($changelogText, "(?m)^##\s+(?<date>\d{4}-\d{2}-\d{2})\s*$")
        if ($dateMatches.Count -eq 0) {
            $errors.Add("CHANGELOG has no dated section")
        } else {
            $dates = @($dateMatches | ForEach-Object { [datetime]::ParseExact($_.Groups["date"].Value, "yyyy-MM-dd", $null) })
            for ($i = 1; $i -lt $dates.Count; $i++) {
                if ($dates[$i] -gt $dates[$i - 1]) {
                    $errors.Add("CHANGELOG date sections are not ordered newest first")
                    break
                }
            }
        }

        foreach ($line in ($changelogText -split "\r?\n")) {
            if ($line -match "^##\s+" -and $line -notmatch "^##\s+\d{4}-\d{2}-\d{2}\s*$") {
                $errors.Add("Invalid CHANGELOG section heading: $line")
            }
            if ($line -match "^- \[" -and $line -notmatch "^- \[(Added|Changed|Fixed|Deprecated|Removed)\] \[[^\]]+\] \S.+$") {
                $errors.Add("Invalid CHANGELOG entry format: $line")
            }
        }

        $changesDir = Join-Path $wiki "changes"
        if (Test-Path -LiteralPath $changesDir) {
            foreach ($changeFile in Get-ChildItem -LiteralPath $changesDir -File -Filter "*.md") {
                $needle = "LLM-Wiki/changes/" + $changeFile.Name
                if (-not $changelogText.Contains($needle)) {
                    $warnings.Add("Detailed change note is not linked from CHANGELOG: $needle")
                }
            }
        }
    }
}

$result = [ordered]@{
    ok = ($errors.Count -eq 0)
    errors = @($errors)
    warnings = @($warnings)
    checked_at = (Get-Date).ToString("s")
}
if ($AsJson) {
    $result | ConvertTo-Json -Depth 4 -Compress
} else {
    Write-Output ("Wiki validation: " + $(if ($result.ok) { "PASS" } else { "FAIL" }))
    foreach ($item in $errors) { Write-Output ("ERROR: " + $item) }
    foreach ($item in $warnings) { Write-Output ("WARN: " + $item) }
    Write-Output ("Errors: " + $errors.Count + "; Warnings: " + $warnings.Count)
}
if ($errors.Count -gt 0) { exit 1 }
