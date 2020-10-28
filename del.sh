#!/bin/bash

readonly ENDPOINT="https://api.github.com"
readonly CUSTOMHEADER="Accept: application/vnd.github.v3.repository+json"

curl \
    -X PATCH \
    -H "$CUSTOMHEADER" \
    -H "Authorization: token $TOKEN" \
    "$ENDPOINT/orgs/$ORG/teams/$CHILD_TEAM" \
    -d "{\"parent_team_id\":null}"