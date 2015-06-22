#!/bin/bash

docker build -t lidcore/base:`git log --pretty=format:'%h' -n 1` .
