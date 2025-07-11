# LIST Windows Installation Guide

This guide explains how to build and deploy LIST (Livermore SEM Image Tools) on Windows systems.

## Prerequisites

### 1. Development Environment
- **Visual Studio 2019 or later** (Community Edition is sufficient)
- **Qt 5.15 or later** (Qt 6.x recommended)
- **CMake 3.16 or later** (optional, for alternative build)

### 2. Required Libraries

#### OpenCV 4.x
1. Download OpenCV from https://opencv.org/releases/
2. Extract to `C:\opencv\build` (recommended default location)
3. Add `C:\opencv\build\x64\vc16\bin` to your system PATH

#### Tesseract OCR 4.x
1. Download from https://github.com/UB-Mannheim/tesseract/wiki
2. Install to `C:\Program Files\Tesseract-OCR` (default location)
3. Add `C:\Program Files\Tesseract-OCR` to your system PATH

#### Qt Framework
1. Download Qt from https://www.qt.io/download
2. Install Qt 5.15 or later with MSVC compiler support
3. Add Qt bin directory to PATH (e.g., `C:\Qt\6.5.0\msvc2019_64\bin`)

### 3. Required Data Files
Download and place in the `Resources` folder:
- `frozen_east_text_detection.pb` - [Download here](https://github.com/ZER-0-NE/EAST-Detector-for-text-detection-using-OpenCV/raw/master/frozen_east_text_detection.pb)
- `eng.traineddata` - From Tesseract tessdata
- `osd.traineddata` - From Tesseract tessdata  
- `snum.traineddata` - From Tesseract tessdata

## Building LIST

### Method 1: Using Batch Script (Recommended)
1. Open Command Prompt or PowerShell as Administrator
2. Navigate to the LIST directory
3. Run the build script:
   ```cmd
   build_windows.bat
   ```

### Method 2: Manual Build
1. Open Command Prompt in the LIST directory
2. Create build directory:
   ```cmd
   mkdir build
   cd build
   ```
3. Generate Makefile:
   ```cmd
   qmake ..\src\LIST.pro CONFIG+=release
   ```
4. Build:
   ```cmd
   nmake
   ```

### Method 3: Using Qt Creator
1. Open Qt Creator
2. Open `src/LIST.pro`
3. Configure the project with your Qt kit
4. Build the project (Ctrl+B)

## Deployment

### Automatic Deployment
Use the provided deployment scripts:

#### Basic Deployment (Batch Script)
```cmd
deploy_windows.bat
```

#### Advanced Deployment (PowerShell)
```powershell
.\deploy_windows.ps1 -QtPath "C:\Qt\6.5.0\msvc2019_64" -DownloadDataFiles
```

#### Create Installer (PowerShell with NSIS)
```powershell
.\deploy_windows.ps1 -CreateInstaller
```

### Manual Deployment
1. Create deployment folder structure:
   ```
   LIST_Windows_Package/
   ├── LIST.exe
   ├── LIST.ini
   ├── run_LIST.bat
   ├── Resources/
   │   ├── frozen_east_text_detection.pb
   │   ├── eng.traineddata
   │   ├── osd.traineddata
   │   └── snum.traineddata
   ├── Samples/
   └── Samples_Out/
   ```

2. Copy the built executable from `build\release\LIST.exe`
3. Copy configuration file `src\LIST_windows.ini` as `LIST.ini`
4. Copy sample data to `Samples` folder
5. Run `windeployqt LIST.exe` to copy Qt dependencies
6. Copy OpenCV DLLs from `C:\opencv\build\x64\vc16\bin`:
   - `opencv_core4XX.dll`
   - `opencv_imgproc4XX.dll`
   - `opencv_imgcodecs4XX.dll`
   - `opencv_dnn4XX.dll`
7. Copy Tesseract trained data files to `Resources` folder

## Configuration

### Environment Variables
Ensure these directories are in your system PATH:
- Qt bin directory (e.g., `C:\Qt\6.5.0\msvc2019_64\bin`)
- OpenCV bin directory (e.g., `C:\opencv\build\x64\vc16\bin`)
- Tesseract directory (e.g., `C:\Program Files\Tesseract-OCR`)

### Custom Library Paths
If you installed libraries in non-standard locations, modify `src/LIST.pro`:

```qmake
win32 {
    # Custom OpenCV path
    OPENCV_DIR = $$quote(D:/MyLibs/opencv/build)
    
    # Custom Tesseract path
    TESSERACT_DIR = $$quote(D:/MyLibs/tesseract)
}
```

## Troubleshooting

### Common Issues

#### "Missing DLL" Errors
- Ensure all required DLLs are in the application directory or system PATH
- Run `windeployqt` to automatically copy Qt DLLs
- Manually copy OpenCV and Tesseract DLLs if needed

#### Build Errors
- Verify all prerequisites are installed
- Check that paths in `LIST.pro` match your installation
- Ensure you're using the correct Visual Studio version

#### Runtime Errors
- Verify required data files are in the `Resources` folder
- Check that Tesseract can find its trained data files
- Ensure OpenCV can load the EAST detector model

### Debug Mode
To build in debug mode for troubleshooting:
```cmd
qmake ..\src\LIST.pro CONFIG+=debug
nmake
```

### Dependency Walker
Use Dependency Walker (depends.exe) to identify missing DLLs:
1. Download from http://www.dependencywalker.com/
2. Open LIST.exe in Dependency Walker
3. Check for missing dependencies

## Distribution

### For End Users
1. Create a deployment package using the deployment scripts
2. Distribute the entire package folder
3. Provide installation instructions for prerequisites
4. Include the Windows-specific README

### For Developers
1. Ensure all build tools are installed
2. Clone the repository
3. Follow the build instructions above
4. Use the provided scripts for consistent deployment

## Performance Optimization

### Release Build
Always use release build for distribution:
```cmd
qmake CONFIG+=release
```

### Static Linking
For standalone deployment, consider static linking:
```qmake
CONFIG += static
```

Note: This requires Qt compiled with static libraries.

## Support

For issues specific to Windows deployment:
1. Check the troubleshooting section above
2. Verify all prerequisites are correctly installed
3. Test with the provided sample data
4. Check Windows Event Viewer for system-level errors

For general LIST support, refer to the main README.md file.