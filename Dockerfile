FROM docker:dind

# Install requirements
RUN apk add -U curl tar gzip bash ca-certificates && \
  wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub && \
  wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.23-r3/glibc-2.23-r3.apk && \
  apk add glibc-2.23-r3.apk && \
  rm glibc-2.23-r3.apk

# Install Helm
#RUN curl https://kubernetes-helm.storage.googleapis.com/helm-v2.0.2-linux-amd64.tar.gz | \
#  tar zx && mv linux-amd64/helm /usr/bin/ && \
#  helm version --client

## Install Helm Canary
#RUN curl https://kubernetes-helm.storage.googleapis.com/helm-canary-linux-amd64.tar.gz | \
#  tar zx && mv linux-amd64/helm /usr/bin/ && \
#  helm version --client

# Install kubectl
RUN curl -L -o /usr/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
  chmod +x /usr/bin/kubectl && \
  kubectl version --client

# Install OpenShift OC
RUN curl -L https://github.com/openshift/origin/releases/download/v1.3.2/openshift-origin-client-tools-v1.3.2-ac1d579-linux-64bit.tar.gz | \
  tar zx && mv openshift-origin-client-tools-v1.3.2-ac1d579-linux-64bit/oc /usr/bin/ && \
  oc version

# Install deploy scripts
ENV PATH=/opt/kubernetes-deploy:$PATH
COPY / /opt/kubernetes-deploy/
RUN ln -s /opt/kubernetes-deploy/run /usr/bin/deploy && \
  which deploy && \
  which build && \
  which destroy

ENTRYPOINT []
CMD []
