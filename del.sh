#!/bin/bash

readonly ENDPOINT="https://api.github.com"
readonly CUSTOMHEADER="Accept: application/vnd.github.v3.repository+json"

function pre_process() {
  echo "-----Input Parameters------"
  echo "org: $ORG"
  echo "child team: $CHILD_TEAMS"
  echo "---------------------"

  # Result
  success_teams=()
  failure_teams=()

  # Empty check
  if [[ $PARENT_TEAM == "" ]]; then
    echo "ERROR: PARENT_TEAM is empty, exit."
    exit 1
  elif [[ $CHILD_TEAMS == "" ]]; then
    echo "ERROR: CHILD_TEAMS is empty, exit."
    exit 1
  fi

  # Validate child_team
  validated_child_teams=()
  while read -a line; do
    # 空白行をスキップ
    if [[ "${line[*]}" == "" ]]; then
      continue
    fi

    team_name=`echo $(IFS=","; echo "${line[*]}") | sed -e "s/,/ /g"`

    exit_code=0
    validate_team "$team_name" || exit_code=$?
    if [[ $exit_code != 1 ]]; then
      validated_child_teams+=("$team_name")
    else
      echo "-> $team_name"
      echo "ERROR: Invalid child team name, skip."
      failure_teams+=("$team_name")
    fi
  done < <(echo "$CHILD_TEAMS")
}

function delete_parent() {
  local child_team=$1
  echo "-> $child_team"

  # 子チームに親チームが設定されているかチェック
  # 親チームが設定されていない場合はエラーメッセージを表示して処理を中断する
  local res=`curl -sS -H "$CUSTOMHEADER" -H "Authorization: token $TOKEN" -w "%{http_code}" "$ENDPOINT/orgs/$ORG/teams/$child_team"`
  local http_status=`echo $res | tail -c 4`
  local has_parent=`echo ${res::${#res}-4} | jq '.parent'`

  if [[ "$http_status" != "200" ]]; then
    echo "ERROR: $child_team not found."
    return 1
  fi

  if [[ "$has_parent" == "null" ]]; then
    echo "ERROR: $child_team does not have a parent team."
    return 1
  fi

  # 子チームから親チームを削除する
  local res=`curl -sS -X PATCH -H "$CUSTOMHEADER" -H "Authorization: token $TOKEN" -w "%{http_code}" "$ENDPOINT/orgs/$ORG/teams/$child_team" -d "{\"parent_team_id\":null}"`
  local http_status=`echo $res | tail -c 4`
  local parent=`echo ${res::${#res}-4} | jq '.parent'`

  echo $parent
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

function result() {
  IFS_BUCKUP=$IFS
  IFS=$(echo -en "\n\t")
  
  echo ""
  echo "===== SUCCESS ====="

  for name in ${success_teams[@]}; do
    echo "$name"
  done

  echo "===== ERROR ======"

  for name in ${failure_teams[@]}; do
    echo "$name"
  done

  echo "================="
  echo ""
  
  IFS=$IFS_BUCKUP
}

function main() {
  pre_process

  for team_name in ${validated_child_teams[@]}; do
    exit_code=0
    delete_parent $team_name || exit_code=$?
    if [[ "$exit_code" == 1 ]]; then
      failure_teams+=("$team_name")
    else
      success_teams+=("$team_name")
    fi
  done

  result

  # 一つでも処理に失敗したチームが存在する場合はjenkinsの状態をfailureにする
  if [[ ${#failure_teams[@]} != 0 ]]; then
    echo "build failure"
    exit 1
  else
    echo "The process was completed successfully."
  fi
}

main
