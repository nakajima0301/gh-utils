#!/bin/bash

export ORG="knapitestorg"
export PARENT_TEAM="Team1"
export CHILD_TEAMS="
Team2
Team3
Team4
Team5
"
# TOKEN -> .bashrc

function usage() {
  echo "Usage: $0 [add|del]"
}

if [[ $# != 1 ]]; then
  usage
  exit
fi

if [[ $1 == "add" ]]; then
  ./add.sh
elif [[ $1 == "del" ]]; then
  ./del.sh
else
  usage
fi