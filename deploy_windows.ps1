# ****************************************************************************
# Copyright 2019-2020 Lawrence Livermore National Security, LLC and other
# LIST Project Developers. See the LICENSE file for details.
# SPDX-License-Identifier: MIT
#
# PowerShell Advanced Deployment Script for LIST (Livermore SEM Image Tools)
# ****************************************************************************

param(
    [string]$QtPath = "",
    [string]$OpenCVPath = "C:\opencv\build",
    [string]$TesseractPath = "C:\Program Files\Tesseract-OCR",
    [string]$OutputDir = "LIST_Windows_Package",
    [switch]$DownloadDataFiles = $false,
    [switch]$CreateInstaller = $false
)

Write-Host "LIST Windows Advanced Deployment Script" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

# Function to check if a path exists
function Test-PathExists {
    param([string]$Path, [string]$Description)
    if (Test-Path $Path) {
        Write-Host "✓ Found $Description at: $Path" -ForegroundColor Green
        return $true
    } else {
        Write-Host "✗ $Description not found at: $Path" -ForegroundColor Red
        return $false
    }
}

# Function to copy files with error handling
function Copy-FileSafely {
    param([string]$Source, [string]$Destination)
    try {
        Copy-Item $Source $Destination -Force -Recurse
        Write-Host "✓ Copied: $Source" -ForegroundColor Green
    } catch {
        Write-Host "✗ Failed to copy: $Source" -ForegroundColor Red
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Check prerequisites
Write-Host "`nChecking prerequisites..." -ForegroundColor Yellow

$allPrereqsMet = $true

# Check if executable exists
if (-not (Test-Path "build\release\LIST.exe")) {
    Write-Host "✗ LIST.exe not found in build\release\" -ForegroundColor Red
    Write-Host "  Please run build_windows.bat first" -ForegroundColor Yellow
    exit 1
}

# Check Qt
if ($QtPath -eq "") {
    # Try to find Qt automatically
    $qtPaths = @(
        "C:\Qt\6.5.0\msvc2019_64",
        "C:\Qt\6.4.0\msvc2019_64",
        "C:\Qt\5.15.2\msvc2019_64",
        "C:\Qt\5.14.2\msvc2017_64"
    )
    
    foreach ($path in $qtPaths) {
        if (Test-Path "$path\bin\windeployqt.exe") {
            $QtPath = $path
            break
        }
    }
}

if ($QtPath -ne "" -and (Test-Path "$QtPath\bin\windeployqt.exe")) {
    Write-Host "✓ Qt found at: $QtPath" -ForegroundColor Green
} else {
    Write-Host "✗ Qt not found. Please specify -QtPath parameter" -ForegroundColor Red
    $allPrereqsMet = $false
}

# Check OpenCV
if (-not (Test-PathExists $OpenCVPath "OpenCV")) {
    $allPrereqsMet = $false
}

# Check Tesseract
if (-not (Test-PathExists $TesseractPath "Tesseract")) {
    $allPrereqsMet = $false
}

if (-not $allPrereqsMet) {
    Write-Host "`nSome prerequisites are missing. Continuing with deployment..." -ForegroundColor Yellow
}

# Create deployment directory
Write-Host "`nCreating deployment package..." -ForegroundColor Yellow

if (Test-Path $OutputDir) {
    Remove-Item $OutputDir -Recurse -Force
}
New-Item -ItemType Directory -Path $OutputDir | Out-Null

# Create subdirectories
@("Resources", "Samples", "Samples_Out") | ForEach-Object {
    New-Item -ItemType Directory -Path "$OutputDir\$_" | Out-Null
}

# Copy executable
Copy-FileSafely "build\release\LIST.exe" "$OutputDir\"

# Copy configuration
Copy-FileSafely "src\LIST.ini" "$OutputDir\"

# Copy sample data
if (Test-Path "sample_data") {
    Copy-FileSafely "sample_data\*" "$OutputDir\Samples\"
}

# Copy documentation
@("readme.md", "LICENSE", "NOTICE") | ForEach-Object {
    if (Test-Path $_) {
        Copy-FileSafely $_ "$OutputDir\"
    }
}

# Deploy Qt dependencies
if ($QtPath -ne "" -and (Test-Path "$QtPath\bin\windeployqt.exe")) {
    Write-Host "`nDeploying Qt dependencies..." -ForegroundColor Yellow
    & "$QtPath\bin\windeployqt.exe" "$OutputDir\LIST.exe"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Qt dependencies deployed successfully" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to deploy Qt dependencies" -ForegroundColor Red
    }
}

# Copy OpenCV DLLs
if (Test-Path "$OpenCVPath\x64\vc16\bin") {
    Write-Host "`nCopying OpenCV DLLs..." -ForegroundColor Yellow
    $opencvDlls = @(
        "opencv_core4*.dll",
        "opencv_imgproc4*.dll", 
        "opencv_imgcodecs4*.dll",
        "opencv_dnn4*.dll"
    )
    
    foreach ($dll in $opencvDlls) {
        $files = Get-ChildItem "$OpenCVPath\x64\vc16\bin\$dll" -ErrorAction SilentlyContinue
        foreach ($file in $files) {
            Copy-FileSafely $file.FullName "$OutputDir\"
        }
    }
}

# Download data files if requested
if ($DownloadDataFiles) {
    Write-Host "`nDownloading required data files..." -ForegroundColor Yellow
    
    $dataFiles = @{
        "frozen_east_text_detection.pb" = "https://github.com/ZER-0-NE/EAST-Detector-for-text-detection-using-OpenCV/raw/master/frozen_east_text_detection.pb"
    }
    
    foreach ($file in $dataFiles.Keys) {
        try {
            Write-Host "Downloading $file..." -ForegroundColor Yellow
            Invoke-WebRequest -Uri $dataFiles[$file] -OutFile "$OutputDir\Resources\$file"
            Write-Host "✓ Downloaded $file" -ForegroundColor Green
        } catch {
            Write-Host "✗ Failed to download $file" -ForegroundColor Red
        }
    }
    
    Write-Host "Note: Tesseract trained data files need to be copied manually from:" -ForegroundColor Yellow
    Write-Host "  $TesseractPath\tessdata\" -ForegroundColor Yellow
    Write-Host "  Required files: eng.traineddata, osd.traineddata, snum.traineddata" -ForegroundColor Yellow
}

# Create installer if requested
if ($CreateInstaller) {
    Write-Host "`nCreating Windows installer..." -ForegroundColor Yellow
    
    # Check if NSIS is available
    $nsisPath = Get-Command "makensis" -ErrorAction SilentlyContinue
    if ($nsisPath) {
        # Create NSIS script
        $nsisScript = @"
; LIST Windows Installer Script
!define APPNAME "LIST"
!define APPVERSION "0.9"
!define PUBLISHER "Lawrence Livermore National Laboratory"

Name "`${APPNAME} `${APPVERSION}"
OutFile "LIST_Windows_Installer.exe"
InstallDir "`$PROGRAMFILES\LIST"

Page directory
Page instfiles

Section "MainSection" SEC01
    SetOutPath "`$INSTDIR"
    File /r "$OutputDir\*"
    
    ; Create shortcuts
    CreateDirectory "`$SMPROGRAMS\LIST"
    CreateShortCut "`$SMPROGRAMS\LIST\LIST.lnk" "`$INSTDIR\LIST.exe"
    CreateShortCut "`$DESKTOP\LIST.lnk" "`$INSTDIR\LIST.exe"
    
    ; Create uninstaller
    WriteUninstaller "`$INSTDIR\Uninstall.exe"
SectionEnd

Section "Uninstall"
    Delete "`$INSTDIR\*"
    RMDir /r "`$INSTDIR"
    Delete "`$SMPROGRAMS\LIST\LIST.lnk"
    Delete "`$DESKTOP\LIST.lnk"
    RMDir "`$SMPROGRAMS\LIST"
SectionEnd
"@
        
        $nsisScript | Out-File -FilePath "LIST_installer.nsi" -Encoding UTF8
        
        # Run NSIS
        & "makensis" "LIST_installer.nsi"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ Windows installer created: LIST_Windows_Installer.exe" -ForegroundColor Green
        } else {
            Write-Host "✗ Failed to create installer" -ForegroundColor Red
        }
    } else {
        Write-Host "NSIS not found. Skipping installer creation." -ForegroundColor Yellow
        Write-Host "Install NSIS from https://nsis.sourceforge.io/ to create installers" -ForegroundColor Yellow
    }
}

Write-Host "`nDeployment completed!" -ForegroundColor Green
Write-Host "Package location: $OutputDir" -ForegroundColor Green
Write-Host "`nTo distribute:" -ForegroundColor Yellow
Write-Host "1. Copy the $OutputDir folder to target systems" -ForegroundColor Yellow
Write-Host "2. Install prerequisites on target systems" -ForegroundColor Yellow
Write-Host "3. Download required data files to Resources folder" -ForegroundColor Yellow
Write-Host "4. Run LIST.exe" -ForegroundColor Yellow