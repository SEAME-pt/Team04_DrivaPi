SUMMARY = "Controller application"
DESCRIPTION = "Rust controller service"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=2775a5a334c1cd9ba058a1374ee37a25"

DEPENDS += "pkgconfig-native systemd"

SRC_URI = "file://controller"

S = "${WORKDIR}/controller"

inherit cargo pkgconfig
inherit cargo-update-recipe-crates
include controller-crates.inc

# crates.io rejects generic wget requests with HTTP 403.
FETCHCMD_wget = "/usr/bin/env wget --user-agent='cargo 1.81.0' -t 2 -T 100"

CARGO_BUILD_FLAGS += "--locked"

do_install() {
    install -d ${D}${bindir}
    install -m 0755 \
        target/${RUST_TARGET_SYS}/release/controller \
        ${D}${bindir}
}
