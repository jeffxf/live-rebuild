FROM golang:1.10 AS build

# Repo path
ARG REPO_PATH
# App name
ARG APP_NAME
ENV APP_NAME=${APP_NAME}
# Dev vs prod
ARG BUILD_ENV
ENV BUILD_ENV=${BUILD_ENV}

# If in dev environment, get fswatch to watch for file changes when developing
WORKDIR /opt/
RUN if [ "${BUILD_ENV}" = "dev" ]; then \
        echo "Building for development" ;\
        apt-get update ;\
        apt-get install -y --no-install-recommends inotify-tools ;\
        # Install fswatch (still in debian/sid)
        wget https://github.com/emcrisostomo/fswatch/releases/download/1.12.0/fswatch-1.12.0.tar.gz ;\
        tar -zxvf fswatch-*.tar.gz && cd fswatch-*/ && ./configure && make && make install && ldconfig && cd / && rm -rf /opt/fswatch-* ;\
        ### Do other development build stuff here... ###
    elif [ "${BUILD_ENV}" = "prod" ]; then \
        echo "Building for production" ;\
        ### Do production build stuff here... ###
    fi

# Clean up apt
RUN apt-get clean ;\
    apt-get autoclean -y ;\
    apt-get autoremove -y

# Copy the source in
WORKDIR /go/src/${REPO_PATH}
RUN mkdir src
COPY ./src ./src
# Get dependencies if vendoring isn't used
RUN if [ ! -d "src/vendor/" ]; then \
        go get -v ./... ;\
    fi
# Build the app, store it where it belongs, then remove source code
RUN go build -i -o ${GOPATH}/bin/${APP_NAME} -v src/main.go
RUN rm -rf src/*

# Short script for starting the app in different environments
COPY cmd.sh .
RUN chmod u+x cmd.sh
# Change CMD to ENTRYPOINT if you want to allow command line arguments
#   you'll need to update cmd.sh and possibly the Makefile to parse the arguments though...
CMD ["./cmd.sh"]
# Only necessary to expose 8080 in our example since it's a gin web app
EXPOSE 8080