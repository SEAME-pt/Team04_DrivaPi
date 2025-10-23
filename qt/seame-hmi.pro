QT += quick qml gui

qtHaveModule(core5compat) {
    QT += core5compat
    DEFINES += HAVE_CORE5COMPAT
}

CONFIG += c++17
CONFIG += sdk_no_version_check

TARGET = SEA_ME_HMI_Dashboard
VERSION = 1.0.0
TEMPLATE = app

# Directories
BUILD_DIR = build
OBJECTS_DIR = $$BUILD_DIR/obj
MOC_DIR = $$BUILD_DIR/moc
RCC_DIR = $$BUILD_DIR/rcc
UI_DIR = $$BUILD_DIR/ui
DESTDIR = $$BUILD_DIR/bin

# Include paths
INCLUDEPATH += include

# Source files
SOURCES += \
    src/core/main.cpp \
    src/core/vehicledata.cpp

HEADERS += \
    include/vehicledata.h

# Resources
RESOURCES += resources/resources.qrc

# Compiler flags
QMAKE_CXXFLAGS += -Wall -Wextra

# Deployment
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

# Clean
QMAKE_CLEAN += -r $$BUILD_DIR
QMAKE_DISTCLEAN += -r $$BUILD_DIR .qmake.stash
