SHELL = /usr/bin/env bash -xeuo pipefail

include Makevars

GIT_COMMIT := $(shell git log -n 1 --format=%h)
ZIP_FILE := $(GIT_COMMIT).zip
UPLOAD_FILE := deploy/$(ZIP_FILE)
BASE := src/functions/handlers
TEMPLATES := $(sort $(notdir $(wildcard templates/template_*.yaml)))
TARGETS := $(patsubst template_%.yaml, %, $(TEMPLATES))

UPLOAD_TASK := $(addprefix upload-, $(TARGETS))
DEPLOY_TASK := $(addprefix deploy-, $(TARGETS))



all: guard-env clean format test-unit dist $(UPLOAD_TASK) $(DEPLOY_TASK)
	@echo $(UPLOAD_TASK)
	@echo $(DEPLOY_TASK)

display:
	@echo $(TARGETS)
	@echo $(UPLOAD_TASK)
	@echo $(DEPLOY_TASK)

install:
	@pip install -r requirements.txt

localstack-up:
	@docker-compose up -d localstack

localstack-stop:
	@docker-compose stop localstack

format:
	-yapf -ir src/
	-yapf -ir test/

test-unit:
	@python -m pytest test/

clean:
	-rm -rf deploy/
	-rm packaged-*.yaml
	-rm template_*.yaml

dist: format
	@pip install -r requirements.txt -t deploy
	@cp -R src deploy
	@find deploy -type f -name \*.pyc -o -name \*.pyo | xargs rm
	@find deploy -type d -name __pycache__ | xargs rm -r
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

upload-%: guard-env $(UPLOAD_FILE)
	@ if [ "${*}" = "" ]; then \
		echo "Target is not set"; \
		exit 1; \
	elif [ ! -d "$(BASE)/${*}" ]; then \
		echo "Target directory $(BASE)/$* does not exists."; \
		exit 1; \
	else \
		s3_keyname="${*}/$(ZIP_FILE)" && \
		echo $${s3_keyname} && \
		aws s3 cp $(UPLOAD_FILE) s3://$${env}-$(S3_BUCKET)/$${s3_keyname} ; \
	fi

deploy-%: templates/template_%.yaml guard-env guard-account_id
	@ if [ "${*}" = "" ]; then \
		echo "Target is not set"; \
		exit 1; \
	elif [ ! -d "$(BASE)/${*}" ]; then \
		echo "Target directory $(BASE)/$* does not exists."; \
		exit 1; \
	else \
		cat templates/template_${*}.yaml templates/lambda_common_parameters.yaml > template_${*}.yaml && \
		stack_name_hyphen=$(subst _,-,$(*)) && \
		s3_keyname="${*}/$(ZIP_FILE)" && \
		aws cloudformation package \
			--template-file template_${*}.yaml \
			--s3-bucket $${env}-$(S3_BUCKET) \
			--output-template-file packaged-${*}.yaml && \
		aws cloudformation deploy \
			--template-file packaged-${*}.yaml \
			--stack-name $${env}-$${stack_name_hyphen}-lambda  \
			--capabilities CAPABILITY_IAM \
			--no-fail-on-empty-changeset \
			--parameter-overrides \
				Env=$${env} \
				AccountId=$${account_id} \
				Region=ap-northeast-1 \
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
	dist \
	upload \
	clean \
	format
