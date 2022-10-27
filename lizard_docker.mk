
ifndef cppcheck_docker

cppcheck_docker:=""

.PHONY: lizard 
lizard: ## Print out lizard static analysis report.
	find . -name "**lizard_report.**" -exec rm -rf {} \;
	cd lizard_docker && \
    (make lizard CPP_PROJECT_DIRECTORY=$$(realpath ${ROOT_DIR}/${PROJECT}) | \
    tee ${ROOT_DIR}/${PROJECT}/${PROJECT}_lizard_report.log)
	find . -name "**lizard_report.xml**" -print0 | xargs -0 -I {} mv {} ${PROJECT}/${PROJECT}_lizard_report.xml

endif
