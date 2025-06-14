param(
    [Parameter(Position=0)]
    [int]$maxNumber = 2500,

    [Parameter(Position=1)]
    [ValidateSet("All", "FirstLast", "None")]
    [string]$OutputMode = "None",

    [Parameter()]
    [switch]$Help
)

function Show-Help {
    Write-Host @"
speedtest.ps1 - paralelní výpočet 9x^4 + 4x^3 - 5x^2 + 48x - 63

Parametry:
  maxNumber    - kolik čísel se má spočítat (výchozí: 2500)
  OutputMode   - režim výpisu výsledků: All, FirstLast, None (výchozí: None)
  -Help, -?, /?, /help - zobrazí tuto nápovědu

Příklad použití:
  powershell -File speedtest.ps1 25000 FirstLast
  powershell -File speedtest.ps1 -maxNumber 10000 -OutputMode None
"@
}

# Kontrola help parametrů
if ($Help -or $args -contains "/?" -or $args -contains "-?" -or $args -contains "/help" -or $args -contains "-help") {
    Show-Help
    exit 0
}

$jobsCount = [Environment]::ProcessorCount
$rangeSize = [math]::Ceiling($maxNumber / $jobsCount)

$scriptBlock = {
    param($startRange, $endRange)
    $results = @()
    for ($x = $startRange; $x -le $endRange; $x++) {
        $y = 9 * [math]::Pow($x,4) + 4 * [math]::Pow($x,3) - 5 * [math]::Pow($x,2) + 48 * $x - 63
        $results += [PSCustomObject]@{X=$x; Y=$y}
    }
    return $results
}

$jobs = @()
for ($i = 0; $i -lt $jobsCount; $i++) {
    $startRange = [int]($i * $rangeSize + 1)
    $endRange = [int][math]::Min($startRange + $rangeSize - 1, $maxNumber)
    $jobs += Start-Job -ScriptBlock $scriptBlock -ArgumentList $startRange, $endRange
}

# ⏱️ Měření času začíná až TEĎ
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

$allResults = @()
foreach ($job in $jobs) {
    $allResults += Receive-Job -Job $job -Wait
    Remove-Job -Job $job
}

$stopwatch.Stop()

switch ($OutputMode) {
    "All" {
        $allResults | ForEach-Object { Write-Host "[$($_.X) ; $($_.Y)]" }
    }
    "FirstLast" {
        if ($allResults.Count -gt 0) {
            Write-Host "[$($allResults[0].X) ; $($allResults[0].Y)]"
            if ($allResults.Count -gt 1) {
                Write-Host "[$($allResults[-1].X) ; $($allResults[-1].Y)]"
            }
        }
    }
    "None" {
        # Nevypsat nic
    }
}

# ✅ Výstup jen číslo s 5 desetinnými místy
"{0:N5}" -f $stopwatch.Elapsed.TotalSeconds
