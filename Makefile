SHELL:=/bin/bash

.DEFAULT_GOAL := help

DOCKER_FILE:=Dockerfile.lizard
ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")
MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
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
	find . -name "**lizard_report.log" -exec rm -rf {} \;
	find . -name "**lizard_report.xml" -exec rm -rf {} \;
	docker rm $$(docker ps -a -q --filter "ancestor=${LIZARD_PROJECT}:${LIZARD_TAG}") 2> /dev/null || true
	docker rmi $$(docker images -q ${LIZARD_PROJECT}:${LIZARD_TAG}) 2> /dev/null --force || true
	docker rmi ${LIZARD_PROJECT}:${LIZARD_TAG} --force 2> /dev/null

.PHONY: build
build: clean ## build lizard docker image
	docker build --network host -t "${LIZARD_PROJECT}:${LIZARD_TAG}" -f "${DOCKER_FILE}" .

.PHONY: build_fast
build_fast: # Build docker context only if it does not already exist
	@if [ -n "$$(docker images -q ${LIZARD_PROJECT}:${LIZARD_TAG})" ]; then \
        echo "Docker image: ${LIZARD_PROJECT}:${LIZARD_TAG} already build, skipping build."; \
    else \
        make build;\
    fi

.PHONY: _lizard 
_lizard: build_fast 
	find . -name "**lizard_report.log" -exec rm -rf {} \;
	find . -name "**lizard_report.xml" -exec rm -rf {} \;
ifndef CPP_PROJECT_DIRECTORY
	$(error CPP_PROJECT_DIRECTORY "ERROR: Environmental variable: CPP_PROJECT_DIRECTORY not set. You must provide a CPP_PROJECT_DIRECTORY, which is an absolute path to a cpp source code directory.")
endif
	cd ${LIZARD_MAKEFILE_PATH} && \
    docker run -v "${CPP_PROJECT_DIRECTORY}:/tmp/lizard" ${LIZARD_PROJECT}:${LIZARD_TAG} | \
    tee ${CPP_PROJECT_DIRECTORY}/lizard_report.log; exit $$PIPESTATUS

.PHONY: lizard_demo
lizard_demo: ## show a demo with provided hello_world project
	make _lizard CPP_PROJECT_DIRECTORY="$$(realpath ./hello_world)"
