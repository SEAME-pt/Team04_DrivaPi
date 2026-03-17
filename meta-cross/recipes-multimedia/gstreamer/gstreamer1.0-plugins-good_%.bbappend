# Enable building the PulseAudio plugin (libgstpulseaudio.so -> pulsesink/pulsesrc)
PACKAGECONFIG:append:pn-gstreamer1.0-plugins-good = " pulseaudio"
