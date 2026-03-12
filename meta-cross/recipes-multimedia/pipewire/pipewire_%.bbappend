# Ensure PipeWire is built with udev support (so libspa-udev + alsa monitor via udev exist)
PACKAGECONFIG:append = "udev"

# If any layer disables udev explicitly, drop it
EXTRA_OEMESON:remove = "-Dudev=disabled"
