#!/bin/bash -e

#aliases for switch on/off command printout to console
shopt -s expand_aliases
alias trace_on='set -x'
alias trace_off='{ set +x; } 2>/dev/null'

trace_on

CONTAINER_PROJECT_BRANCH_FILE="/gem_base/etc/container_project_branch.cfg"

if [ -s $CONTAINER_PROJECT_BRANCH_FILE ]; then
    CONTAINER_PROJECT_BRANCH=$(cat $CONTAINER_PROJECT_BRANCH_FILE)
    echo found BASE_CONTAINER target branch reconfigured to $CONTAINER_PROJECT_BRANCH
    curl --request POST --form token=$CI_JOB_TOKEN \
            --form ref=$CONTAINER_PROJECT_BRANCH \
            --form "variables[TYPE]=$TYPE" \
            --form "variables[OVERRIDE_MATURITY]=$MATURITY" \
            --form "variables[OVERRIDE_BRANCH]=$TARGET_BRANCH" \
            --form "variables[OVERRIDE_SHORT_SHA]=$CI_COMMIT_SHORT_SHA" \
            --form "variables[BASE_CONTAINER]=$NEW_BASE_CONTAINER" \
            --form "variables[CALLER_ID]=$CI_PIPELINE_ID/$CI_JOB_ID" \
            "https://gitlab.com/api/v4/projects/$CONTAINER_PROJECT_HTML/trigger/pipeline"
else
    echo using BASE_CONTAINER target branch configured to project branch $CONTAINER_PROJECT_BRANCH
    curl --request POST --form token=$CI_JOB_TOKEN \
        --form ref=$CONTAINER_PROJECT_BRANCH \
        --form "variables[TYPE]=$TYPE" \
        --form "variables[MATURITY]=$MATURITY" \
        "https://gitlab.com/api/v4/projects/$CONTAINER_PROJECT_HTML/trigger/pipeline"
fi


trace_off
