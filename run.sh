#!/bin/sh

OPEN_OCR_VERSION=$1

if [ -z $OPEN_OCR_VERSION ]
then
	echo "Open ocr version is missing apply latest (2)"
	OPEN_OCR_VERSION="2"
fi

OPEN_OCR_INSTANCE_NAME=""

if [ $OPEN_OCR_VERSION == "1" ]
then
	echo "Open ocr instance name will be open-ocr-1"
	OPEN_OCR_INSTANCE_NAME="open-ocr-1"
	
elif [ $OPEN_OCR_VERSION == "2" ]
	echo "Open ocr instance name will be open-ocr-2"
	OPEN_OCR_INSTANCE_NAME="open-ocr-2"

else
	echo "ERROR: No correct version specified (please choose between 1 and 2)"
	exit
fi

STATUS_OK="Status ok"

# 1/ build docker image for open-ocr
cd docker/$OPEN_OCR_INSTANCE_NAME
docker build -t $OPEN_OCR_INSTANCE_NAME .

if docker run $OPEN_OCR_INSTANCE_NAME echo $STATUS_OK | grep -q $STATUS_OK; then
	echo "Instance $OPEN_OCR_INSTANCE_NAME is up and running"

else
	echo "ERROR: Build instance $OPEN_OCR_INSTANCE_NAME failed"
fi

# 2/ build docker image for open-ocr-preprocessor
cd ../open-ocr-preprocessor
docker build -t open-ocr-preprocessor .

if docker run open-ocr-preprocessor echo $STATUS_OK | grep -q $STATUS_OK; then
	echo "Instance open-ocr-preprocessor is up and running"
	exit
	
else
	echo "ERROR: Build instance open-ocr-preprocessor failed"
	exit
fi

# 3/ run docker compose

docker-compose up -e OPEN_OCR=$OPEN_OCR_INSTANCE_NAME
