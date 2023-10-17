# Minikube

## Prerequisites
* A Minikube cluster

## Namespaces Overview
The following namespaces are used by the deployment
| Name | Description |
| ---- | ---- |
|sonataflow-operator-system| Sonataflow Serverless Operator will be installed in this namespace.|
|sonataflow-infra| Infra services such as Jobs Service, Data Index and PostgreSQL will be installed in this namespace.|
|User's Workflow Namespace| User specified namespace where workflows will be deployed.|

## Deploy Sonataflow Operator, PostgreSQL, Data Index, Jobs Service & Sample Work Flows
* Be sure to create file called postgres-secret.yaml with following content in sonataflow-infra-services directory.
```yaml
kind: Secret
apiVersion: v1
metadata:
  name: postgres-secrets
  namespace: sonataflow-infra
  labels: 
    app: kogito
data:
  POSTGRES_USER: <Your postgres user>
  POSTGRES_PASSWORD: <Your postgres password>
type: Opaque
```
* Deploy Sonataflow Operator, postgres database, data index, Jobs services and Sample work flows.
* The data index and jobs service will wait for postgres db to come up before coming alive, so as to avoid pod restarts.
```shell
cd kustomize-based/minikube
./deploy.sh
```
* Watch the deployment progress with
```shell
kubectl get pod  --watch
```
* Wait until you see the deployment complete.
* Once you see the workflow pods appear like this example, proceed to the next step. 
    * `greeting-5598d44fbb-cnvqw       1/1     Running             0          16s`
    * `event-timeout-ffc6d5696-8qf5g   1/1     Running             0          17s`

## Testing the Sample Work Flow - Greeting
* Expose the greeting workflow service and get the URL. 
* Note: You may need to keep the terminal window running and carry out next command in a separate terminal.
```shell
kubectl patch svc greeting -p '{"spec": {"type": "NodePort"}}'
minikube service greeting --url
```

* Check if you get a response from the greeting workflow 
```shell
curl -X POST -H 'Content-Type:application/json' -H 'Accept:application/json' -d '{"name": "SonataFlow", "language": "English"}'    http://<Your greeting workflow url>/greeting
```

* A sample response
```json
{"id":"bf05e03f-a996-4482-aff7-89aa4a173be9","workflowdata":{"name":"SonataFlow","language":"English","greeting":"Hello from JSON Workflow, "}}
```

## Testing the Sample Work Flow - TimeOut
* After the deployment above is complete, retrieve the service for timeout workflow and forward the host's port to the service
```shell
kubectl get svc
kubectl port-forward  svc/event-timeout 8088:80
```

* Trigger the timeout workflow and copy the workflow id from the response for use in triggering events below.
```shell
curl -i -X POST -H 'Content-Type:application/json' -H 'Accept:application/json' -d '{}' 'http://localhost:8088/event-timeout'
```

* Sample response
```shell
HTTP/1.1 201 Created
Content-Type: application/json
Location: http://localhost:8088/event-timeout/6df5eff2-ff3f-4ea7-8514-727587700030
content-length: 63

{"id":"6df5eff2-ff3f-4ea7-8514-727587700030","workflowdata":{}}
```

* Fire the following two commands within 60 seconds of command above, as the workflow timeout is 60s. 
* Trigger event1, substitute the id you copied.
```shell
curl -i -X POST -H 'Content-Type: application/cloudevents+json' -d '{"datacontenttype": "application/json", "specversion":"1.0","id":"<Your ID>","source":"/local/curl","type":"event1_event_type","data": "{\"eventData\":\"Event1 sent from UI\"}", "kogitoprocrefid": "<Your ID>" }' http://localhost:8088/
```

* Sample response
```shell
HTTP/1.1 202 Accepted
content-length: 0
```

* Trigger event2, substitute the id you copied.
```shell
curl -i -X POST -H 'Content-Type: application/cloudevents+json' -d '{"datacontenttype": "application/json", "specversion":"1.0","id":"<Your ID>","source":"/local/curl","type":"event2_event_type","data": "{\"eventData\":\"Event2 sent from UI\"}", "kogitoprocrefid": "<Your ID>" }' http://localhost:8088/
```

* Sample response
```shell
HTTP/1.1 202 Accepted
content-length: 0
```

* At any point, use the following command to get running workflow instances
```shell
curl -i -X GET -H 'Content-Type:application/json' -H 'Accept:application/json' -d '{}' 'http://localhost:8088/event-timeout'
```

## Delete the deployment
```shell
./undeploy.sh
```