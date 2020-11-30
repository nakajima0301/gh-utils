#!/bin/bash

readonly ENDPOINT="https://api.github.com"
readonly CUSTOMHEADER="Accept: application/vnd.github.v3.repository+json"

function pre_process() {
  echo "-----Input Parameters------"
  echo "org: $ORG"
  echo "team: $TEAM"
  echo "---------------------"

  # Empty check
  if [[ $TEAM == "" ]]; then
    echo "ERROR: TEAM is empty, exit."
    exit 1
  fi

  # Validate team
  IFS_BUCKUP=$IFS_BACKUP
  IFS=$(echo -en "\n\t")

  exit_code=0
  validate_team $TEAM || exit_code=$?
  if [[ $exit_code == 1 ]]; then
    echo "-> $TEAM"
    echo "ERROR: Invalid team name, exit."
    exit 1
  fi
}

function validate_team() {
  local team_name
  team_name=$1

  regex='[a-zA-Z0-9_-]*'
  if [[ $team_name =~ $regex ]]; then
    if [[ ${BASH_REMATCH[0]} != $team_name ]]; then
      return 1
    fi
  fi
}

function check_parent() {
  local team=$1

  res=`curl -sS -H "$CUSTOMHEADER" -H "Authorization: token $TOKEN" -w "%{http_code}" "$ENDPOINT/orgs/$ORG/teams/$team"`
  local body=`echo "$res" | sed '$d'`
  local http_status=`echo $res | tail -c 4`

  if [[ "$http_status" != "200" ]]; then
    echo "ERROR: $team not found."
    return 1
  fi

  parent=`echo $body | jq -r .parent.name`
  echo "Parent: $parent"
}

function main() {
  pre_process

  exit_code=0
  check_parent $TEAM || exit_code=$?
  echo ""
  if [[ "$exit_code" == 1 ]]; then
    exit 1
  fi
}

main
