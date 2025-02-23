#! /bin/bash 
###########################################
#
###########################################

# constants
baseDir=$(cd `dirname "$0"`;pwd)
appHome=$baseDir/..
registryPrefix=
imagename=cskefu/api

# functions

# main 
[ -z "${BASH_SOURCE[0]}" -o "${BASH_SOURCE[0]}" = "$0" ] || return
# build
cd $appHome
if [ -d ../private ]; then
    registryPrefix=dockerhub.qingcloud.com/
fi

TIMESTAMP=`date "+%Y%m%d.%H%M%S"`
PACKAGE_VERSION=`git rev-parse --short HEAD`
APPLICATION_CUSTOMER_ENTITY=${APPLICATION_CUSTOMER_ENTITY:-"OpenSource Community"}

$baseDir/../../bin/deploy.sh

if [ ! $? -eq 0 ]; then
    echo "Error on deploy"
    exit 1
fi

# $baseDir/package.sh # package happens with deploy.sh
# if [ ! $? -eq 0 ]; then
#     echo "Error happens on package."
#     exit 1
# fi

set -x
docker build --build-arg VCS_REF=$PACKAGE_VERSION \
    --build-arg APPLICATION_BUILD_DATESTR=$TIMESTAMP \
    --build-arg APPLICATION_CUSTOMER_ENTITY="$APPLICATION_CUSTOMER_ENTITY" \
    --no-cache \
    --force-rm=true --tag $registryPrefix$imagename:$PACKAGE_VERSION .

if [ $? -eq 0 ]; then
    docker tag $registryPrefix$imagename:$PACKAGE_VERSION $registryPrefix$imagename:v8
else 
    echo "Build contact-center failure."
    exit 1
fi