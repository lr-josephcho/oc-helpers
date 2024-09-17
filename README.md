# oc-helpers

Various helper scripts for notorious DsM OC. Things are always work-in-progress so use with caution!

## How I use it
1. I initially prepare four terminal sessions, divided by `tmux`:
- `vim oc_helper.py`
- `vim cadence_helper.sh`
- Two empty sessions
    - One for running `./get_workflow_status.sh <lca_id>`
    - One for running `./cadence_helper.sh <lca_id>`
1. With these sessions, I start going over the stuck audiences list, running `./get_workflow_status.sh <lca_id>` on individual ones. This tells me the latest status of the workflow.
- When I see some unclear result from the command, I go to the pane that has `oc_helper.py` and adds some more logs to be able to catch this workflow status.
1. Once the workflow status has been identified, I run `./cadence_helper.sh <lca_id>` with the proper mode.
- Most of the times, I need to restart the workflows, so I would uncomment the workflow termination parts (for both Mason Workflow and Audience Workflow) and the top Start Workflow mode (Skip Throttling mode)
1. Then I repeat the above steps for all stuck audiences. This naturally enhances the `oc_helper.py` script in the process.
