PN = "drivapi_audio"
SUMMARY = "Services systemd audio (PipeWire/WirePlumber) + dashboard"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "\
    file://pipewire-system.service \
    file://wireplumber-system.service \
    file://pipewire-pulse-system.service \
    file://drivapi-dashboard.service \
"

inherit systemd

S = "${WORKDIR}"

RDEPENDS:${PN} += "pipewire wireplumber pipewire-pulse"

FILES:${PN} += "${systemd_system_unitdir}/*.service"

do_install() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/pipewire-system.service ${D}${systemd_system_unitdir}/
    install -m 0644 ${WORKDIR}/wireplumber-system.service ${D}${systemd_system_unitdir}/
    install -m 0644 ${WORKDIR}/pipewire-pulse-system.service ${D}${systemd_system_unitdir}/
    install -m 0644 ${WORKDIR}/drivapi-dashboard.service ${D}${systemd_system_unitdir}/
}

SYSTEMD_SERVICE:${PN} = "\
    pipewire-system.service \
    wireplumber-system.service \
    pipewire-pulse-system.service \
    drivapi-dashboard.service \
"

SYSTEMD_AUTO_ENABLE:${PN} = "enable"
