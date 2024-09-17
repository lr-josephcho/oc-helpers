# TODO: Make it more interactive that could restart with one key stroke
import json, base64, sys, pprint

try:
    lca_id = int(sys.argv[1])
except:
    print(f"Invalid audience ID given: {sys.argv[1]}")
    exit(1)

print(f"Running oc_helper.py with audience: {lca_id}\n")

events = json.load(open(f'temp/{lca_id}_temp.json'))

workflow_input_decoded = events[0]['workflowExecutionStartedEventAttributes']['input']
workflow_input = json.loads(base64.b64decode(workflow_input_decoded.encode('ascii')))

for _key in ['lcaId', 'fromDB', 'workflowConfigurations']:
    workflow_input.pop(_key, None)
print(f"- Workflow Inputs: {workflow_input}")

last_event = events[-1]
last_activity_event = None
last_activity_event_i = -1

for event in events[::-1]:
    if event['eventType'][:8] != 'Decision' and event['eventType'][:8] != 'Workflow':
        last_activity_event = event
        break
    last_activity_event_i -= 1

if last_event['eventType'] == 'DecisionTaskCompleted' or last_event['eventType'] == 'WorkflowExecutionTerminated':
    if last_activity_event['eventType'] == 'ChildWorkflowExecutionStarted':
        print("- Still running child workflow: " + str(last_activity_event['childWorkflowExecutionStartedEventAttributes']['workflowType']))
    elif last_activity_event['eventType'] == 'ChildWorkflowExecutionFailed':
        print(f"- Mason failed")
        details = last_activity_event['childWorkflowExecutionFailedEventAttributes']['details']
        reason = json.loads(base64.b64decode(details.encode('ascii')))
        print(f"- Reason: {reason['detailMessage']}")

        for event in events[last_activity_event_i-1::-1]:
            if event['eventType'] == 'StartChildWorkflowExecutionInitiated':
                task_list = event['startChildWorkflowExecutionInitiatedEventAttributes']['taskList']['name']
                print(f"- Last Task List: {task_list}")

                input_encoded = event['startChildWorkflowExecutionInitiatedEventAttributes']['input']
                input_decoded = json.loads(base64.b64decode(input_encoded.encode('ascii')))
                mason_algorithm = input_decoded['masonAlgorithm']
                print(f"- Mason Algorithm: {mason_algorithm}")
                break
    elif last_activity_event['eventType'] == 'ActivityTaskFailed':
        details_encoded = last_activity_event['activityTaskFailedEventAttributes']['details']
        details = json.loads(base64.b64decode(details_encoded.encode('ascii')))
        print(f"- Activity failed: {details['detailMessage']}")
        print(f"- Cause: {details['cause']['detailMessage']}") 
elif last_event['eventType'] == 'DecisionTaskTimedOut':
    print("- Decision Task timed out. Restart from the beginning.")
elif last_event['eventType'] == 'WorkflowExecutionTerminated':
    print("- Workflow has been terminated.")
#elif last_event['eventType'] == 'ChildWorkflowExecutionFailed':
elif last_event['eventType'] == 'WorkflowExecutionCompleted':
    # Check if it didn't fail
    if last_activity_event['eventType'] == 'ActivityTaskFailed':
        details_encoded = last_activity_event['activityTaskFailedEventAttributes']['details']
        details = json.loads(base64.b64decode(details_encoded.encode('ascii')))
        print(f"- Activity failed: {details['detailMessage']}")
        print(f"- Cause: {details['cause']['detailMessage']}") 
    elif last_activity_event['eventType'] == 'ActivityTaskCompleted':
        print("Workflow has completed 👍")
elif last_event['eventType'] == 'TimerStarted':
    throttling_time_sec = last_event['timerStartedEventAttributes']['startToFireTimeoutSeconds']
    print(f"Workflow is being throttled for {throttling_time_sec / 60} min")
else:
    print("Unsupported exception. Need further investigation")
    #import pdb; pdb.set_trace()
