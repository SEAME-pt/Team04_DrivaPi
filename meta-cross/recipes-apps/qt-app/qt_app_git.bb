PN = "qt_app"
SUMMARY = "DrivaPi Qt Dashboard"
DESCRIPTION = "Application Qt6/QML (CMake) for DrivaPi"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=7800be09a61cad6da79d8f0c18b1e007"

SRC_URI = "file://qt-app"
S = "${WORKDIR}/qt-app"

inherit qt6-cmake pkgconfig

DEPENDS = "\
    qtbase \
    qtdeclarative \
    qtserialbus \
    qtmultimedia \
    qtpositioning \
    qtlocation \
    qt5compat \
    qtshadertools \
    protobuf \
    grpc \
    taglib \
    protobuf-native \
    grpc-native \
    qtbase-native \
    qtdeclarative-native \
"

EXTRA_OECMAKE += "\
    -DProtobuf_PROTOC_EXECUTABLE=${STAGING_BINDIR_NATIVE}/protoc \
    -DGRPC_CPP_PLUGIN_EXECUTABLE=${STAGING_BINDIR_NATIVE}/grpc_cpp_plugin \
    -DUSE_PKGCONFIG_GRPC=ON \
"

RDEPENDS:${PN} = "\
    qtbase \
    qtdeclarative \
    qtmultimedia \
    qtmultimedia-plugins \
    qtmultimedia-qmlplugins \
    qtpositioning \
    qtpositioning-qmlplugins \
    qtlocation \
    qtlocation-qmlplugins \
    qt5compat \
    qt5compat-qmlplugins \
    qtshadertools \
    qtshadertools-qmlplugins \
    qtsvg-plugins \
    gstreamer1.0 \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-base-audioconvert \
    gstreamer1.0-plugins-base-audioresample \
    gstreamer1.0-plugins-base-playback \
    gstreamer1.0-plugins-base-typefindfunctions \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-good-audioparsers \
    gstreamer1.0-plugins-good-autodetect \
    gstreamer1.0-plugins-good-mpg123 \
    gstreamer1.0-plugins-good-pulseaudio \
    pipewire \
    pipewire-pulse \
    wireplumber \
    ca-certificates \
"

RDEPENDS:${PN}:append = " pulseaudio-misc pipewire-tools"

FILES:${PN}:append = " \
    ${datadir}/qt-app \
"

do_install:append() {
    if [ -d "${S}/resources" ]; then
        install -d ${D}${datadir}/qt-app
        cp -r --no-preserve=ownership "${S}/resources" "${D}${datadir}/qt-app/"
    fi
    if [ -d "${S}/mp3" ]; then
        install -d ${D}${datadir}/qt-app
        cp -r --no-preserve=ownership "${S}/mp3" "${D}${datadir}/qt-app/"
    fi
}
