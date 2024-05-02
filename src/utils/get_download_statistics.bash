#!/usr/bin/env bash

# gh auth login

# See: https://docs.github.com/de/rest/releases/releases?apiVersion=2022-11-28#list-assets-for-a-release

gh api -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" \
/repos/freeella/kubectl-cpbase64/releases | \
jq 'sort_by(.tag_name) | .[] | {  "tag_name": ."tag_name", "assets": .assets[] | {"name": .name, "download_count": ."download_count", "created_at": ."created_at" } }  ' -c

