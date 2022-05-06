#!/bin/sh -e

echo "CI_PROJECT_NAME is set to $CI_PROJECT_NAME"
echo "TYPE is set to $TYPE"
echo "OVERRIDE_BRANCH is set to $OVERRIDE_BRANCH"
echo "OVERRIDE_MATURITY is set to $OVERRIDE_MATURITY"
echo "OVERRIDE_SHORT_SHA is set to $OVERRIDE_SHORT_SHA"
rm -rf callers
BRANCH=$CI_COMMIT_BRANCH
  
if [ "$OVERRIDE_MATURITY" != "" ]; then
    MATURITY=$OVERRIDE_MATURITY
fi

if [ "$OVERRIDE_BRANCH" != "" ]; then
    BRANCH=$MATURITY/$OVERRIDE_BRANCH
fi

SHORT_SHA=$CI_COMMIT_SHORT_SHA

if [ "$OVERRIDE_SHORT_SHA" != "" ]; then
    SHORT_SHA=$OVERRIDE_SHORT_SHA
fi

#if [[ "$TYPE" == "common" && "$CI_PROJECT_NAME" == "gemini-ade" \
#  || "$TYPE" == "epics-base" && "$CI_PROJECT_NAME" == "epics-base" \
#  || "$TYPE" == "app" ]]; then
    # login
    docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    # build container image with tag $CI_COMMIT_SHORT_SHA
    docker build -t $(echo $CI_REGISTRY_IMAGE/$BRANCH:$SHORT_SHA | tr '[:upper:]' '[:lower:]') --no-cache -f Containerfile .
    docker push $(echo $CI_REGISTRY_IMAGE/$BRANCH:$SHORT_SHA | tr '[:upper:]' '[:lower:]')
    # and for the tag 'latest'
    docker build -t $(echo $CI_REGISTRY_IMAGE/$BRANCH:latest | tr '[:upper:]' '[:lower:]') -f Containerfile .
    docker push $(echo $CI_REGISTRY_IMAGE/$BRANCH:latest | tr '[:upper:]' '[:lower:]')
    # and also for the tag 'latest' without branch specification (which is convenient for stable)
    docker build -t $(echo $CI_REGISTRY_IMAGE/$MATURITY:latest | tr '[:upper:]' '[:lower:]') -f Containerfile .
    docker push $(echo $CI_REGISTRY_IMAGE/$MATURITY:latest | tr '[:upper:]' '[:lower:]')
#fi
# create artifacts to let caller job know that the triggered pipeline finished
mkdir -p callers/$CALLER_ID
touch callers/$CALLER_ID/dummy.txt

