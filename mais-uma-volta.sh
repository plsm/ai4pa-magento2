#!/usr/bin/env bash

docker container prune --force
docker volume rm docker-file-4_ai4pa-db docker-file-4_ai4pa-magento docker-file-4_ai4pa-www
docker-compose build
docker-compose run ai4pa bash
