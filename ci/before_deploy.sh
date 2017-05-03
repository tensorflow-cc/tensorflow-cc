#!/bin/sh

RELEASE_NAME=$(basename $TRAVIS_BUILD_DIR)-$TRAVIS_TAG-$TARGET

rm -rf $RELEASE_NAME
mkdir -p $RELEASE_NAME

cp -R ~/root/* $RELEASE_NAME/

tar zcf \
	$RELEASE_NAME.tar.gz \
	$RELEASE_NAME
