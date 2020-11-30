#!/bin/bash

export ORG="knapitestorg"
export TEAM="Parent"
# TOKEN -> .bashrc

function usage() {
  echo "Usage: $0 [list]"
}

if [[ $# != 1 ]]; then
  usage
  exit
fi

if [[ $1 == "list" ]]; then
  ./list.sh
else
  usage
fi