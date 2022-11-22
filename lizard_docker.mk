
ifndef LIZARD_MAKEFILE_PATH 

LIZARD_MAKEFILE_PATH:=$(shell realpath "$(shell dirname "$(lastword $(MAKEFILE_LIST))")")

LIZARD_PROJECT=lizard
LIZARD_TAG:=latest

.PHONY: lizard 
lizard: ## Print out lizard static analysis report for source code
	cd ${LIZARD_MAKEFILE_PATH} && \
    make _lizard

endif
