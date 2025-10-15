IMAGE ?= team04-doorstop:3.13
WORKDIR ?= /workspace

.PHONY: build run help doorstop create-urd create-srd create-swd create-lltc

build:
	docker build -t $(IMAGE) .

run:
	docker run --rm -it -v "$(PWD)":$(WORKDIR) -w $(WORKDIR) $(IMAGE) --help

doorstop:
	# pass arguments via args variable, e.g.:
	# make doorstop args="create URD ./reqs/urd -f"
	@if [ -z "$(args)" ]; then \
		echo "Usage: make doorstop args=\"<doorstop args>\""; exit 1; \
	fi
	docker run --rm -it -v "$(PWD)":$(WORKDIR) -w $(WORKDIR) $(IMAGE) $(args)

create-urd:
	docker run --rm -it -v "$(PWD)":$(WORKDIR) -w $(WORKDIR) $(IMAGE) URD ./reqs/urd -f

create-srd:
	docker run --rm -it -v "$(PWD)":$(WORKDIR) -w $(WORKDIR) $(IMAGE) SRD ./reqs/srd -p URD -f

create-swd:
	docker run --rm -it -v "$(PWD)":$(WORKDIR) -w $(WORKDIR) $(IMAGE) SWD ./reqs/swd -p SRD -f

create-lltc:
	docker run --rm -it -v "$(PWD)":$(WORKDIR) -w $(WORKDIR) $(IMAGE) LLTC ./reqs/lltc -p SWD -f

help:
	@echo "Makefile targets:"
	@echo "  make build        # build docker image"
	@echo "  make run          # run doorstop --help inside container"
	@echo "  make doorstop args=\"<doorstop args>\"  # run arbitrary doorstop command in container"
	@echo "  make create-urd   # create URD in ./reqs/urd"
	@echo "  make create-srd   # create SRD in ./reqs/srd (parent URD)"
	@echo "  make create-swd   # create SWD in ./reqs/swd (parent SRD)"
	@echo "  make create-lltc  # create LLTC in ./reqs/lltc (parent SWD)"
