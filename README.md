# Live Rebuild

This example template will live-rebuild apps in a docker container via [fswatch](https://github.com/emcrisostomo/fswatch). A very simple golang (gin) webserver is used as the example which is in the src/ directory. This could easily be modified to work with other languages as well.

Got the idea from [here](https://medium.com/@olebedev/live-code-reloading-for-golang-web-projects-in-19-lines-8b2e8777b1ea). Just made a few tweaks & applied it to docker.

## Example

Starting the container in dev mode:
```
$ docker-compose up --build --force-recreate
[...]
web_1  | Running in development
web_1  | Starting app...
web_1  | Watching for changes...
[...]
web_1  |  - using env:	export GIN_MODE=release
web_1  | [GIN-debug] GET    /oldpath
web_1  | [GIN-debug] Listening and serving HTTP on :8080
```

After adding a new route (`/newpath`) to gin in main.go:
```
web_1  | Rebuilding app...
web_1  | Built new app...
web_1  | Killing old app...
web_1  | Killed old app...
web_1  | Starting new app...
[...]
web_1  |  - using env:	export GIN_MODE=release
web_1  | [GIN-debug] GET    /oldpath
web_1  | [GIN-debug] GET    /newpath
web_1  | [GIN-debug] Listening and serving HTTP on :8080
```

## How to use

1. Copy all of the files in the root of this repo (or their content) into your project.
1. Put your code in the `src/` directory.
2. Modify the `.env` file; especially to set the `REPO_PATH` variable.
3. Configure Dockerfile, docker-compose.yml, and docker-compose.override.yml to your liking.

## How it works

- docker-compose.yml = standard configuration including production.
- docker-compose.override.yml = dev specific configuration.
- Golang code should be stored in the **`src/`** directory.
- The **`REPO_PATH`** variable in the **`.env`** file specifies the path of the repo to ensure the app is built correctly.
- The `go get` command will be ran on each rebuild to download new dependencies if the `src/vendor/` directory doesn't exist.

### Dev

```
$ docker-compose up --build --force-recreate
```

1. Docker-compose builds the image using the official golang docker image (debian) and installs fswatch.
2. docker-compose.override.yml maps the `Makefile` and `src/` to the container.
3. `cmd.sh` is ran which runs `make serve` to enable live-rebuilding.
4. `make serve` uses fswatch to look for changes in the `src/` directory.
5. Any changes will cause the app to rebuild, kill the current app running, then start the new binary.

### Prod

```
$ docker-compose -f docker-compose.yml up --build --force-recreate

# OR

$ docker stack deploy -c docker-compose.yml --with-registry-auth stackname
```

1. Docker builds the image using the official golang docker image (debian) without fswatch since rebuilding isn't necessary.
2. The app is built in the image.
3. Everything in `src/` is deleted after the app is built.
4. Neither the `Makefile` nor `src/` are mapped in production.
5. `cmd.sh` is ran which just runs the app directly (no live-rebuilding).
