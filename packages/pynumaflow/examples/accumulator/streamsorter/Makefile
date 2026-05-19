DOCKER = podman
TAG ?= v0.13.0
PUSH ?= false
IMAGE_REGISTRY = 192.168.21.17:30003/dci-community-general/streamsorter-blackhole:${TAG}
DOCKER_FILE_PATH = examples/accumulator/streamsorter/Dockerfile

.PHONY: update
update:
	uv lock --check || uv lock

.PHONY: image-push
image-push: update
	cd ../../../ && ${DOCKER} buildx build \
	-f ${DOCKER_FILE_PATH} \
	-t ${IMAGE_REGISTRY} \
	--platform linux/amd64,linux/arm64 . --push

.PHONY: image
image: update
	cd ../../../ && ${DOCKER} build \
	-f ${DOCKER_FILE_PATH} \
	-t ${IMAGE_REGISTRY} .
	@if [ "$(PUSH)" = "true" ]; then ${DOCKER} push ${IMAGE_REGISTRY}; fi
