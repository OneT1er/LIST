//******************************************************************************
// Copyright 2019-2020 Lawrence Livermore National Security, LLC and other
// LIST Project Developers. See the LICENSE file for details.
// SPDX-License-Identifier: MIT
//
// LIvermore Sem image Tools (LIST)
// QT Project created by QtCreator
//*****************************************************************************/


QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = LIST
TEMPLATE = app
CONFIG += app_bundle
CONFIG += c++11
#CONFIG += static
#CONFIG += staticlib
#static static-runtime


SOURCES += main.cpp\
		mainwindow.cpp\
		mainview.cpp\
		configwindow.cpp\
		histwindow.cpp\
		histview.cpp\
		semproc.cpp\
		semutil.cpp\
		textdetect.cpp \
		segmenter.cpp

HEADERS += mainwindow.h\
		mainview.h\
		configwindow.h\
		histwindow.h\
		histview.h\
		semproc.h\
		semutil.h\
		textdetect.h\
		segmenter.h\
		datatype.h


# OpenCV
DEFINES		+= __LIB_OPENCV

# Platform-specific OpenCV and Tesseract configurations
win32 {
    # Windows OpenCV configuration
    # Assumes OpenCV is installed in standard Windows location
    # Users may need to adjust these paths based on their OpenCV installation
    OPENCV_DIR = $$quote(C:/opencv/build)
    OPENCV_INCLUDE = $$quote($${OPENCV_DIR}/include)
    OPENCV_LIB = $$quote($${OPENCV_DIR}/x64/vc16/lib)
    OPENCV_BIN = $$quote($${OPENCV_DIR}/x64/vc16/bin)
    
    INCLUDEPATH += $${OPENCV_INCLUDE}
    DEPENDPATH  += $${OPENCV_INCLUDE}
    LIBS        += -L$${OPENCV_LIB}
    
    # OpenCV libraries for Windows (adjust version numbers as needed)
    CONFIG(debug, debug|release) {
        LIBS += -lopencv_core4d
        LIBS += -lopencv_imgproc4d
        LIBS += -lopencv_imgcodecs4d
        LIBS += -lopencv_dnn4d
    }
    CONFIG(release, debug|release) {
        LIBS += -lopencv_core4
        LIBS += -lopencv_imgproc4
        LIBS += -lopencv_imgcodecs4
        LIBS += -lopencv_dnn4
    }
    
    # Tesseract for Windows
    # Assumes Tesseract is installed in standard Windows location
    TESSERACT_DIR = $$quote(C:/Program Files/Tesseract-OCR)
    TESSERACT_INCLUDE = $$quote($${TESSERACT_DIR}/include)
    TESSERACT_LIB = $$quote($${TESSERACT_DIR}/lib)
    
    INCLUDEPATH += $${TESSERACT_INCLUDE}
    DEPENDPATH  += $${TESSERACT_INCLUDE}
    LIBS        += -L$${TESSERACT_LIB}
    LIBS        += -ltesseract
}

unix:!macx {
    # Linux OpenCV configuration
    INCLUDEPATH += /usr/local/include/opencv4
    DEPENDPATH  += /usr/local/include/opencv4
    LIBS        += -L/usr/local/lib
    LIBS        += -lopencv_core
    LIBS        += -lopencv_imgproc
    LIBS		+= -lopencv_imgcodecs
    LIBS        += -lopencv_dnn
    
    # Tesseract for Linux
    INCLUDEPATH += /usr/local/include
    DEPENDPATH  += /usr/local/include
    LIBS        += -L/usr/local/lib
    LIBS        += -ltesseract
}

macx {
    # macOS OpenCV configuration
    INCLUDEPATH += /usr/local/include/opencv4
    DEPENDPATH  += /usr/local/include/opencv4
    LIBS        += -L/usr/local/lib
    LIBS        += -lopencv_core
    LIBS        += -lopencv_imgproc
    LIBS		+= -lopencv_imgcodecs
    LIBS        += -lopencv_dnn
    
    # Tesseract for macOS
    INCLUDEPATH += /usr/local/include
    DEPENDPATH  += /usr/local/include
    LIBS        += -L/usr/local/lib
    LIBS        += -ltesseract
}


