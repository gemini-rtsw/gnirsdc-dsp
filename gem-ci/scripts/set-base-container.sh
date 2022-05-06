#!/bin/bash -e
#aliases for switch on/off command printout to console
shopt -s expand_aliases
alias trace_on='set -x'
alias trace_off='{ set +x; } 2>/dev/null'

trace_on

echo current container: $BASE_CONTAINER
echo current branch: $CI_COMMIT_BRANCH

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

echo CONTAINER_PROJECT="nsf-noirlab/gemini/rtsw/$TYPE/$TARGET_PROJECT" >> prepare.env
echo CONTAINER_PROJECT_HTML="nsf-noirlab%2Fgemini%2Frtsw%2F$TYPE%2F$TARGET_PROJECT" >> prepare.env
echo CONTAINER_PROJECT_BRANCH="$CI_COMMIT_BRANCH" >> prepare.env
echo MATURITY="$MATURITY" >> prepare.env
echo TYPE="$TYPE" >> prepare.env
echo TARGET_BRANCH="$TARGET_BRANCH" >> prepare.env

NEW_BASE_CONTAINER="registry.gitlab.com/nsf-noirlab/gemini/rtsw/$TYPE/$TARGET_PROJECT/$MATURITY/$TARGET_BRANCH:latest"
# make it lowercase
NEW_BASE_CONTAINER=$(echo $NEW_BASE_CONTAINER | tr '[:upper:]' '[:lower:]')

echo NEW_BASE_CONTAINER=$NEW_BASE_CONTAINER >> prepare.env

# login
docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
# check if container image exists on registry
# if not, trigger a multi-project pipeline to create it
# and wait for dummy artifacts to be generated so the
# local pipeline can continue.
result=$(docker manifest inspect $NEW_BASE_CONTAINER) || echo manifest not found, hence container not existing. Using container specified by BASE_CONTAINER 
if [ "$result" == "" ]; then
    # make use of setting in .gitlab-ci.yml (or API ot git push option or...)
    # echo NEW_BASE_CONTAINER=$BASE_CONTAINER >> prepare.env
    curl --request POST --form token=$CI_JOB_TOKEN \
            --form ref=$BASE_CONTAINER_BRANCH \
            --form "variables[TYPE]=$TYPE" \
            --form "variables[OVERRIDE_MATURITY]=$MATURITY" \
            --form "variables[OVERRIDE_BRANCH]=$TARGET_BRANCH" \
            --form "variables[OVERRIDE_SHORT_SHA]=$CI_COMMIT_SHORT_SHA" \
            --form "variables[BASE_CONTAINER]=$BASE_CONTAINER" \
            --form "variables[CALLER_ID]=$CI_PIPELINE_ID/$CI_JOB_ID" \
            "https://gitlab.com/api/v4/projects/$BASE_CONTAINER_PROJECT_HTML/trigger/pipeline"

    echo "Waiting on $BASE_CONTAINER_PROJECT_HTML artifacts..."
    ARTIFACT_URL="https://gitlab.com/api/v4/projects/$BASE_CONTAINER_PROJECT_HTML/jobs/artifacts/$BASE_CONTAINER_BRANCH/download?job=${BASE_CONTAINER_TYPE}_deploy-container"
    trace_off
    sleep 15
    while :; do
        echo -n "."
        curl --silent --location -o artifacts.zip  --header "JOB-TOKEN: $CI_JOB_TOKEN" $ARTIFACT_URL
        unzip -l artifacts.zip | grep -q "$CI_PIPELINE_ID/$CI_JOB_ID/dummy.txt" && break
        sleep 15
    done; echo
fi
