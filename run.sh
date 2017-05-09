#!/bin/bash

# first remove all the docker container and docker images related to the project

echo
echo "Removing all previous instance"
echo

DOCKER_CONTAINER=$(docker ps -a -q)

if [ "$DOCKER_CONTAINER" != "" ]
then
	echo "Cleaning all docker container"
	docker rm $DOCKER_CONTAINER
fi

OPEN_OCR_1=$(docker images | grep "open-ocr-1")
if [ "$OPEN_OCR_1" != "" ]
then
	echo "Cleaning open-ocr-1 image"
	docker rmi "open-ocr-1"
fi

OPEN_OCR_2=$(docker images | grep "open-ocr-2")
if [ "$OPEN_OCR_2" != "" ]
then
	echo "Cleaning open-ocr-2 image"
	docker rmi "open-ocr-2"
fi

UBUNTU=$(docker images | grep "ubuntu")
if [ "$UBUNTU" != "" ]
then
	echo "Cleaning ubuntu image"
	docker rmi "ubuntu"
fi

OPEN_OCR_PREPROCESSOR=$(docker images | grep "open-ocr-preprocessor")
if [ "$OPEN_OCR_PREPROCESSOR" != "" ]
then
	echo "Cleaning open-ocr-preprocessor image"
	docker rmi "open-ocr-preprocessor"
fi

echo
echo "Which version of the OCR do you want to deploy: "
echo "[1] V1 (using tesseract 3.X): low memory consumption, faster but result less precise"
echo "[2] V2 (using tesseract 4.X): High accuracy but slower and moderate to high memory consumption"
echo

read -p "Choose 1 or 2: " OPEN_OCR_VERSION

OPEN_OCR_INSTANCE_NAME=""

if [ "$OPEN_OCR_VERSION" == "1" ]
then
	echo "Open ocr instance name will be open-ocr-1"
	OPEN_OCR_INSTANCE_NAME="open-ocr-1"
elif [ "$OPEN_OCR_VERSION" == "2" ]
then
	echo "Open ocr instance name will be open-ocr-2"
	OPEN_OCR_INSTANCE_NAME="open-ocr-2"
else
	echo "ERROR: No correct version specified (please choose between 1 and 2)"
	exit
fi

# 1/ build docker image for open-ocr
cd docker/$OPEN_OCR_INSTANCE_NAME
docker build -t $OPEN_OCR_INSTANCE_NAME .

#check that docker instance answer to a simple command
RESULT_OK=$(docker run $OPEN_OCR_INSTANCE_NAME echo "Status ok" | grep "Status ok")

if [ "$RESULT_OK" == "Status ok" ]
then
	echo "Instance $OPEN_OCR_INSTANCE_NAME is up and running"
else
	echo "ERROR: Build instance $OPEN_OCR_INSTANCE_NAME failed"
	exit
fi

# 2/ build docker image for open-ocr-preprocessor
cd ../open-ocr-preprocessor
docker build -t open-ocr-preprocessor .

#check that docker instance answer to a simple command
RESULT_OK=$(docker run open-ocr-preprocessor echo "Status ok" | grep "Status ok")

if [ "$RESULT_OK" == "Status ok" ]
then
	echo "Instance open-ocr-preprocessor is up and running"
	exit
else
	echo "ERROR: Build instance open-ocr-preprocessor failed"
	exit
fi

# 3/ run docker compose
export OPEN_OCR_INSTANCE=$OPEN_OCR_INSTANCE_NAME

docker-compose up
