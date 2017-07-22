GITHUB_API_BASE=https://api.github.com

# if GITHUB_TOKEN is defined, setup auth file for ok.sh
if [[ $GITHUB_TOKEN ]]; then
    echo -e "machine api.github.com\n\tlogin user\n\tpassword $GITHUB_TOKEN\n" > ~/.netrc
    chmod 600 ~/.netrc
fi

ensure_github() {
  if [[ ! -f ~/.netrc ]]; then
    echo "ok.sh authentication ~/.netrc doesn't exists."
    return 1
  fi

  if [[ -z "$GITHUB_REPO" ]]; then
    echo "Missing GITHUB_REPO for posting status"
    return 1
  fi
}

# post a status on github PR/commit
# github_post_status STATUS
# https://developer.github.com/v3/repos/statuses/#create-a-status
github_post_status() {
  ensure_github

  msg=(state=$1 target_url=$CI_PROJECT_URL/-/jobs/$CI_JOB_ID context=$CI_JOB_STAGE description="$2")
  ok.sh _format_json "${msg[@]}" | ok.sh _post $GITHUB_API_BASE/repos/$GITHUB_REPO/statuses/$CI_COMMIT_SHA > /dev/null
}

# github_post_comment ISSUE MESSAGE
github_post_comment() {
  ensure_github

  ok.sh _format_json body="$2" | ok.sh _post $GITHUB_API_BASE/repos/$GITHUB_REPO/issues/$1/comments > /dev/null
}

github_post_issue_comment() {
  if [[ "$CI_COMMIT_REF_NAME" != pull* ]]; then
    echo "The branch $CI_COMMIT_REF_NAME is not github issue related. Should be in the form of 'pull/ISSUE #/head'"
    return 1
  fi

  ISSUE=$(echo "$CI_COMMIT_REF_NAME" | sed 's/pull\/\([0-9]*\)\/.*/\1/')

  github_post_comment $ISSUE "$1"
}

