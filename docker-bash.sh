#!/bin/bash
#
# This is an example of how to create the various Docker containers that make
# up Cyclid, without using docker-compose. It does not expose every
# environment variable available; refer to the documentation for a full list
# of available environment variables.
#
# At a minimum the cyclid-server & cyclid-sidekiq are required, and you can
# choose to provide the MySQL & Redis servers however you wish. Cyclid UI is
# optional, but recommended.
#
# You can change the following if you wish, to suit your own environment.
# They are especially important in a production environment where you
# probably do not want to use the cyclid-db MySQL container, and you will
# need to provide useful database connection details.
_MYSQL_HOST=${MYSQL_HOST:-cyclid-db}
_MYSQL_DATABASE=${MYSQL_DATABASE:-cyclid}
_MYSQL_USER=${MYSQL_USER:-root}
_MYSQL_PASSWORD=${MYSQL_PASSWORD:-cyclid}

# cyclid-db
#
# Create a MySQL instance. You almost certainly do not want to do this in a
# production environment, where you'll want to use a proper database instance.
# However it's fine for testing.
docker run  --detach \
            -e MYSQL_ROOT_PASSWORD=${_MYSQL_PASSWORD} \
            -P \
            --name cyclid-db \
            mysql

# cyclid-redis
#
# You can choose to use an existing Redis instance instead if you like, but
# Redis is only used for Sidekiq worker queues here and is not quite as
# critical as the database.
docker run  --detach \
            -P \
            --name cyclid-redis \
            redis

# cyclid-server
#
# The Cyclid server. It needs to connect to both MySQL & Redis, and must have
# a matching Sidekiq instance if you want to actually run any jobs.
docker run  --detach \
            -e MYSQL_HOST=${_MYSQL_HOST} \
            -e MYSQL_USER=${_MYSQL_USER} \
            -e MYSQL_DATABASE=${_MYSQL_DATABASE} \
            -e MYSQL_PASSWORD=${_MYSQL_PASSWORD} \
            -e CYCLID_DB_INIT=true \
            -p 8361:8361/tcp \
            --name cyclid-server \
            --link cyclid-db:cyclid-db \
            --link cyclid-redis:cyclid-redis \
            cyclid/server

# cyclid-sidekiq
#
# The Cyclid Sidekiq job runner. It also needs to connect to both MySQL &
# Redis. By default it is configured to use Docker to create ephemeral build
# hosts, and the Docker daemon socket is mounted into the container. If you
# choose to use something other than Docker, you don't need to do this.
docker run  --detach \
            -e MYSQL_HOST=${_MYSQL_HOST} \
            -e MYSQL_USER=${_MYSQL_USER} \
            -e MYSQL_PASSWORD=${_MYSQL_PASSWORD} \
            -v /var/run/docker.sock:/var/run/docker.sock \
            --name cyclid-sidekiq \
            --link cyclid-db:cyclid-db \
            --link cyclid-redis:cyclid-redis \
            cyclid/sidekiq

# cyclid-ui
#
# The Cyclid UI server. It connects to the Cyclid server. Port 8080 is used
# to forward HTTP connections.
docker run  --detach \
            -p 8080:80/tcp \
            --name cyclid-ui \
            --link cyclid-server:cyclid-server \
            cyclid/ui
