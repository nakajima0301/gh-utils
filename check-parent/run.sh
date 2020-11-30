#!/bin/bash

export ORG="knapitestorg"
export TEAM="Team2f"
# TOKEN -> .bashrc

function usage() {
  echo "Usage: $0 [check]"
}

if [[ $# != 1 ]]; then
  usage
  exit
fi

if [[ $1 == "check" ]]; then
  ./check.sh
else
  usage
fi