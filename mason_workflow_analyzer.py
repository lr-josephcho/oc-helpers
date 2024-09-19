# TODO: Make it more interactive that could restart with one key stroke
import json, base64, sys, pprint

def ppp(input_json):
    print(json.dumps(input_json, indent=4))

def main(lca_id):
    events = json.load(open(f'temp/mason_{lca_id}.json'))
    workflow_input_decoded = events[0]['workflowExecutionStartedEventAttributes']['input']
    workflow_input = json.loads(base64.b64decode(workflow_input_decoded.encode('ascii')))

    print(f"-- Workflow Algorithm: {workflow_input['masonAlgorithm']}")
    print(f"-- Workflow contains AIs to Delete Paths: {len(workflow_input['aiToDeletePaths']) > 0}")

    last_event = events[-1]
    last_activity_event = None
    last_activity_event_i = len(events) - 1

    for event in events[::-1]:
        if event['eventType'][:8] != 'Decision' and event['eventType'][:8] != 'Workflow':
            last_activity_event = event
            break
        last_activity_event_i -= 1

    if last_activity_event['eventType'] == 'ActivityTaskStarted' or last_activity_event['eventType'] == 'ActivityTaskScheduled':
        last_activity_task_scheduled = None
        for event in events[last_activity_event_i:: -1]:
            if event['eventType'] == 'ActivityTaskScheduled':
                last_activity_task_scheduled = event
                break

        activity_attr = last_activity_task_scheduled['activityTaskScheduledEventAttributes']
        print(f"--- Waiting for the last activity to finish: {activity_attr['activityType']}")
        print(f"--- Task List: {activity_attr['taskList']}")
        print(f"--- Activity Type: {activity_attr['activityType']}")
    else:
        print("--- Unsupported exception. Need further investigation")
        import pdb; pdb.set_trace()

if __name__ == "__main__":
    try:
        lca_id = int(sys.argv[1])
    except:
        print(f"- Invalid audience ID given: {sys.argv[1]}")
        exit(-1)

    print("- Running mason_workflow_analyzer.py")
    main(lca_id)
