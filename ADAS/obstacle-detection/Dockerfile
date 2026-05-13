FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
	python3-pip \
	python3-dev \
	libgl1-mesa-glx \
	libglib2.0-0 \
	curl \
	unzip \
	graphviz \
	libgraphviz-dev \
	pkg-config \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY requirements.txt .
RUN pip3 install --upgrade pip && pip3 install -r requirements.txt

COPY hailo_dataflow_compiler-*.whl .
RUN pip3 install hailo_dataflow_compiler-*.whl

CMD ["python3", "inference/compile.py", "--run"]
