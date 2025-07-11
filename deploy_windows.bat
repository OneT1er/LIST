@echo off
REM ****************************************************************************
REM Copyright 2019-2020 Lawrence Livermore National Security, LLC and other
REM LIST Project Developers. See the LICENSE file for details.
REM SPDX-License-Identifier: MIT
REM
REM Windows Deployment Script for LIST (Livermore SEM Image Tools)
REM ****************************************************************************

echo Creating Windows deployment package for LIST...
echo.

REM Check if the executable exists
if not exist build\release\LIST.exe (
    echo Error: LIST.exe not found in build\release\
    echo Please run build_windows.bat first
    exit /b 1
)

REM Create deployment directory
set DEPLOY_DIR=LIST_Windows_Package
if exist %DEPLOY_DIR% rmdir /s /q %DEPLOY_DIR%
mkdir %DEPLOY_DIR%

REM Copy executable
echo Copying executable...
copy build\release\LIST.exe %DEPLOY_DIR%\

REM Copy configuration file
echo Copying configuration...
copy src\LIST.ini %DEPLOY_DIR%\

REM Create required directories
mkdir %DEPLOY_DIR%\Resources
mkdir %DEPLOY_DIR%\Samples
mkdir %DEPLOY_DIR%\Samples_Out

REM Copy sample data
echo Copying sample data...
copy sample_data\*.* %DEPLOY_DIR%\Samples\

REM Copy documentation
echo Copying documentation...
copy readme.md %DEPLOY_DIR%\
copy LICENSE %DEPLOY_DIR%\
copy NOTICE %DEPLOY_DIR%\

REM Create a Windows-specific README
echo Creating Windows-specific README...
(
echo # LIST - Windows Deployment Package
echo.
echo ## Prerequisites
echo.
echo Before running LIST, please ensure you have:
echo.
echo 1. **Qt Runtime Libraries** - Install Qt or the Qt runtime redistributables
echo    - Download from: https://www.qt.io/download
echo    - Or use the Microsoft Visual C++ Redistributable
echo.
echo 2. **OpenCV Libraries** - Install OpenCV 4.x
echo    - Download from: https://opencv.org/releases/
echo    - Extract to C:\opencv\build ^(default location^)
echo    - Add C:\opencv\build\x64\vc16\bin to your PATH environment variable
echo.
echo 3. **Tesseract OCR** - Install Tesseract 4.x or higher
echo    - Download from: https://github.com/UB-Mannheim/tesseract/wiki
echo    - Install to C:\Program Files\Tesseract-OCR ^(default location^)
echo    - Add C:\Program Files\Tesseract-OCR to your PATH environment variable
echo.
echo 4. **Required Data Files**
echo    - Download frozen_east_text_detection.pb from the project repository
echo    - Download eng.traineddata, osd.traineddata, snum.traineddata from Tesseract
echo    - Place all files in the Resources folder
echo.
echo ## Running LIST
echo.
echo 1. Ensure all prerequisites are installed
echo 2. Double-click LIST.exe to start the application
echo 3. Use the Samples folder for test images
echo 4. Output will be saved to Samples_Out folder
echo.
echo ## Troubleshooting
echo.
echo - If you get "missing DLL" errors, ensure OpenCV and Tesseract are in PATH
echo - If Qt libraries are missing, install Qt runtime redistributables
echo - Check that all required data files are in the Resources folder
echo.
echo For more information, see the main readme.md file.
) > %DEPLOY_DIR%\README_Windows.txt

REM Use windeployqt if available to copy Qt dependencies
echo Checking for Qt deployment tool...
where windeployqt >nul 2>&1
if %errorlevel% equ 0 (
    echo Running windeployqt to copy Qt dependencies...
    windeployqt %DEPLOY_DIR%\LIST.exe
) else (
    echo Warning: windeployqt not found in PATH
    echo You may need to manually copy Qt DLLs to the deployment directory
    echo Or ensure Qt is installed on target systems
)

REM Create a batch file to run the application
echo Creating launcher script...
(
echo @echo off
echo REM Launch LIST with proper environment
echo.
echo REM Add OpenCV to PATH if not already there
echo if not exist "C:\opencv\build\x64\vc16\bin" goto :skip_opencv
echo set PATH=%%PATH%%;C:\opencv\build\x64\vc16\bin
echo :skip_opencv
echo.
echo REM Add Tesseract to PATH if not already there
echo if not exist "C:\Program Files\Tesseract-OCR" goto :skip_tesseract
echo set PATH=%%PATH%%;C:\Program Files\Tesseract-OCR
echo :skip_tesseract
echo.
echo REM Launch LIST
echo LIST.exe
echo.
echo pause
) > %DEPLOY_DIR%\run_LIST.bat

echo.
echo Deployment package created successfully!
echo Location: %DEPLOY_DIR%\
echo.
echo To distribute:
echo 1. Copy the entire %DEPLOY_DIR% folder to target Windows systems
echo 2. Install prerequisites on target systems
echo 3. Download required data files to Resources folder
echo 4. Run using run_LIST.bat or LIST.exe directly
echo.