VERSION ?= latest

DOCKERFILE := Dockerfile
IMAGE_NAME := ghcr.io/luislavena/homelab-pocketid

.PHONY: build
build: $(DOCKERFILE)
	docker build -t ${IMAGE_NAME}:${VERSION} -f ${DOCKERFILE} .
