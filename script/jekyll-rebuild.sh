#!/bin/bash

if [$TRAVIS_PULL_REQUEST == "true"]; then
  echo "this is a PR, exiting"
  exit 0
fi

set -e

rm -rf _site
mkdir _site

git clone https://${GH_TOKEN}@github.com/jplesperance/jplesperance.github.io --branch master _site

cd _site
git config user.email "jesse@lesperance.io"
git config user.name "Jesse Lesperance"
git commit -a -m "rebuilding pages"
git push origin master

git reset HEAD~
git push origin master --force
