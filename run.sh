#!/bin/bash

echo
echo "Which version of the OCR do you want to deploy: "
echo "[1] V1 (using tesseract 3.X): low memory consumption, faster but result less precise"
echo "[2] V2 (using tesseract 4.X): High accuracy but slower and moderate to high memory consumption"
echo

# first remove all the docker container and docker images related to the project
docker rm $(docker ps -a -q)
docker rmi open-ocr-1
docker rmi open-ocr-2
docker rmi ubuntu
docker rmi open-ocr-preprocessor

read -p "Choose 1 or 2: " OPEN_OCR_VERSION

OPEN_OCR_INSTANCE_NAME=""

if [ "$OPEN_OCR_VERSION" == "1" ]
then
	echo "Open ocr instance name will be open-ocr-1"
	OPEN_OCR_INSTANCE_NAME="open-ocr-1"
	
elif [ "$OPEN_OCR_VERSION" == "2" ]
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
