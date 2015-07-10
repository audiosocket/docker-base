#!/bin/bash

docker build -t audiosocket/docker-base:`git log --pretty=format:'%h' -n 1` .
