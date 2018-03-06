#!/usr/bin/env bash

cd `dirname $0`

find test -name '*.bats' | xargs bats
