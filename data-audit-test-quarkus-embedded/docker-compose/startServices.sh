#!/bin/sh

PROFILE="full"

echo "Script requires your Kogito Example to be compiled"

PROJECT_VERSION=$(cd ../ && mvn help:evaluate -Dexpression=project.version -q -DforceStdout)

echo "Project version: ${PROJECT_VERSION}"

if [[ $PROJECT_VERSION == *SNAPSHOT ]];
then
  KOGITO_VERSION="latest"
else
  KOGITO_VERSION=${PROJECT_VERSION%.*}
fi

echo "Kogito Image version: ${KOGITO_VERSION}"
echo "KOGITO_VERSION=${KOGITO_VERSION}" > ".env"
echo "COMPOSE_PROFILES='${PROFILE}'" >> ".env"

if [ "$(uname)" == "Darwin" ]; then
   echo "DOCKER_GATEWAY_HOST=kubernetes.docker.internal" >> ".env"
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
   echo "DOCKER_GATEWAY_HOST=172.17.0.1" >> ".env"
fi

if [ ! -d "./persistence" ]
then
  echo "$KOGITO_EXAMPLE_PERSISTENCE does not exist. Have you compiled the project? mvn clean install -DskipTests"
  exit 1
fi
PERSISTENCE_FOLDER=./persistence

if [ ! -d "./svg" ]
then
    echo "$KOGITO_EXAMPLE_SVG_FOLDER does not exist. Have you compiled the project? mvn clean install -DskipTests"
    exit 1
fi

docker compose -f docker-compose.yml up