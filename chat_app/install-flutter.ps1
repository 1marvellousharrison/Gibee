# Installs the Flutter SDK once chat_app's flutter.zip download completes,
# then scaffolds and verifies builds. Idempotent.

$ErrorActionPreference = 'Stop'
$temp = 'C:\Users\hp\AppData\Local\Temp\opencode'
$zip = Join-Path $temp 'flutter.zip'
$root = 'C:\src'
$flutterBin = 'C:\src\flutter\bin'
$project = 'C:\Users\hp\Desktop\chat\chat_app'
$expectedHash = '0ccd71931f49c2fbe394b1eeb6d79af3d624058a043ea0d03d34160581624fb8'
$expectedSize = 1933437428
$log = Join-Path $temp 'install.log'

function Log([string]$m) {
  $line = "[{0:yyyy-MM-dd HH:mm:ss}] {1}" -f (Get-Date), $m
  $line | Add-Content -Path $log
  Write-Host $line
}

New-Item -ItemType Directory -Path $root -Force | Out-Null

# 1) Wait for a complete, correct zip.
Log "Waiting for $zip ..."
$deadline = (Get-Date).AddHours(72)
while ((Get-Date) -lt $deadline) {
  if (Test-Path $zip) {
    $len = (Get-Item $zip).Length
    if ($len -eq $expectedSize) { break }
    Log "partial: $([math]::Round($len/1MB,1)) MB (need $([math]::Round($expectedSize/1MB,1)) MB)"
  } else {
    Log 'zip not present yet'
  }
  Start-Sleep -Seconds 300
}
if (-not (Test-Path $zip)) { Log 'TIMEOUT waiting for zip'; exit 1 }
$actual = Get-FileHash -LiteralPath $zip -Algorithm SHA256
if ($actual.Hash -ne $expectedHash) {
  Log "BAD HASH: got $($actual.Hash)"
  exit 1
}
Log 'zip verified.'

# 2) Extract if not yet done.
if (-not (Test-Path "$root\flutter\bin\flutter.bat")) {
  Log 'Extracting (tar) ...'
  & tar.exe -xf $zip -C $root
  if (-not (Test-Path "$root\flutter\bin\flutter.bat")) { Log 'extract failed'; exit 1 }
  Log 'extracted to C:\src\flutter'
}

# 3) Add to PATH (user scope, idempotent).
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($userPath -notlike "*$flutterBin*") {
  [Environment]::SetEnvironmentVariable('Path', "$flutterBin;$userPath", 'User')
  Log "added $flutterBin to user PATH"
}
$env:Path = "$flutterBin;$env:Path"

# 4) First run + doctor.
Log 'flutter --version ...'
& "$flutterBin\flutter.bat" --version
Log 'flutter doctor -v ...'
& "$flutterBin\flutter.bat" doctor -v

# 5) Scaffold platform folders in the existing app.
if (-not (Test-Path "$project\android\build.gradle")) {
  Log 'flutter create ...'
  & "$flutterBin\flutter.bat" create --platforms=android,web --project-name chat_app "$project"
}

# 6) Analyze.
& "$flutterBin\flutter.bat" pub get
Log 'flutter analyze ...'
& "$flutterBin\flutter.bat" analyze

# 7) Builds.
Log 'flutter build web ...'
& "$flutterBin\flutter.bat" build web
Log 'flutter build apk ...'
& "$flutterBin\flutter.bat" build apk --debug

Log 'DONE'