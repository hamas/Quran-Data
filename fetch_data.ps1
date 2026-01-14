$translations = @(
    @{ id = "en_sahih"; apiId = "en.sahih"; code = "en"; name = "English"; translator = "Sahih International"; direction = "ltr" },
    @{ id = "ur_jalandhry"; apiId = "ur.jalandhry"; code = "ur"; name = "Urdu"; translator = "Jalandhry"; direction = "rtl" },
    @{ id = "fr_hamidullah"; apiId = "fr.hamidullah"; code = "fr"; name = "French"; translator = "Hamidullah"; direction = "ltr" },
    @{ id = "id_indonesian"; apiId = "id.indonesian"; code = "id"; name = "Indonesian"; translator = "Ministry of Religion"; direction = "ltr" },
    @{ id = "ru_kuliev"; apiId = "ru.kuliev"; code = "ru"; name = "Russian"; translator = "Kuliev"; direction = "ltr" }
)

$transDir = "translations"
$infoDir = "info"
if (-not (Test-Path $transDir)) { New-Item -ItemType Directory -Force -Path $transDir }
if (-not (Test-Path $infoDir)) { New-Item -ItemType Directory -Force -Path $infoDir }

$index = @()

foreach ($t in $translations) {
    # 1. Fetch Translation (Verses)
    $filename = "$($t.id).json"
    $filepath = Join-Path $transDir $filename
    
    # Only fetch if size is small (error) or forced. Assuming we want to ensure latest.
    Write-Host "Fetching Translation $($t.name) from AlQuran.cloud..."
    
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
        
        # 2. Fetch Chapters Info (Surah Names) from Quran.com
        $chapterPath = Join-Path $infoDir "$($t.code)_chapters.json"
        
        Write-Host "Fetching Chapters Info for $($t.code) from Quran.com..."
        try {
            $cUrl = "http://api.quran.com/api/v4/chapters?language=$($t.code)"
            $cResponse = Invoke-RestMethod -Uri $cUrl
            # Response: { chapters: [ { id:1, translated_name: { "name": "..." } } ] }
             
            # Transform to simple list: [ { id:1, name: "..." } ... ]
            $chaptersList = @()
            foreach ($c in $cResponse.chapters) {
                $chaptersList += @{
                    id   = $c.id
                    name = $c.translated_name.name
                }
            }
             
            $chaptersJson = $chaptersList | ConvertTo-Json -Depth 5
            Set-Content -Path $chapterPath -Value $chaptersJson -Encoding UTF8
        }
        catch {
            Write-Host "Failed chapters fetch: $_"
        }

        # Add to index
        $index += @{
            id           = $t.id
            name         = $t.name
            translator   = $t.translator
            direction    = $t.direction
            url          = "https://raw.githubusercontent.com/hamas/Quran-Data/main/translations/$filename"
            chapters_url = "https://raw.githubusercontent.com/hamas/Quran-Data/main/info/$($t.code)_chapters.json"
        }
    }
    catch {
        Write-Host "Failed to fetch $($t.id): $_"
    }
}

$indexJson = $index | ConvertTo-Json -Depth 5
Set-Content -Path "languages.json" -Value $indexJson

Write-Host "Done. Languages.json updated."
