#!/usr/bin/env bash

build_message(){
    # $1 = build message
    echo
    echo =========BUILD MESSAGE=========
    echo "$@"
    echo ===============================
    echo
}

login_docker(){
    docker login --username=$DOCKER_USER --password=$DOCKER_PASS
}

prepare_package(){
	DOCKER_ORG=treehouses
	DOCKER_REPO=rpi-couchdb
	VERSION=$(cat package.json | grep version | awk '{print$2}' | awk '{print substr($0, 2, length($0) - 3)}')
	if [ -z "$BRANCH" ]; then
		BRANCH=$TRAVIS_BRANCH
	fi
	if [ -z "$COMMIT" ]; then
		COMMIT=${TRAVIS_COMMIT::8}
	fi
	V200_DOCKER_NAME=$DOCKER_ORG/$DOCKER_REPO:2.0.0-$VERSION-$BRANCH-$COMMIT
	V200_DOCKER_NAME_LATEST=$DOCKER_ORG/$DOCKER_REPO:2.0.0
	V210_DOCKER_NAME=$DOCKER_ORG/$DOCKER_REPO:2.1.0-$VERSION-$BRANCH-$COMMIT
	V210_DOCKER_NAME_LATEST=$DOCKER_ORG/$DOCKER_REPO:2.1.0
}

remove_temporary_folders(){
	rm -rf "$TEST_DIRECTORY"
}

create_footprint_rpi_couchdb() {
  echo $(date +%Y-%m-%d.%H-%M-%S) from rpi-couhdb >> $FOOTPRINT
}

package_v200(){
	build_message processing $V200_DOCKER_NAME
	docker build 2.0.0/ -t $V200_DOCKER_NAME
	build_message done processing $V200_DOCKER_NAME
	if [ "$BRANCH" = "master" ]
	then
		build_message processing $V200_DOCKER_NAME_LATEST
		docker tag $V200_DOCKER_NAME $V200_DOCKER_NAME_LATEST
		build_message done processing $V200_DOCKER_NAME_LATEST
	fi
}

package_v210(){
	build_message processing $V210_DOCKER_NAME
	docker build 2.1.0/ -t $V210_DOCKER_NAME
	build_message done processing $V210_DOCKER_NAME
	if [ "$BRANCH" = "master" ]
	then
		build_message processing $V210_DOCKER_NAME_LATEST
		docker tag $V210_DOCKER_NAME $V210_DOCKER_NAME_LATEST
		build_message done processing $V210_DOCKER_NAME_LATEST
	fi
}

push_v200(){
	build_message pushing $V200_DOCKER_NAME
	docker push $V200_DOCKER_NAME
	build_message done pushing $V200_DOCKER_NAME
	if [ "$BRANCH" = "master" ]
	then
		build_message pushing $V200_DOCKER_NAME_LATEST
		docker push $V200_DOCKER_NAME_LATEST
		build_message done pushing $V200_DOCKER_NAME_LATEST
	fi
}

push_v210(){
	build_message pushing $V210_DOCKER_NAME
	docker push $V210_DOCKER_NAME
	build_message done pushing $V210_DOCKER_NAME
	if [ "$BRANCH" = "master" ]
	then
		build_message pushing $V210_DOCKER_NAME_LATEST
		docker push $V210_DOCKER_NAME_LATEST
		build_message done pushing $V210_DOCKER_NAME_LATEST
	fi
}

deploy_v200(){
	login_docker
	package_v200
	push_v200
}

deploy_v210(){
	login_docker
	package_v210
	push_v210
}
