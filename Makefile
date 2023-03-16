SHELL:=/bin/bash

.DEFAULT_GOAL := help

DOCKER_FILE:=Dockerfile.lizard
ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")

.EXPORT_ALL_VARIABLES:
MAKEFLAGS += --no-print-directory
DOCKER_BUILDKIT?=1
DOCKER_CONFIG:=

include ${ROOT_DIR}/lizard_docker.mk

.PHONY: help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: all
all: build

.PHONY: clean 
clean: ## Clean cppclint docker context
	cd "${LIZARD_DOCKER_MAKEFILE_PATH}" && find . -name "**lizard_report.log" -exec rm -rf {} \;
	cd "${LIZARD_DOCKER_MAKEFILE_PATH}" && find . -name "**lizard_report.xml" -exec rm -rf {} \;
	docker rm $$(docker ps -a -q --filter "ancestor=${LIZARD_PROJECT}:${LIZARD_TAG}") 2> /dev/null || true
	docker rmi $$(docker images -q ${LIZARD_PROJECT}:${LIZARD_TAG}) 2> /dev/null --force || true
	docker rmi ${LIZARD_PROJECT}:${LIZARD_TAG} --force 2> /dev/null

.PHONY: build
build: clean ## build lizard docker image
	cd "${LIZARD_DOCKER_MAKEFILE_PATH}" && docker build --network host -t "${LIZARD_PROJECT}:${LIZARD_TAG}" -f "${DOCKER_FILE}" .

.PHONY: build_fast
build_fast: # Build docker context only if it does not already exist
	@if [ -n "$$(docker images -q ${LIZARD_PROJECT}:${LIZARD_TAG})" ]; then \
        echo "Docker image: ${LIZARD_PROJECT}:${LIZARD_TAG} already build, skipping build."; \
    else \
        make build;\
    fi

.PHONY: _lizard 
_lizard: build_fast 
	@if [ -z $${CPP_PROJECT_DIRECTORY+x} ]; then \
        echo "ERROR: Environmental variable: CPP_PROJECT_DIRECTORY not set. You must provide a CPP_PROJECT_DIRECTORY, which is an absolute path to a cpp source code directory." >&2; \
        exit 1; \
    fi
	cd "${LIZARD_DOCKER_MAKEFILE_PATH}" && find . -name "**lizard_report.log" -exec rm -rf {} \;
	cd "${LIZARD_DOCKER_MAKEFILE_PATH}" && find . -name "**lizard_report.log" -exec rm -rf {} \;
	cd "${CPP_PROJECT_DIRECTORY}" && find . -name "**lizard_report.xml" -exec rm -rf {} \;
	cd "${CPP_PROJECT_DIRECTORY}" && find . -name "**lizard_report.xml" -exec rm -rf {} \;
	cd ${LIZARD_DOCKER_MAKEFILE_PATH} && \
    docker run -v "${CPP_PROJECT_DIRECTORY}:/tmp/lizard" ${LIZARD_PROJECT}:${LIZARD_TAG}
	BASE_DIR=$$(basename "${CPP_PROJECT_DIRECTORY}") && \
    mv "${CPP_PROJECT_DIRECTORY}/lizard_report.log" "${CPP_PROJECT_DIRECTORY}/$${BASE_DIR}_lizard_report.log" && \
    mv "${CPP_PROJECT_DIRECTORY}/lizard_report.xml" "${CPP_PROJECT_DIRECTORY}/$${BASE_DIR}_lizard_report.xml"



.PHONY: lizard_demo 
lizard_demo:
	cd "${LIZARD_DOCKER_MAKEFILE_PATH}" && make lizard CPP_PROJECT_DIRECTORY="${LIZARD_DOCKER_MAKEFILE_PATH}/hello_world"
