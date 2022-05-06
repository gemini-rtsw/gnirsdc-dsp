#!/bin/bash -e
#aliases for switch on/off command printout to console
shopt -s expand_aliases
alias trace_on='set -x'
alias trace_off='{ set +x; } 2>/dev/null'

# default for 'app'
PROJECT_NAME=$CI_PROJECT_NAME

trace_on

# if 'common' or 'epics-base'
if [ "$TYPE" != "app" ]; then
    echo setting PROJECT_NAME to $TYPE &&
    PROJECT_NAME=$TYPE
fi

#strip off MATURITY from CI_COMMIT_BRANCH
BRANCH=${CI_COMMIT_BRANCH#*/}

echo current container: $BASE_CONTAINER

ssh -o StrictHostKeyChecking=no koji@hbfswgrepo-lv1.hi.gemini.edu "echo importing public key of hbfswgrepo-lv1"
unlink .tito/releasers.conf 

# create releasers.conf from template
sed -e "s#<PROJECTNAME>#$PROJECT_NAME#g" \
  -e "s#<BRANCH>#$BRANCH#g" \
  -e "s#<MATURITY>#$MATURITY#g" \
  gem-ci/templates/tito/$TYPE/releasers.conf > .tito/releasers.conf


RSYNC_USERNAME=koji tito release gem-rtsw-$TYPE

#cp -f /gem_base/usr/share/tito/$TYPE/releasers.conf .tito/releasers.conf && RSYNC_USERNAME=koji tito release gem-rtsw-$TYPE

trace_off
