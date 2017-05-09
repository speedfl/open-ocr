#!/bin/bash

#===================================================================
# clean docker containers
#===================================================================
cleanContainer()
{
	echo
	echo "Removing all previous instance"
	echo

	DOCKER_CONTAINER=$(docker ps -a -q)

	if [ "$DOCKER_CONTAINER" != "" ]
	then
		echo "Cleaning all docker container"
		docker rm $DOCKER_CONTAINER
	fi
}

#===================================================================
# clean docker images
#===================================================================
cleanImage()
{
	IMAGE_TO_CLEAN=$(docker images | grep "$1")
	if [ "$IMAGE_TO_CLEAN" != "" ]
	then
		echo "Cleaning $IMAGE_TO_CLEAN image"
		docker rmi $IMAGE_TO_CLEAN
	else
        echo "$1 already cleaned"
	fi

}

#===================================================================
# run an instance and check the status
#===================================================================
runInstance()
{
	INSTANCE_NAME=$1
	echo "About to build $INSTANCE_NAME"
	
	cd docker/$INSTANCE_NAME
	docker build -t $INSTANCE_NAME .
	
	#check that docker instance answer to a simple command
	RESULT_OK=$(docker run $INSTANCE_NAME echo "Status ok" | grep "Status ok")
	
	if [ "$RESULT_OK" == "Status ok" ]
	then
		echo "Instance $INSTANCE_NAME is up and running"
		exit
	else
		echo "ERROR: Build instance $INSTANCE_NAME failed"
		exit
	fi
	
	# go back to initial directory
	cd ..
}

# first remove all the docker container and docker images related to the project

cleanContainer
cleanImage "open-ocr-1"
cleanImage "open-ocr-2"
cleanImage "ubuntu"
cleanImage "open-ocr-preprocessor"

echo
echo "Which version of the OCR do you want to deploy: "
echo "[1] V1 (using tesseract 3.X): low memory consumption, faster but result less precise"
echo "[2] V2 (using tesseract 4.X): High accuracy but slower and moderate to high memory consumption"
echo

read -p "Choose 1 or 2: " OPEN_OCR_VERSION

OPEN_OCR_INSTANCE_NAME=""

if [ "$OPEN_OCR_VERSION" == 1 ]
then
	echo "Open ocr instance name will be open-ocr-1"
	OPEN_OCR_INSTANCE_NAME="open-ocr-1"
elif [ "$OPEN_OCR_VERSION" == 2 ]
then
	echo "Open ocr instance name will be open-ocr-2"
	OPEN_OCR_INSTANCE_NAME="open-ocr-2"
else
	echo "ERROR: No correct version specified (please choose between 1 and 2)"
	exit
fi

# 1/ build docker image for open-ocr
runInstance $OPEN_OCR_INSTANCE_NAME

# 2/ build docker image for open-ocr-preprocessor
runInstance "open-ocr-preprocessor"

# 3/ run docker compose
export OPEN_OCR_INSTANCE=$OPEN_OCR_INSTANCE_NAME
cd docker-compose
docker-compose up
