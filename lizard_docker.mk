
ifeq ($(filter lizard_docker.mk, $(notdir $(MAKEFILE_LIST))), lizard_docker.mk)

LIZARD_DOCKER_MAKEFILE_PATH:=$(strip $(shell realpath "$(shell dirname "$(lastword $(MAKEFILE_LIST))")"))

LIZARD_PROJECT=lizard
LIZARD_TAG:=latest
MAKEFLAGS += --no-print-directory

.PHONY: lizard 
lizard: ## Print out lizard static analysis report for source code (see: https://github.com/terryyin/lizard)
	cd "${LIZARD_DOCKER_MAKEFILE_PATH}" && \
    make _lizard

endif
