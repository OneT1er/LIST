@echo off
REM ****************************************************************************
REM Copyright 2019-2020 Lawrence Livermore National Security, LLC and other
REM LIST Project Developers. See the LICENSE file for details.
REM SPDX-License-Identifier: MIT
REM
REM Windows Build Script for LIST (Livermore SEM Image Tools)
REM ****************************************************************************

echo Building LIST for Windows...
echo.

REM Check if Qt is available
where qmake >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: Qt qmake not found in PATH
    echo Please ensure Qt is installed and qmake is in your PATH
    echo Example: set PATH=%PATH%;C:\Qt\6.5.0\msvc2019_64\bin
    exit /b 1
)

REM Create build directory
if not exist build mkdir build
cd build

REM Generate Makefile
echo Generating Makefile...
qmake ../src/LIST.pro CONFIG+=release
if %errorlevel% neq 0 (
    echo Error: qmake failed
    exit /b 1
)

REM Build the application
echo Building application...
nmake
if %errorlevel% neq 0 (
    echo Error: Build failed
    echo.
    echo Make sure you have:
    echo 1. Visual Studio Build Tools installed
    echo 2. OpenCV installed (default location: C:\opencv\build)
    echo 3. Tesseract installed (default location: C:\Program Files\Tesseract-OCR)
    echo.
    exit /b 1
)

echo.
echo Build completed successfully!
echo Executable location: build\release\LIST.exe
echo.

cd ..