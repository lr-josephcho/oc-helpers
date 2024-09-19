#/usr/bin/bash
# Usage: ./get_workflow_status.sh <id_1>,<id_2>,...
for lca_id in ${@//,/ }
do
    echo "\n\n==== ${lca_id} ===="
    echo "> Audience Workflow"
    echo ""
    echo "Getting Audiencd Workflow data: audience_${lca_id}"
    cadence workflow showid audience_${lca_id} --of temp/audience_${lca_id}.json >/dev/null 2>&1
    echo "Saved Audience Workflow history at temp/audience_${lca_id}.json"
    echo ""
    echo "Running Audience Workflow Analyzer"
    echo ""
    python audience_workflow_analyzer.py ${lca_id}
    return_value=$?
    rm temp/audience_${lca_id}.json

    if [[ $return_value == 10 ]]; then
        echo "\n==="
        echo "> Mason Workflow"
        echo ""
        echo "Getting Mason Workflow data: mason_${lca_id}"
        cadence workflow showid mason_${lca_id} --of temp/mason_${lca_id}.json >/dev/null 2>&1
        echo "Saved Mason Workflow history at temp/mason_${lca_id}.json"
        echo ""
        echo "Running Mason Workflow Analyzer"
        echo ""
        python mason_workflow_analyzer.py ${lca_id}
        rm temp/mason_${lca_id}.json
    elif [[ $return_value == 20 ]]; then
        echo "\n==="
        echo "Skipping Audience Workflow Throttling"
        ./signal_skip_throttling.sh ${lca_id}
    fi
    echo ""
done
