SUMMARY = "DrivaPi Qt Dashboard"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=7800be09a61cad6da79d8f0c18b1e007"

DEPENDS = "qtbase qtdeclarative qtserialbus qtmultimedia taglib protobuf-native grpc-native protobuf grpc qtbase-native qtdeclarative-native qtpositioning qtlocation qt5compat qtshadertools"

RDEPENDS:${PN} = "qtbase qtdeclarative qtserialbus qtmultimedia taglib protobuf grpc qtpositioning qtpositioning-qmlplugins qtlocation qtlocation-qmlplugins qt5compat qt5compat-qmlplugins qtshadertools qtshadertools-qmlplugins"

SRC_URI = "file://qt-app"

S = "${WORKDIR}/qt-app"

inherit qt6-cmake pkgconfig

EXTRA_OECMAKE += "-DProtobuf_PROTOC_EXECUTABLE=${STAGING_BINDIR_NATIVE}/protoc"
EXTRA_OECMAKE += "-DGRPC_CPP_PLUGIN_EXECUTABLE=${STAGING_BINDIR_NATIVE}/grpc_cpp_plugin"

EXTRA_OECMAKE += "-DUSE_PKGCONFIG_GRPC=ON"
