#!/bin/bash

readonly ENDPOINT="https://api.github.com"
readonly CUSTOMHEADER="Accept: application/vnd.github.v3.repository+json"

function pre_process() {
  echo "-----Input Parameters------"
  echo "org: $ORG"
  echo "parent team: $PARENT_TEAM"
  echo "child team: $CHILD_TEAM"
  echo "---------------------"

  IFS_BUCKUP=$IFS_BACKUP
  IFS=$(echo -en "\n\t")

  exit_code=0
  validate_team $PARENT_TEAM || exit_code=$?
  if [[ $exit_code == 99 ]]; then
    echo "$PARENT_TEAM: Invalid team"
    exit
  fi

  exit_code=0
  validate_team $CHILD_TEAM || exit_code=$?
  if [[ $exit_code == 99 ]]; then
    echo "$CHILD_TEAM: Invalid team"
    exit
  fi

  IFS=$IFS_BACKUP
}

function validate_team() {
  local team_name
  team_name=$1

  regex='[a-zA-Z0-9_-]*'
  if [[ $team_name =~ $regex ]]; then
    if [[ ${BASH_REMATCH[0]} != $team_name ]]; then
      return 99
    fi
  fi
}

function update_team() {
  # 子チームが親チームを持っている場合はエラーで処理を終了させる
  local res=`curl -sS -H "$CUSTOMHEADER" -H "Authorization: token $TOKEN" -w "%{http_code}" "$ENDPOINT/orgs/$ORG/teams/$CHILD_TEAM"`
  local http_status=`echo $res | tail -c 4`
  local has_parent=`echo ${res::-4} | jq '.parent'`

  if [[ "$http_status" != "200" ]]; then
    echo "ERROR: $CHILD_TEAM not found."
    exit
  fi

  if [[ "$has_parent" != "null" ]]; then
    echo "ERROR: $CHILD_TEAM already has a parent team."
    echo "If you want to change the parent team, please run the delete parent team job first."
    exit
  fi

  local res=`curl -sS -H "$CUSTOMHEADER" -H "Authorization: token $TOKEN" -w "%{http_code}" "$ENDPOINT/orgs/$ORG/teams/$PARENT_TEAM"`
  local http_status=`echo $res | tail -c 4`
  local parent_team_id=`echo ${res::-4} | jq '.id'`

  if [[ "$http_status" != "200" ]]; then
    echo "ERROR: $PARENT_TEAM not found."
    exit
  fi

  curl -sS -X PATCH -H "$CUSTOMHEADER" -H "Authorization: token $TOKEN" "$ENDPOINT/orgs/$ORG/teams/$CHILD_TEAM" -d "{\"parent_team_id\":$parent_team_id}"
}

function main() {
  pre_process
  update_team
}

main
