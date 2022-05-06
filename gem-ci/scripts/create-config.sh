#!/bin/bash -e

dnf -y update

# checks if $candidate is contained (in the sense of 'part of')
# $file. $file is split by csplit using the regex_csplit as
# delimiter expression.
# Returns true/0 or false/1
is_contained=false  #return value

function isContained () {
    local candidate="$1"
    local file="$2"
    local regex_csplit="$3"

    is_contained=false
   
    if [ -f $1 -a -f $2 ]; then
        # csplit file
        csplit --elide-empty-files --quiet --prefix="xxxx" $file $regex_csplit {*}
        for i in xxxx*
        do
            # explicitly set exit_code to zero, inmight be one from former loop cycle
            exit_code=0
            # check if content is already in $candidate
            diff --ignore-blank-lines --brief $i $candidate || exit_code=$?
            if [ $exit_code -eq 0 ]; then
                is_contained=true
            fi
        done
        rm xxxx*
    fi 
}

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

# Make container_project_branch.cfg available for artifacts.
# This file contains the branch the original BASE_CONTAINER is build from.
# See https://gitlab.com/nsf-noirlab/gemini/rtsw/support/pmaclib/-/issues/12
# If it already exists and has a size >0, we do already have a container whos namespace is
# not correponding with a branch name. Then copy the existing config file
# to be kept as artifact for the next jobs.
touch container_project_branch.cfg
if [ -s /gem_base/etc/container_project_branch.cfg ]; then
    cp /gem_base/etc/container_project_branch.cfg container_project_branch.cfg
fi

# store the original project's branch in file to be made permanent in container
# if the configuration file has size 0 (meaning it has been 'touched' above).
# This will only be the case for the beginning of a container 'chain' within a layer
if [ ! -s container_project_branch.cfg ]; then
    echo $CI_COMMIT_BRANCH > container_project_branch.cfg
fi

# strip off MATURITY from CI_COMMIT_BRANCH
BRANCH=${CI_COMMIT_BRANCH#*/}

# OVERRIDE_BRANCH is set if an extra repository
# needs to be created
if [ "$OVERRIDE_BRANCH" != "" ]; then
    BRANCH=$OVERRIDE_BRANCH
fi

if [ "$OVERRIDE_MATURITY" != "" ]; then
    MATURITY=$OVERRIDE_MATURITY
fi

echo "BRANCH is set to $BRANCH"

# create mock configuration file from template
# and from mock configuration already existing 
# (inherited from BASE_CONTAINER)
MOCK_CONFIG="/etc/mock/gem-rtsw.cfg"
if [ -f $MOCK_CONFIG ]; then
    cat $MOCK_CONFIG > gem-rtsw.cfg
else
    cat gem-ci/templates/mock/gem-rtsw-header.cfg > gem-rtsw.cfg
fi

sed -e "s#<PROJECTNAME>#$PROJECT_NAME#g" \
  -e "s#<BRANCH>#$BRANCH#g" \
  -e "s#<MATURITY>#$MATURITY#g" \
  gem-ci/templates/mock/$TYPE/gem-rtsw-$TYPE.cfg > gem-rtsw.cfg.tmp

# check if gem-rtsw.cfg.tmp is contained in gem-rtsw.cfg
# (meaning: check if the configuration is already contained 
# in the existing container)
isContained "gem-rtsw.cfg.tmp" "gem-rtsw.cfg" "/^\#\#/" 
if $is_contained; then
    echo Mock configuration already existing, ommitting to append auto-generated one
else
    echo Appending auto-generated mock configuration
    cat gem-rtsw.cfg.tmp >> gem-rtsw.cfg
fi


# create RPM repo configuration file from template 
# and from mock configuration already existing 
# (inherited from BASE_CONTAINER)
REPO_CONFIG="/etc/yum.repos.d/gem-rtsw.repo"
if [ -f $REPO_CONFIG ]; then
    cat $REPO_CONFIG > gem-rtsw.repo
fi

sed -e "s#<PROJECTNAME>#$PROJECT_NAME#g" \
  -e "s#<BRANCH>#$BRANCH#g" \
  -e "s#<MATURITY>#$MATURITY#g" \
  gem-ci/templates/rpm/$TYPE/gem-rtsw-$TYPE.repo >> gem-rtsw.repo.tmp

# check if gem-rtsw.repo.tmp is contained in gem-rtsw.repo
# (meaning: check if the configuration is already contained 
# in the existing container)
isContained "gem-rtsw.repo.tmp" "gem-rtsw.repo" "/^\[gem-rtsw/"
if $is_contained; then
    echo RPM repo configuration already existing, ommitting to append auto-generated one
else
    echo Appending auto-generated RPM repo configuration
    cat gem-rtsw.repo.tmp >> gem-rtsw.repo
fi


# create releasers.conf from template
sed -e "s#<PROJECTNAME>#$PROJECT_NAME#g" \
  -e "s#<BRANCH>#$BRANCH#g" \
  -e "s#<MATURITY>#$MATURITY#g" \
  gem-ci/templates/tito/$TYPE/releasers.conf > releasers.conf

# tweak Containerfile to COPY these repo configuration file instead of default testing ones
#sed -e "s#<BASE_CONTAINER>#$BASE_CONTAINER#g" \
#  -e "s#<PROJECTNAME>#$PROJECT_NAME#g" \
#  -e "s#<MATURITY>#$MATURITY#g" \
#  gem-ci/templates/docker/$TYPE/Containerfile > Containerfile

# in the currently used Containerfile, no tweak is neccessary, the same
# Containerfile is used for all containers:
# all neccessary configuration is in the config files from above which
# are copied into the Container image at container build time.
cp gem-ci/templates/docker/Containerfile Containerfile

trace_off
