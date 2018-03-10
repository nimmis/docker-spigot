#!/bin/bash
# Basic healthcheck for docker, remove # from echo if you want some sort of output.
# During build, it will show as unhealthy in docker ps

if /usr/bin/supervisorctl status spigot | grep -q 'RUNNING'; then
 # echo "matched"
  exit 0
else
 # echo "failed"
  exit 1
fi
