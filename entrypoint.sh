#!/bin/sh -l
set -e

if [ $# -lt 7 ]
then
  echo "Some parameters are missing"
  exit 1
fi
VENDOR=$1
APP_ID=$2
export KBC_DEVELOPERPORTAL_USERNAME=$3
export KBC_DEVELOPERPORTAL_PASSWORD=$4
TAG=$5
TARGET_IMAGE=$6
TAG_AS_LATEST=$7

# Login to the repository
docker pull quay.io/keboola/developer-portal-cli-v2:latest
export REPOSITORY=`docker run --rm -e KBC_DEVELOPERPORTAL_USERNAME -e KBC_DEVELOPERPORTAL_PASSWORD quay.io/keboola/developer-portal-cli-v2:latest ecr:get-repository ${VENDOR} ${APP_ID}`
eval $(docker run --rm \
  -e KBC_DEVELOPERPORTAL_USERNAME \
  -e KBC_DEVELOPERPORTAL_PASSWORD \
  quay.io/keboola/developer-portal-cli-v2:latest ecr:get-login ${VENDOR} ${APP_ID})

# Pull
IMAGE="${REPOSITORY}:${TAG}"
echo "Pulling image '$IMAGE'. Using service account '${KBC_DEVELOPERPORTAL_USERNAME}'."
docker pull $IMAGE
docker tag $IMAGE "${TARGET_IMAGE}:${TAG}"

# Add latest tag?
if [ "TAG_AS_LATEST" = "true" ]
then
	docker tag $IMAGE "${TARGET_IMAGE}:latest"
fi

docker images
