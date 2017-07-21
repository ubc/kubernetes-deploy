set -eo pipefail

[[ "$TRACE" ]] && set -x

export CI_CONTAINER_NAME="ci_job_build_$CI_BUILD_ID"
export CI_REGISTRY_TAG="$CI_BUILD_REF_SLUG"

create_kubeconfig() {
  [[ -z "$KUBE_URL" ]] && return

  echo "Generating kubeconfig..."
  export KUBECONFIG="$(pwd)/kubeconfig"
  export KUBE_CLUSTER_OPTIONS=
  if [[ -n "$KUBE_CA_PEM" ]]; then
    echo "Using KUBE_CA_PEM..."
    echo "$KUBE_CA_PEM" > "$(pwd)/kube.ca.pem"
    export KUBE_CLUSTER_OPTIONS=--certificate-authority="$(pwd)/kube.ca.pem"
  fi
  kubectl config set-cluster gitlab-deploy --server="$KUBE_URL" \
    $KUBE_CLUSTER_OPTIONS
  kubectl config set-credentials gitlab-deploy --token="$KUBE_TOKEN" \
    $KUBE_CLUSTER_OPTIONS
  kubectl config set-context gitlab-deploy \
    --cluster=gitlab-deploy --user=gitlab-deploy \
    --namespace="$KUBE_NAMESPACE"
  kubectl config use-context gitlab-deploy
  echo ""
}

ensure_environment_url() {
  # [[ -n "$CI_ENVIRONMENT_URL" ]] && return

  echo "Reading CI_ENVIRONMENT_URL from .gitlab-ci.yml..."
  CI_ENVIRONMENT_URL="$(ruby -ryaml -e 'puts YAML.load_file(".gitlab-ci.yml")[ENV["CI_BUILD_NAME"]]["environment"]["url"]')"
  CI_ENVIRONMENT_URL="$(eval echo "$CI_ENVIRONMENT_URL")"
  echo "CI_ENVIRONMENT_URL: $CI_ENVIRONMENT_URL"
}

ensure_deploy_variables() {
  if [[ -z "$KUBE_NAMESPACE" ]]; then
    echo "Missing KUBE_NAMESPACE."
    exit 1
  fi

  if [[ -z "$CI_ENVIRONMENT_SLUG" ]]; then
    echo "Missing CI_ENVIRONMENT_SLUG."
    exit 1
  fi

  if [[ -z "$CI_ENVIRONMENT_URL" ]]; then
    echo "Missing CI_ENVIRONMENT_URL."
    exit 1
  fi
}

ping_kube() {
  if kubectl version > /dev/null; then
    echo "Kubernetes is online!"
    echo ""
  else
    echo "Cannot connect to Kubernetes."
    return 1
  fi
}
