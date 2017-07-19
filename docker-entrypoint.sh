#!/bin/bash

if [[ $DEPLOYMENT_KEY ]]; then
    eval $(ssh-agent -s)
    ssh-add <(echo "$DEPLOYMENT_KEY")
    mkdir -p ~/.ssh
    echo -e "Host *\n\tStrictHostKeyChecking no\n\n" > ~/.ssh/config
    chmod 700 ~/.ssh
    chmod 400 ~/.ssh/config
fi

exec "$@"
