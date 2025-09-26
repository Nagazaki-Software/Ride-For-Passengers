param(
  [string]$PluginRoot = "$Env:LOCALAPPDATA/ Pub/ Cache/ git/ google_maps_native_sdk-5ee859b9a1bd3a529d5237b28f6a84f06fb05957"
)

$PluginRoot = $PluginRoot -replace "\\/ ", "/" -replace " /", "/" -replace "  ", " "
$PluginRoot = $PluginRoot -replace "\s+", " "
$PluginRoot = $PluginRoot.Trim()
$PluginRoot = $PluginRoot -replace " ", ""

$swiftFile = Join-Path $PluginRoot "ios/Classes/MapViewController.swift"
if (!(Test-Path $swiftFile)) {
  Write-Error "Swift file not found: $swiftFile"
  exit 1
}

$text = Get-Content $swiftFile -Raw

# 1) Make cluster item rotation mutable
$text = $text -replace 'let rotation: Double','var rotation: Double'

# 2) Fix GMSMapID initializer label
$text = $text -replace 'GMSMapID\(mapID:','GMSMapID(identifier:'

# 3) Replace GMSTileLayer + tileURLConstructor with GMSURLTileLayer(urlConstructor:)
$pattern = 'let tile = GMSTileLayer\(\)[\s\S]*?tile\.map = self\.mapView'
$replacement = @'
        let tile = GMSURLTileLayer(urlConstructor: { (x, y, zoom) -> URL? in
          var url = template.replacingOccurrences(of: "{x}", with: String(x))
          url = url.replacingOccurrences(of: "{y}", with: String(y))
          url = url.replacingOccurrences(of: "{z}", with: String(zoom))
          return URL(string: url)
        })
        tile.tileSize = Int((args["tileSize"] as? NSNumber)?.intValue ?? 256)
        let opacity = (args["opacity"] as? Double) ?? 1.0
        tile.opacity = Float(opacity)
        let z = (args["zIndex"] as? Double) ?? 0
        tile.zIndex = Int32(z)
        tile.map = self.mapView
'@

$new = [regex]::Replace($text, $pattern, $replacement)

if ($new -ne $text) {
  Set-Content -Path $swiftFile -Value $new -Encoding UTF8
  Write-Host "Patched: $swiftFile"
} else {
  Write-Host "No changes applied (pattern not found)."
}
