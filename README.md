# All In One Build/Dev/Prod Environment in Docker
This is an experiment whether it is possible to have a `Dockerfile` (or a set of files) that could allow one (or a team), having only Docker and an SCM client of one’s choice, to be able to spin up:
* Runtime environment.
	* These are all the libraries and tools the Dockerized service requires in order to run (these are not your compile-time (`make`) or development (`vim`) dependencies).
	* These are also any and all executables (binaries and/or scripts), configs, secrets, volumes, etc that the service requires in order to run.
		* _NOTE_: The configs, secrets, volumes integrated inside the image ought to be thought of as default/snakeoil, and when running containers from the image, one should be expected to provide them externally.
* Build environment.
	* These are all the libraries and tools the Dockerized build system requires in order to build the service.
* IDE.
	* These are all the libraries and tools the Dockerized build system requires in order to develop, build and run the service.
	* In ideal case, this should contain a real IDE (I am sorry, I don’t really consider `vim` to be an IDE), however, I haven’t found one that can be installed and configured unattended.
		* Until any IDEs support this, one will have to manually install it inside a container, configure it, and save it as an archive. This will work, and the IDE will be reusable. But every update and change will require one to recreate the archive, sadly.

Feel free to send me PR’s, I’d be happy to include new ideas, but keep it simple. Let’s not overdosing this :).

I would love for people to be able to take what has been done here, make it their own, and improve on it.

## Requirements
* Docker Client and Docker Engine (that supports BuildKit).
* SCM of your choice (if you wish to clone this repository, then that’s Git).

## Building and Running The IDE (`vim`)
```bash
git submodule init
git submodule fetch

DOCKER_BUILDKIT=1 docker build -t all-in-one:dev-latest -t dev .

docker run -it --rm -v "$(pwd)":/work all-in-one
```
_NOTE_: Will wipe everything that you do inside the container with any file outside of `/work`, which will be mapped to the repository on your machine.
_NOTE_: I work on macOS with iTerm2, so the default run configuration will attempt to launch a headless `tmux` session. If you don’t want that, do (replace `bash` with any other command you’d like to run, e.g. `tmux`)
```bash
docker run -it --rm -v "$(pwd)":/work --entrypoint /usr/bin/env all-in-one bash
```

## Building, Running and Verifiyng the Service
```bash
DOCKER_BUILDKIT=1 docker build -t all-in-one:latest .

docker run -p 65443:443 all-in-one

# Install, `curl` if you don't have it already.
curl --insecure https://127.0.0.1:65443
```

## Running the Service Using Custom Configs and Secrets
_NOTE_: Needs `openssl` on top of the requirements mentioned before.
_NOTE_: If you need this to be part of a Docker Stack, this should be easy to adapt into a docker-compose YAML file.
```bash
docker config create all-in-one_nginx.conf src/nginx.conf

openssl req \
	-new \
	-newkey rsa:4096 \
	-days 365 \
	-nodes \
	-x509 \
	-subj "/CN=127.0.0.1" \
	-keyout >( docker secret create all-in-one_server.key.pem - ) \
	-out >( docker secret create all-in-one_server.crt.pem - )

docker service create \
	--name all-in-one \
	--config src=all-in-one_nginx.conf,target=/run/config/nginx.conf \
	--secret src=all-in-one_server.key.pem,target=/run/secret/server.key.pem \
	--secret src=all-in-one_server.crt.pem,target=/run/secret/server.crt.pem \
	--publish 65443:443 \
	all-in-one
```