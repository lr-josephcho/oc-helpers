#/usr/bin/bash
# Usage: ./get_workflow_status.sh <id_1>,<id_2>,...
for lca_id in ${@//,/ }
do
    echo "\n\n====  ${lca_id} ===="
    echo "Getting Workflow status: audience_${lca_id}"
    echo "cadence workflow showid audience_${lca_id} --of ${lca_id}_temp.json"
    cadence workflow showid audience_${lca_id} --of temp/${lca_id}_temp.json >/dev/null 2>&1
    echo "Saved workflow run history at ${lca_id}_temp.json"
    echo "---"
    python oc_helper.py ${lca_id}
done
