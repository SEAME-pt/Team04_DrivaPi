SUMMARY = "DrivaPi Qt Dashboard"
LICENSE = "CLOSED"
PR = "r4"

DEPENDS = "qtbase qtdeclarative qtserialbus qtmultimedia taglib protobuf-native grpc-native protobuf grpc qtbase-native qtdeclarative-native"

RDEPENDS:${PN} = "qtbase qtdeclarative qtserialbus qtmultimedia taglib protobuf grpc"

SRC_URI = "file://qt-app"

S = "${WORKDIR}/qt-app"

inherit qt6-cmake pkgconfig

EXTRA_OECMAKE += "-DProtobuf_PROTOC_EXECUTABLE=${STAGING_BINDIR_NATIVE}/protoc"
EXTRA_OECMAKE += "-DgRPC_PLUGIN_EXECUTABLE=${STAGING_BINDIR_NATIVE}/grpc_cpp_plugin"
