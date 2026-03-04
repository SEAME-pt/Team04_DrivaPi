SUMMARY = "Packagegroup DrivaPi Dashboard (Qt6+ multimedia + maps)"
LICENSE = "MIT"

ALLOW_EMPTY:${PN} = "1"

RDEPENDS:${PN} = "\
    drivapi-audio \
    qt-app \
    qtmultimedia \
    qtmultimedia-plugins \
    qtmultimedia-qmlplugins \
    qtlocation \
    qtlocation-qmlplugins \
    qtpositioning \
    qtpositioning-qmlplugins \
    qtsvg-plugins \
    gstreamer1.0-plugins-base-alsa \
    gstreamer1.0-plugins-base-playback \
    gstreamer1.0-plugins-base-audioconvert \
    gstreamer1.0-plugins-base-audioresample \
    gstreamer1.0-plugins-base-typefindfunctions \
    gstreamer1.0-plugins-good-id3demux \
    gstreamer1.0-plugins-good-mpg123 \
    gstreamer1.0-pipewire \
    pipewire \
    pipewire-pulse \
    pipewire-alsa \
    wireplumber \
"
