REPO := registry.gitlab.com/gitlab-examples/openshift-deploy:latest

build:
		docker build -t $(REPO) .

build_and_push: build
		docker push $(REPO)

build_test: build
		source .dev_env && cd examples/rails-app/ && ../../build

deploy_test: build
		source .dev_env && cd examples/rails-app/ && ../../deploy

build_and_enter: build
		docker run --privileged -it --rm -v $(shell pwd):/app -w /app $(REPO) /bin/bash --login

.PHONY: build build_and_push build_test build_and_enter deploy_test
