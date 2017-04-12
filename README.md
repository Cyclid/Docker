# Docker for Cyclid

We like Docker. This repository contains a few extra files that can help you get Cyclid up and running on Docker. You can use them to build a quick and easy set of containers that will run Cyclid, or you can use them as the basis of your own production installation of Cyclid on Docker.

## Quickstart

To start the containers:

  * [Install Docker](https://www.docker.com/community-edition)
  * Run `docker-compose up`
  * Point your web-browser at http://localhost:8080
  * Log in with the username `admin` and the password `cyclid`

To run a job:

  * Install the [Cyclid client](https://rubygems.org/gems/cyclid-client)
  * Copy the file `docker` to `$HOME/.cyclid/` and activate it with `cyclid org use docker`
  * Clone one of the example projects and run it with `cyclid job submit <file>`:
    * [example-ruby-project](https://github.com/Cyclid/example-ruby-project)
    * [example-python-project](https://github.com/Cyclid/example-python-project)
    * [example-chef-project](https://github.com/Cyclid/example-chef-project)

## Files

### docker-compose.yml

[docker-compose](https://docs.docker.com/compose/overview/) is the quickest way to start the Docker containers that make up Cyclid. The example docker-compose.yml file creates:

  * cyclid-server : A Cyclid API server.
  * cyclid-sidekiq : A Sidekiq based Cyclid job runner.
  * cyclid-ui : A Cyclid UI server.
  * cyclid-redis : A Redis server for the Sidekiq worker queues.
  * cyclid-db : A MySQL database server.
  
Just run `docker-compose up` to start them all.

### docker-bash.sh

If you don't want to use docker-compose, this shell script contains examples of using Docker to start each individual container.

### docker

A Cyclid client configuration file with the default username & HMAC secret already set. Just copy it to `$HOME/.cyclid` and activate it with the `cyclid org use` command.

## Cyclid containers

Three Dockerfiles define the container build process for each of the Cyclid components. You can build containers directly from them, or use `docker-compose build` to create them. They are also available ready-built from Docker hub.

### cyclid-server (Dockerfile.server)

The following build time arguments are supported:

| Name | Default | Description |
|---|---|---|
|admin_secret|fe150f3939ed0419f32f8079482380f5cc54885a381904c15d861e8dc5989286|The initial 'admin' users HMAC secret.|
|admin_password|cyclid|The initial 'admin' users password.|
|redis_url|redis://cyclid-redis:6379|URL of the Redis server.|

The following runtime environment variables are supported:

| Name | Default | Description |
|---|---|---|
|MYSQL_HOST|127.0.0.1|The host running MySQL.|
|MYSQL_DATABASE|cyclid|The name of the database to use.|
|MYSQL_USER|cyclid|Username to use for database connections.|
|MYSQL_PASSWORD|cyclid|Password to use for database connections.|
|ADMIN_SECRET|${admin_secret}|The initial 'admin' users HMAC secret.|
|ADMIN_PASSWORD|${admin_password}|The initial 'admin' users password.|
|REDIS_URL|${redis_url}|URL of the Redis server.|
|CYCLID_DB_INIT|   |Should the container attempt to run `cyclid-db-init` when it's started?|

These environment variables should probably match the ones you used for the cyclid-sidekiq instance.

### cyclid-sidekiq (Dockerfile.sidekiq)

The following build time arguments are supported:

| Name | Default | Description |
|---|---|---|
|redis_url|redis://cyclid-redis:6379|URL of the Redis server.|

The following runtime environment variables are supported:

| Name | Default | Description |
|---|---|---|
|MYSQL_HOST|127.0.0.1|The host running MySQL.|
|MYSQL_DATABASE|cyclid|The name of the database to use.|
|MYSQL_USER|cyclid|Username to use for database connections.|
|MYSQL_PASSWORD|cyclid|Password to use for database connections.|
|REDIS_URL|${redis_url}|URL of the Redis server.|

These environment variables should probably match the ones you used for the cyclid-server instance.

### cyclid-ui (Dockerfile.ui)

The following build time arguments are supported:

| Name | Default | Description |
|---|---|---|
|server_url|http://cyclid-server:8361|URL to the Cyclid server to connect to directly from the UI server.|
|client_url|http://localhost:8361|URL to the Cyclid server to connect to from the client.|
|session_secret|7b48be7df0efeb669cb899704b3153814980c9a846fd3b1398bcd6cb20e6e5ed|Unicorn session encryption secret.|

The following runtime environment variables are supported:

| Name | Default | Description |
|---|---|---|
|SERVER_URL|${server_url}|URL to the Cyclid server to connect to directly from the UI server.|
|CLIENT_URL|${client_url}|URL to the Cyclid server to connect to from the client.|
|SESSION_SECRET|${session_secret}|Unicorn session encryption secret.|

The server URL & client URL should both resolve to the same Cyclid server: the server URL should be accessable from within the cyclid-ui container, and the client URL should be accessable from any clients (E.g. a web browser) running *outside* of the container.
