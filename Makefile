REPO := ayufan/gitlab-kubernetes-deploy

build_and_push:
		docker build -t $(REPO) .
		docker push $(REPO)

build_test:
		source .dev_env && cd examples/rails-app/ && ../../build

deploy_test:
		source .dev_env && cd examples/rails-app/ && ../../deploy

build_and_enter:
		docker build -t $(REPO) .
		docker run --privileged -it --rm -v $(shell pwd):/app -w /app $(REPO) /bin/bash --login

.PHONY: build_and_push build_test
