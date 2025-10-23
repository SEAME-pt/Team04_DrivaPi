FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV QT_QPA_PLATFORM=offscreen

WORKDIR /workspace

RUN apt-get update && apt-get install -y \
	build-essential cmake git \
	qt6-base-dev qt6-declarative-dev \
	qml6-module-qtquick qml6-module-qtquick-window \
	qml6-module-qtquick-layouts qml6-module-qtquick-controls \
	libqt6core5compat6-dev \
	&& rm -rf /var/lib/apt/lists/*

COPY . /workspace/

RUN mkdir -p build && cd build && \
	qmake6 ../seame-hmi.pro CONFIG+=release && \
	make -j$(nproc)

FROM ubuntu:22.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV QT_QPA_PLATFORM=wayland

RUN apt-get update && apt-get install -y \
	libqt6core6 libqt6gui6 libqt6qml6 libqt6quick6 \
	qml6-module-qtquick qml6-module-qtquick-window \
	qml6-module-qtquick-layouts qml6-module-qtquick-controls \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=builder /workspace/build/bin/SEA_ME_HMI_Dashboard /app/SEA_ME_HMI_Dashboard

WORKDIR /app
CMD ["/app/SEA_ME_HMI_Dashboard"]
