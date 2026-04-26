# PowerShell script to copy icon to Android mipmap folders
# This is a workaround for flutter_launcher_icons git dependency issue

$sourceIcon = "assets\icon\app_icon.png"
$iconName = "ic_launcher.png"

# Check if source icon exists
if (!(Test-Path $sourceIcon)) {
    Write-Host "Error: Source icon not found at $sourceIcon" -ForegroundColor Red
    exit 1
}

Write-Host "Copying your icon to all Android mipmap folders..." -ForegroundColor Green

# List of mipmap directories
$mipmapDirs = @(
    "android\app\src\main\res\mipmap-ldpi",
    "android\app\src\main\res\mipmap-mdpi",
    "android\app\src\main\res\mipmap-hdpi",
    "android\app\src\main\res\mipmap-xhdpi",
    "android\app\src\main\res\mipmap-xxhdpi",
    "android\app\src\main\res\mipmap-xxxhdpi"
)

foreach ($dir in $mipmapDirs) {
    if (!(Test-Path $dir)) {
        Write-Host "Creating directory: $dir" -ForegroundColor Yellow
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    
    $targetPath = Join-Path $dir $iconName
    Copy-Item -Path $sourceIcon -Destination $targetPath -Force
    Write-Host "OK - Copied to: $dir" -ForegroundColor Green
}

Write-Host "Icon replacement complete!" -ForegroundColor Green
Write-Host "Now run: flutter clean" -ForegroundColor Cyan
Write-Host "Then: flutter run" -ForegroundColor Cyan
