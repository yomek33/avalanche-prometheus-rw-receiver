#!/bin/bash

DIR="/go/src/github.com/prometheus/prometheus"
PR_NUMBER=14498
VOLUME_DIR="/etc"
GITHUB_ORG="prometheus"
GITHUB_REPO="prometheus"

if [[ -z $PR_NUMBER || -z $VOLUME_DIR || -z $GITHUB_ORG || -z $GITHUB_REPO ]]; then
    echo "ERROR:: Environment variables not set correctly"
    exit 1
fi

# Check if the directory exists and is not empty
if [ -d "$DIR" ] && [ "$(ls -A $DIR)" ]; then
    echo ">> Directory $DIR already exists and is not empty."
    echo ">> Removing existing directory."
    rm -rf "$DIR"
fi

echo ">> Cloning repository $GITHUB_ORG/$GITHUB_REPO"
if ! git clone https://github.com/$GITHUB_ORG/$GITHUB_REPO.git $DIR; then
    echo "ERROR:: Cloning of repo $GITHUB_ORG/$GITHUB_REPO failed"
    exit 1
fi

cd $DIR || exit 1

echo ">> Fetching Pull Request $GITHUB_ORG/$GITHUB_REPO/pull/$PR_NUMBER"
if ! git fetch origin pull/$PR_NUMBER/head:pr-branch; then
    echo "ERROR:: Fetching of PR $PR_NUMBER failed"
    exit 1
fi

git checkout pr-branch

echo ">> Creating prometheus binaries"
if ! make build PROMU_BINARIES="prometheus"; then
    echo "ERROR:: Building of binaries failed"
    exit 1
fi

echo ">> Copy files to volume"
cp prometheus               $VOLUME_DIR/prometheus
cp -r console_libraries/    $VOLUME_DIR
cp -r consoles/             $VOLUME_DIR

