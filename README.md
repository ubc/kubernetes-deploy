## OpenShift auto-deployments (EXPERIMENTAL)

This is repository that builds Docker Image with all scripts needed to
deploy to OpenShift from GitLab CI.

It basically consist of two stages:
1. Build stage where a Docker Image is built,
2. Deploy stage where a previously built Docker Image is run on OpenShift and
   exposed on hostname.

### Build stage

The build script does:
1. Check if the repository has `Dockerfile`,
2. If yes, use `docker build` to build Docker Image,
3. If no, use [herokuish](https://github.com/gliderlabs/herokuish) to build
   and package a buildpack based application,
4. Login to GitLab Container Registry,
5. Push build image to GitLab Container Registry.

### Deploy stage

The deploy script does:
1. Create a new project if does not exist already,
2. Delete old application,
3. Create a new application with most recent Docker Image,
4. Expose route with given hostname for this application.

### Requirements

1. GitLab Runner using Docker or Kubernetes executor with privileged mode enabled,
2. Service account for existing OpenShift cluster,
3. DNS wildcard domain to host deployed applications.

### Limitations

1. Only public docker images can be deployed,
2. There is no upgrades for OpenShift existing deployments,
3. There is no ability to pass environment variables to deployed application,
4. Currently we do not have a way to watch for deployment status and make sure
   that deployment did succeed,
5. Currently we do not have a way to expose `mysql`, `postgres` or other database
   services.

### Examples

You can see existing working examples:
1. [Ruby](https://gitlab.com/gitlab-examples/ruby-openshift-example/)

### How to contribute?

Simply fork this repository. As soon as you push your changes,
the new docker image with all scripts will be build.
You can then start using your own docker image hosted on your Container Registry.

### How to use it?

Basically, configure Kubernetes Service in your project settings and
copy-paste this `.gitlab-ci.yml`:

```
image: registry.gitlab.com/gitlab-examples/openshift-deploy

variables:
  # Application deployment domain
  KUBE_DOMAIN: domain.com

stages:
  - build
  - test
  - review
  - staging
  - production

build:
  stage: build
  script:
    - command build
  only:
    - branches

production:
  stage: production
  variables:
    CI_ENVIRONMENT_URL: http://production.$KUBE_DOMAIN
  script:
    - command deploy
  environment:
    name: production
    url: http://production.$KUBE_DOMAIN
  when: manual
  only:
    - master

staging:
  stage: staging
  variables:
    CI_ENVIRONMENT_URL: http://staging.$KUBE_DOMAIN
  script:
    - command deploy
  environment:
    name: staging
    url: http://staging.$KUBE_DOMAIN
  only:
    - master

review:
  stage: review
  variables:
    CI_ENVIRONMENT_URL: http://$CI_ENVIRONMENT_SLUG.$KUBE_DOMAIN
  script:
    - command deploy
  environment:
    name: review/$CI_BUILD_REF_NAME
    url: http://$CI_ENVIRONMENT_SLUG.$KUBE_DOMAIN
    on_stop: stop_review
  only:
    - branches
  except:
    - master

stop_review:
  stage: review
  variables:
    GIT_STRATEGY: none
  script:
    - command remove
  environment:
    name: review/$CI_BUILD_REF_NAME
    action: stop
  only:
    - branches
  except:
    - master
```

### License

MIT, GitLab, 2016
