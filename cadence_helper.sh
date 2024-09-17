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


########### Cadence Workflow Termination (add the reason if necessary)
## Terminate Mason Workflow (should come before terminating Audience Workflow)
#cadence wf terminate -w mason_${lca_id} --reason "Retry"

## Terminate Audience Workflow
#cadence wf terminate -w audience_${lca_id} --reason "Retry"



########### Cadence: Start Workflow Modes
## Skip Throttling Mode
#cadence wf start --tl audienceworkflow --wt AudienceWorkflow::start -wrp 1 --et 60000000 --workflow_id audience_${lca_id}  -i '{"lcaId":"'"${lca_id}"'","fromDB":true, "workflowConfigurations":[]}'

## Particular Flavor (here, it's qa-joseph)
#cadence wf start --tl audienceworkflow-qa-joseph --wt AudienceWorkflow::start -wrp 1 --et 60000000 --workflow_id audience_${lca_id}  -i '{"lcaId":"'"${lca_id}"'","fromDB":true, "workflowConfigurations":[]}'

## Skip Throttling & Skip Full Recomp Mode
#cadence wf start --tl audienceworkflow --wt AudienceWorkflow::start --workflow_id audience_${lca_id} -wrp 1 -et 60000000 -i '{"lcaId":"'"${lca_id}"'", "fromDB":true, "workflowConfigurations":[], "skipFullRecomps":true}'

## Skip Throttling & Controlled Batch Size Mode
#cadence wf start --tl audienceworkflow --wt AudienceWorkflow::start --workflow_id audience_${lca_id} -wrp 1 -et 60000000 -i '{"lcaId":"'"${lca_id}"'", "fromDB":true, "workflowConfigurations":[], "batchSizeOverride":50}'

## Skip Throttling & Skip Full Recomp & Controlled Batch Size Mode
#cadence wf start --tl audienceworkflow --wt AudienceWorkflow::start --workflow_id audience_${lca_id} -wrp 1 -et 60000000 -i '{"lcaId":"'"${lca_id}"'", "fromDB":true, "workflowConfigurations":[], "skipFullRecomps":true, "batchSizeOverride":100}'

# You can also add "skipThrottling":true in the options part


########### Cadence: Start Workflow From Specific Step (find the workflow's run_id and replcae it in the command below)
#cadence wf reset -w audience_${lca_id} -r 1a27540e-5033-4bfd-a247-d1b44bfc8d52 --event_id 142 --reason "retry"



########### Cadence: Signal Workflow To Skip Throttling (this is used if you want to signal already runnning workflow to skip throttling)
cadence wf signal --workflow_id=audience_${lca_id} --name=AudienceWorkflow::signalSkipThrottling
