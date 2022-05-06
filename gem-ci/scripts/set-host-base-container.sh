#!/bin/bash -e
#aliases for switch on/off command printout to console
shopt -s expand_aliases
alias trace_on='set -x'
alias trace_off='{ set +x; } 2>/dev/null'

trace_on


#CI_COMMIT_BRANCH=`git rev-parse --abbrev-ref HEAD`
#TYPE=epics-base

echo current container: $BASE_CONTAINER
echo current branch: $CI_COMMIT_BRANCH
echo current type: $TYPE

## extract BASE_CONTAINER's branch and type
# strip off registry name and namespace up to rtsw
TMP=${BASE_CONTAINER##registry.gitlab.com/nsf-noirlab/gemini/rtsw/}
# for the type, strip off all after the first '/'
BASE_CONTAINER_TYPE=${TMP%%/*}
# strip off BASE_CONTAINER_TYPE from TMP
TMP=${TMP##$BASE_CONTAINER_TYPE/}
# for the name, strip off all after the first '/'
BASE_CONTAINER_PROJECTNAME=${TMP%%/*}
# strip off BASE_CONTAINER_PROJECTNAME from TMP
TMP=${TMP##$BASE_CONTAINER_PROJECTNAME/}
# finally strip off the SHORT_SHA from the end, i.e. everything after ':'
BASE_CONTAINER_BRANCH=${TMP%%:*}
BASE_CONTAINER_PROJECT_HTML="nsf-noirlab%2Fgemini%2Frtsw%2F$BASE_CONTAINER_TYPE%2F$BASE_CONTAINER_PROJECTNAME"

# the NEW_BASE_CONTAINER's maturity is extracted from branch name
# by deleting longest match of '/*' from end of string
MATURITY=${CI_COMMIT_BRANCH%%/*}
# the NEW_BASE_CONTAINER's 'branch' is extracted from branch name
# by deleting longest match of '*/' from beginning of string
TARGET_BRANCH=${CI_COMMIT_BRANCH##*/}
TARGET_PROJECT=""

# map maturity to correct internal ones
if [[ "$MATURITY" != "testing" && "$MATURITY" != "stable" ]]; then
    MATURITY="unstable"
fi

# if '/special/' is part of the branch name and type is app, extract
# target project name from branch name. 
if [[ "$TYPE" == "app" && \
     `expr match "$CI_COMMIT_BRANCH" '.*\(/special/\).*'` == "/special/" ]]; then
    TMP=${CI_COMMIT_BRANCH##*special/}
    TARGET_PROJECT=${TMP%%/*}
    # use 'iocs' instead of 'app' as the correct path following
    # the subgroup structure on gitlab.com
    TYPE="iocs"
# else it's straight forward
elif [ "$TYPE" == "epics-base" ]; then
    TARGET_PROJECT="epics-base"
elif [ "$TYPE" == "common" ]; then
    TARGET_PROJECT="gemini-ade"
fi  

echo CONTAINER_PROJECT="nsf-noirlab/gemini/rtsw/$TYPE/$TARGET_PROJECT" 
echo CONTAINER_PROJECT_HTML="nsf-noirlab%2Fgemini%2Frtsw%2F$TYPE%2F$TARGET_PROJECT" 
echo CONTAINER_PROJECT_BRANCH="$CI_COMMIT_BRANCH" 
echo MATURITY="$MATURITY"
echo TYPE="$TYPE" 
echo TARGET_BRANCH="$TARGET_BRANCH" 

BASE_CONTAINER="registry.gitlab.com/nsf-noirlab/gemini/rtsw/$TYPE/$TARGET_PROJECT/$MATURITY/$TARGET_BRANCH:latest"
# make it lowercase
export BASE_CONTAINER=$(echo $BASE_CONTAINER | tr '[:upper:]' '[:lower:]')

echo BASE_CONTAINER=$BASE_CONTAINER
