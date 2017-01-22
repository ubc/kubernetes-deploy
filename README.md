## Kubernetes auto-deployments (EXPERIMENTAL)

This is repository that builds Docker Image with all scripts needed to
deploy to Kubernetes from GitLab CI.

It basically consist of two stages:
1. Build stage where a Docker Image is built,
2. Deploy stage where a previously built Docker Image is run on Kubernetes and
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
1. Create a new namespace if does not exist already,
2. Deploy an application with most recent Docker Image,
3. Create or update ingress to expose the application under hostname.

### Requirements

1. GitLab Runner using Docker or Kubernetes executor with privileged mode enabled,
2. Service account for existing Kubernetes cluster,
3. DNS wildcard domain to host deployed applications.

### Limitations

1. Only public docker images can be deployed,
2. There is no ability to pass environment variables to deployed application,
3. Currently we do not have a way to watch for deployment status and make sure
   that deployment did succeed,
4. Currently we do not have a way to expose `mysql`, `postgres` or other database
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
copy-paste [this `.gitlab-ci.yml`](https://gitlab.com/gitlab-org/gitlab-ci-yml/blob/master/autodeploy/Kubernetes.gitlab-ci.yml).

### License

MIT, GitLab, 2016
