# PowerShell Script to Fix Hardcoded Strings in Flutter App
# This script replaces hardcoded English strings with localized versions
# Usage: Run this from the project root directory

$projectRoot = "c:\Users\abede\OneDrive\Desktop\kingco\Mobile\glovo_app\glovo_app"

# List of dart files to process
$dartFiles = Get-ChildItem -Path "$projectRoot\lib" -Filter "*.dart" -Recurse

Write-Host "Found $($dartFiles.Count) Dart files to process" -ForegroundColor Green

$changesCount = 0

# Array of replacements
$replacements = @(
    @{"old" = "'My Orders'"; "new" = "AppLocalizations.of(context)!.myOrders" },
    @{"old" = "'My Cart'"; "new" = "AppLocalizations.of(context)!.myCart" },
    @{"old" = "'My Profile'"; "new" = "AppLocalizations.of(context)!.myProfile" },
    @{"old" = "'Favorites'"; "new" = "AppLocalizations.of(context)!.favorites_title" },
    @{"old" = "'Cancel'"; "new" = "AppLocalizations.of(context)!.cancel" },
    @{"old" = "'Settings'"; "new" = "AppLocalizations.of(context)!.accountSettings" },
    @{"old" = "'Log out'"; "new" = "AppLocalizations.of(context)!.logout" },
    @{"old" = "'Confirm log out?'"; "new" = "AppLocalizations.of(context)!.logOutConfirm" },
    @{"old" = "'Ongoing'"; "new" = "AppLocalizations.of(context)!.ongoing" },
    @{"old" = "'History'"; "new" = "AppLocalizations.of(context)!.history" },
    @{"old" = "'Delete'"; "new" = "AppLocalizations.of(context)!.delete" },
    @{"old" = "'Edit'"; "new" = "AppLocalizations.of(context)!.edit" },
    @{"old" = "'Save'"; "new" = "AppLocalizations.of(context)!.save" }
)

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $fileChanged = $false
    
    foreach ($replacement in $replacements) {
        if ($content -match [regex]::Escape($replacement.old)) {
            Write-Host "Fixing: $($file.Name)" -ForegroundColor Yellow
            Write-Host "  Replacing: $($replacement.old)" -ForegroundColor Cyan
            
            $content = $content -replace [regex]::Escape("Text($($replacement.old)"), "Text($($replacement.new))"
            $fileChanged = $true
            $changesCount++
        }
    }
    
    if ($fileChanged) {
        # Add l10n import if not already present
        if (-not ($content -match "import.*l10n/app_localizations")) {
            $content = $content -replace "(import.*injection_container.*`n)", "`$1import '../../../../l10n/app_localizations.dart';`n"
        }
        
        Set-Content -Path $file.FullName -Value $content
        Write-Host "  ✓ Updated" -ForegroundColor Green
    }
}

Write-Host "`nCompleted! Checked all files." -ForegroundColor Green
