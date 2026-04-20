HARBOR        := zdc-ai-harbor.ecouncil.ae/agent-plane
DATE          := $(shell date +%Y%m%d)
CTR           ?= podman

TAG           ?= $(DATE)
IMAGE         := $(HARBOR)/hermes-base:$(TAG)

UPSTREAM_TAG  ?= $(TAG)
UPSTREAM_IMAGE := docker.io/nousresearch/hermes-agent:$(UPSTREAM_TAG)

.PHONY: help build push build-push login mirror

help:
	@echo "Usage:"
	@echo "  make login                       Log in to harbor (--tls-verify=false)"
	@echo "  make build                       Build hermes-base image locally (tag: $(TAG))"
	@echo "  make push                        Push hermes-base image to harbor"
	@echo "  make build-push                  Build and push in one step"
	@echo "  make mirror                      Pull upstream image and push to harbor (no build)"
	@echo ""
	@echo "Override tag:          make mirror TAG=v0.10.0"
	@echo "Override upstream tag: make mirror UPSTREAM_TAG=latest TAG=v0.10.0"
	@echo "Override engine:       make build-push CTR=docker"
	@echo "Harbor image:          $(IMAGE)"
	@echo "Upstream image:        $(UPSTREAM_IMAGE)"

login:
	$(CTR) login --tls-verify=false $(HARBOR)

build:
	@echo "Building $(IMAGE)..."
	$(CTR) build -t $(IMAGE) .

push:
	$(CTR) push --tls-verify=false $(IMAGE)

build-push: build push

mirror:
	@echo "Pulling $(UPSTREAM_IMAGE)..."
	$(CTR) pull $(UPSTREAM_IMAGE)
	$(CTR) tag $(UPSTREAM_IMAGE) $(IMAGE)
	@echo "Pushing $(IMAGE)..."
	$(CTR) push --tls-verify=false $(IMAGE)
