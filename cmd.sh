#!/bin/sh

if [ -z "${BUILD_ENV}" ]; then
    echo "BUILD_ENV environment variable doesn't exist."
    exit 1
elif [ "${BUILD_ENV}" = "dev" ]; then 
    echo "Running in development"
    ### Do other development stuff here... ###
    make serve # Run app via Makefile reloader
elif [ "${BUILD_ENV}" = "prod" ]; then 
    echo "Running in production"
    ### Do production stuff here... ###
    ${APP_NAME} # Run app without reloading
else
    echo "Invalid BUILD_ENV environment variable: ${BUILD_ENV}"
    exit 1
fi