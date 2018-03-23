SHELL = /usr/bin/env bash -xeuo pipefail

include Makevars

TEST_INTEG_TARGETS := $(shell find test -name '*.bats')

GIT_COMMIT := $(shell git log -n 1 --format=%h)
ZIP_FILE := $(GIT_COMMIT).zip
UPLOAD_FILE := deploy/$(ZIP_FILE)
BASE := src/functions
DIR := $(sort $(dir $(wildcard $(BASE)/*/)))
TARGETS := $(patsubst $(BASE)/%/, %, $(DIR))
UPLOAD_TASK := $(addprefix upload-, $(TARGETS))
DEPLOY_TASK := $(addprefix deploy-, $(TARGETS))


all: guard-env clean test-unit test-integ dist $(UPLOAD_TASK) $(DEPLOY_TASK)
	@echo $(UPLOAD_TASK)
	@echo $(DEPLOY_TASK)

install:
	@pip install -r requirements.txt

localstack-up:
	@docker-compose up -d localstack

localstack-stop:
	@docker-compose stop localstack

test-unit:
	python -m pytest

test-integ: localstack-up
	@echo $(TEST_INTEG_TARGETS)
	@echo $(DOCKER_NAME)
	@DOCKER_NAME=$(DOCKER_NAME) bats $(TEST_INTEG_TARGETS)

clean:
	-rm -rf deploy/
	-rm packaged-*.yaml

dist:
	@pip install -r requirements.txt -t deploy
	@cp -R src deploy
	@cd deploy && \
	zip -r $(GIT_COMMIT).zip *

upload: guard-env clean dist $(UPLOAD_TASK)
	@echo $(TARGETS)
	@echo $(UPLOAD_TASK)
	@echo $(DEPLOY_TASK)

deploy: guard-env $(DEPLOY_TASK)
	@echo $(TARGETS)
	@echo $(UPLOAD_TASK)
	@echo $(DEPLOY_TASK)

upload-%: $(UPLOAD_FILE)
	@ if [ "${*}" = "" ]; then \
		echo "Target is not set"; \
		exit 1; \
	elif [ ! -d "$(BASE)/${*}" ]; then \
		echo "Target directory $(BASE)/$* does not exists."; \
		exit 1; \
	else \
		s3_keyname="${*}/$(ZIP_FILE)" && \
		echo $${s3_keyname} && \
		aws s3 cp $(UPLOAD_FILE) $(S3_BUCKET_URL)/$${s3_keyname} ; \
	fi

deploy-%: template_%.yaml guard-env
	@ if [ "${*}" = "" ]; then \
		echo "Target is not set"; \
		exit 1; \
	elif [ ! -d "$(BASE)/${*}" ]; then \
		echo "Target directory $(BASE)/$* does not exists."; \
		exit 1; \
	else \
		s3_keyname="${*}/$(ZIP_FILE)" && \
		aws cloudformation package \
			--template-file template_${*}.yaml \
			--s3-bucket $(S3_BUCKET_URL) \
			--output-template-file packaged-${*}.yaml && \
		aws cloudformation deploy \
			--template-file packaged-${*}.yaml \
			--stack-name $${env}-${*}-lambda  \
			--capabilities CAPABILITY_IAM \
			--parameter-overrides \
				Env=$${env} \
				CodeKey=$${s3_keyname} ; \
	fi

guard-%:
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi

.PHONY: \
	install \
	localstack-up \
	localstack-stop \
	test-unit \
	test-integ \
	dist \
	upload \
	clean \
