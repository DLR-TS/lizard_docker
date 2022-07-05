SHELL:=/bin/bash

.DEFAULT_GOAL := all

PROJECT="lizard"
VERSION="latest"
TAG="${PROJECT}:${VERSION}"

ROOT_DIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
MAKEFLAGS += --no-print-directory
.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=


.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: all
all: build

.PHONY: clean
clean:
	docker rm $$(docker ps -a -q --filter "ancestor=${TAG}") 2> /dev/null || true
	docker rmi $$(docker images -q ${TAG}) 2> /dev/null || true
	docker rmi ${TAG} --force 2> /dev/null

.PHONY: build
build: clean
	docker build -t ${TAG} -f Dockerfile.lizard .

.PHONY: build_check
build_check:
	@[ -n "$$(docker images -q ${TAG} 2> /dev/null)" ] && \
          echo "" || \
          make build

.PHONY: check_CPP_PROJECT_DIRECTORY
check_CPP_PROJECT_DIRECTORY:
	@[ "${CPP_PROJECT_DIRECTORY}" ] || ( echo "CPP_PROJECT_DIRECTORY is not set. You must provide a project directory. make <target> CPP_PROJECT_DIRECTORY=<absolute path to cpp source code>"; exit 1 )

.PHONY: lizard
lizard: build_check check_CPP_PROJECT_DIRECTORY 
	@docker run -v ${CPP_PROJECT_DIRECTORY}:/tmp/out -v ${CPP_PROJECT_DIRECTORY}:/home/lizard/$$(basename ${CPP_PROJECT_DIRECTORY}) ${TAG}

