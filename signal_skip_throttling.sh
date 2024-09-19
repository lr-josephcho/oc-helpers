#/usr/bin/bash
#################################################################################
# This script lets you run various Cadence Workflow commands, to terminate them,
# to restart them, to signal them, etc. You should use either:
#   - Terminate and Start Workflow
#   - Signal Workflow
# When you just want to signal the workflow, don't forget to comment the
# termination and starting parts out.
#################################################################################
export CADENCE_CLI_SHOW_STACKS=1
alias cadence='docker run --rm ubercadence/cli:0.6.4 --address dm-cadence-frontend.service.consul:31776  --domain dataset-manager'
shopt -s expand_aliases

########### LCA_ID Check
if [[ $# -eq 0 ]]; then
    echo "ERROR: No LCA given"
    exit 1
fi

lca_id=$1
echo "INFO: Given LCA_ID: $lca_id"


########### Cadence: Signal Workflow To Skip Throttling (this is used if you want to signal already runnning workflow to skip throttling)
cadence wf signal --workflow_id=audience_${lca_id} --name=AudienceWorkflow::signalSkipThrottling
