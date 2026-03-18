# Decodes base64 placeholder files into PNGs for the iOS asset catalog
$base = Join-Path $PSScriptRoot "ios\Runner\Assets.xcassets\MobifundLaunch.imageset"
Get-ChildItem -Path $base -Filter "*.b64" | ForEach-Object {
    $b64 = Get-Content -Raw -Path $_.FullName
    $out = [System.IO.Path]::ChangeExtension($_.FullName, ".png")
    [System.IO.File]::WriteAllBytes($out, [System.Convert]::FromBase64String($b64))
    Write-Host "Wrote $out"
}
Write-Host "Done. Open ios/Runner.xcworkspace in Xcode and confirm Assets.xcassets/MobifundLaunch.imageset contains the images."