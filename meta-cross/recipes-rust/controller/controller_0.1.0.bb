SUMMARY = "Controller application"
DESCRIPTION = "Rust controller service"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=2775a5a334c1cd9ba058a1374ee37a25"

SRC_URI = "file://controller"

S = "${WORKDIR}/controller"

inherit cargo
inherit cargo-update-recipe-crates
include controller-crates.inc

CARGO_BUILD_FLAGS += "--locked"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 \
        target/${RUST_TARGET_SYS}/release/controller \
        ${D}${bindir}
}
