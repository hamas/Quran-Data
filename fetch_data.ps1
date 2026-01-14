$translations = @(
    @{ id = "en_sahih"; apiId = "en.sahih"; name = "English"; translator = "Sahih International"; direction = "ltr" },
    @{ id = "ur_jalandhry"; apiId = "ur.jalandhry"; name = "Urdu"; translator = "Jalandhry"; direction = "rtl" },
    @{ id = "fr_hamidullah"; apiId = "fr.hamidullah"; name = "French"; translator = "Hamidullah"; direction = "ltr" },
    @{ id = "id_indonesian"; apiId = "id.indonesian"; name = "Indonesian"; translator = "Ministry of Religion"; direction = "ltr" },
    @{ id = "ru_kuliev"; apiId = "ru.kuliev"; name = "Russian"; translator = "Kuliev"; direction = "ltr" }
)

$outputDir = "translations"
if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Force -Path $outputDir }

$index = @()

foreach ($t in $translations) {
    $filename = "$($t.id).json"
    $filepath = Join-Path $outputDir $filename
    Write-Host "Fetching $($t.name) from AlQuran.cloud..."
    
    $url = "http://api.alquran.cloud/v1/quran/$($t.apiId)"
    try {
        $response = Invoke-RestMethod -Uri $url
        $surahs = $response.data.surahs
        $quranList = @()

        foreach ($surah in $surahs) {
            foreach ($ayah in $surah.ayahs) {
                $quranList += @{
                    chapter = $surah.number
                    verse   = $ayah.numberInSurah
                    text    = $ayah.text
                }
            }
        }

        $finalJson = @{ quran = $quranList } | ConvertTo-Json -Depth 5
        Set-Content -Path $filepath -Value $finalJson -Encoding UTF8
        
        # Add to index
        $index += @{
            id         = $t.id
            name       = $t.name
            translator = $t.translator
            direction  = $t.direction
            url        = "https://raw.githubusercontent.com/hamas/Quran-Data/main/translations/$filename"
        }
    }
    catch {
        Write-Host "Failed to fetch $($t.id): $_"
    }
}

$indexJson = $index | ConvertTo-Json -Depth 5
Set-Content -Path "languages.json" -Value $indexJson

Write-Host "Done. Languages.json updated."
