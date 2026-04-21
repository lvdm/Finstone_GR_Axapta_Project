param(
    [string]$XpoPath = (Join-Path $PSScriptRoot "..\\SharedProject_FIN_GroupReporting.xpo"),
    [string]$OutputRoot = (Join-Path $PSScriptRoot "..\\src")
)

$ErrorActionPreference = "Stop"

$XpoPath = [System.IO.Path]::GetFullPath($XpoPath)
$OutputRoot = [System.IO.Path]::GetFullPath($OutputRoot)

$folders = @(
    "reports",
    "menus",
    "menuitems",
    "classes",
    "forms",
    "tables",
    "enums",
    "jobs",
    "projects",
    "types"
)

foreach ($folder in $folders) {
    $path = Join-Path $OutputRoot $folder
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
    }
}

$lines = Get-Content -Path $XpoPath
$objects = New-Object System.Collections.Generic.List[object]

function Write-ObjectFile {
    param(
        [string]$Folder,
        [string]$Name,
        [string[]]$Block
    )

    $safeName = ($Name -replace '[<>:"/\\|?*]', '_')
    $outPath = Join-Path (Join-Path $OutputRoot $Folder) ($safeName + ".xpo")
    Set-Content -Path $outPath -Value $Block -Encoding UTF8
    return $outPath
}

for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]

    if ($line -match '^\s*;\s+Microsoft Dynamics Job:\s+([^\r\n]+?)\s+unloaded\s*$') {
        $name = $Matches[1].Trim()
        $start = $i
        $j = $i + 1

        while ($j -lt $lines.Count -and $lines[$j].Trim() -ne 'ENDSOURCE') {
            $j++
        }

        if ($j -ge $lines.Count) {
            throw "End token ENDSOURCE not found for JOB $name"
        }

        $outPath = Write-ObjectFile -Folder "jobs" -Name $name -Block $lines[$start..$j]
        $objects.Add([pscustomobject]@{ Type = "JOB"; Name = $name; Path = $outPath }) | Out-Null
        $i = $j
        continue
    }

    if ($line -match '^\s{0,2}(REPORT|MENUITEM|CLASS|FORM|TABLE|ENUMTYPE|JOB|PROJECT|MENU)\s+#([^\r\n]+)$') {
        $kind = $Matches[1]
        $name = $Matches[2].Trim()
        $endToken = switch ($kind) {
            "ENUMTYPE" { "ENDENUMTYPE" }
            default { "END$kind" }
        }

        $j = $i + 1
        if ($kind -eq "MENU") {
            $depth = 1
            while ($j -lt $lines.Count -and $depth -gt 0) {
                if ($lines[$j] -match '^\s*MENU\s+#') {
                    $depth++
                } elseif ($lines[$j].Trim() -eq "ENDMENU") {
                    $depth--
                }
                $j++
            }
            $j--
        } else {
            while ($j -lt $lines.Count -and $lines[$j].Trim() -ne $endToken) {
                $j++
            }
        }

        if ($j -ge $lines.Count) {
            throw "End token $endToken not found for $kind $name"
        }

        $folder = switch ($kind) {
            "REPORT" { "reports" }
            "MENU" { "menus" }
            "MENUITEM" { "menuitems" }
            "CLASS" { "classes" }
            "FORM" { "forms" }
            "TABLE" { "tables" }
            "ENUMTYPE" { "enums" }
            "JOB" { "jobs" }
            "PROJECT" { "projects" }
        }

        $outPath = Write-ObjectFile -Folder $folder -Name $name -Block $lines[$i..$j]
        $objects.Add([pscustomobject]@{ Type = $kind; Name = $name; Path = $outPath }) | Out-Null
        $i = $j
        continue
    }

    if ($line -match '^\s{0,2}USERTYPE\s+#([^\r\n]+)$') {
        $name = $Matches[1].Trim()

        $j = $i + 1
        while ($j -lt $lines.Count -and $lines[$j].Trim() -ne 'ENDUSERTYPE') {
            $j++
        }

        if ($j -ge $lines.Count) {
            throw "End token ENDUSERTYPE not found for USERTYPE $name"
        }

        $outPath = Write-ObjectFile -Folder "types" -Name $name -Block $lines[$i..$j]
        $objects.Add([pscustomobject]@{ Type = "USERTYPE"; Name = $name; Path = $outPath }) | Out-Null
        $i = $j
    }
}

$objects | Sort-Object Type, Name | Format-Table -AutoSize
