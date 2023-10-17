# Helm based approach

## Namespaces Overview
The following namespaces are used by the deployment
| Name | Description |
| ---- | ---- |
|sonataflow-operator-system| Sonataflow Serverless Operator will be installed in this namespace.|
|sonataflow-infra| Infra services such as Jobs Service, Data Index and PostgreSQL will be installed in this namespace.|
|User's Workflow Namespace| User specified namespace where workflows will be deployed.|

## Providing Postgres Credentials

### For use by kubernetes secret
* The postgres credentials are provided by the user via environment variables, before executing the installation script.
* Set the base64 encoded postgres credentials in the terminal window as:
```shell
export BASE64_PG_USER=<Base64 encoded Postgres user>
export BASE64_PG_PWD=<Base64 encoded Postgres password>
```

* You can get base64 encoded value as follows
```shell
echo <Value to be base64 encoded> | base64
```

* Both the environment variables should be set appropriately, check if the values are correct with the following.
```shell
echo $BASE64_PG_USER
echo $BASE64_PG_PWD
```

### For use by timeout workflow application.properties
* Set the postgres credentials in the terminal window as:
```shell
export PG_USER=<Postgres user>
export PG_PWD=<Postgres password>
```

* Both the environment variables should be set appropriately, check if the values are correct with the following.
```shell
echo $PG_USER
echo $PG_PWD
```

## Minikube

### Prerequisites
* A Minikube cluster

### Update values.yaml
* Update clusterPlatform value as follows
```yaml
clusterPlatform: minikube
```

### Deploy Sonataflow Operator, PostgreSQL, Data Index, Jobs Service & Sample Work Flows
* Deploy Sonataflow Operator, postgres database, data index, Jobs services and Sample work flows.
* The data index and jobs service will wait for postgres db to come up before coming alive, so as to avoid pod restarts.
```shell
cd helm-based
./deploy.sh
```
* Watch the deployment progress with
```shell
kubectl get pod  --watch
```
* Wait until you see the deployment complete.
* Once you see the workflow pods appear like this example, proceed to the next step. 
    * `greeting-5598d44fbb-cnvqw       1/1     Running             0          16s`
    * `event-timeout-ffc6d5696-ntrjv   1/1     Running             0          16s`

### Testing the Sample Work Flow - Greeting 
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

### Testing the Sample Work Flow - TimeOut
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
Location: http://localhost:8088/event-timeout/180ee8a1-5b3f-4fef-bd9a-abc131ca65ef
content-length: 63

{"id":"180ee8a1-5b3f-4fef-bd9a-abc131ca65ef","workflowdata":{}}
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

### Delete the deployment
```shell
./undeploy.sh
```

## Openshift

### Prerequisites
* An Openshift or Openshift Local cluster
* You must be logged in to the cluster from command line
* Necessary permissions to deploy and delete services
* helm command is available

### Update values.yaml
* Update clusterPlatform value as follows
```yaml
clusterPlatform: openshift
```

### Deploy Sonataflow Operator, PostgreSQL, Data Index, Jobs Service & Sample Work Flows
* Deploy Sonataflow Operator, postgres database, data index, Jobs services and Sample work flows.
* The data index and jobs service will wait for postgres db to come up before coming alive, so as to avoid pod restarts.
```shell
cd helm-based
./deploy.sh
```

* Watch the deployment progress with
```shell
oc get pod  --watch
```
* Wait until you see the deployment complete.
* Once you see the workflow pods appear like this example, proceed to the next step. 
    * `greeting-7f596f94b6-hqrf8       1/1     Running             0          16s`
    * `event-timeout-58b45fd67d-8qwlk  1/1     Running             0          16s`

### Testing the Sample Work Flow - Greeting
* After the deployment above is complete, retrieve the route of the workflow greeting service
```shell
oc get route
```

* Check if you get a response from the greeting workflow 
```shell
curl -X POST -H 'Content-Type:application/json' -H 'Accept:application/json' -d '{"name": "SonataFlow", "language": "English"}'    http://<Your greeting workflow route>/greeting
```

* A sample response
```json
{"id":"bf05e03f-a996-4482-aff7-89aa4a173be9","workflowdata":{"name":"SonataFlow","language":"English","greeting":"Hello from JSON Workflow, "}}
```

### Testing the Sample Work Flow - TimeOut
* After the deployment above is complete, retrieve the route of the timeout workflow service
```shell
oc get route
```

* Trigger the timeout workflow and copy the workflow id from the response for use in triggering events below.
```shell
curl -i -X POST -H 'Content-Type:application/json' -H 'Accept:application/json' -d '{}' 'http://<Your route>/event-timeout'
```

* Sample response
```shell
HTTP/1.1 201 Created
content-type: application/json
location: http://event-timeout-arhkp-kustomize.apps.rhdh-dev01.kni.syseng.devcluster.openshift.com/event-timeout/2d9df0c1-a29d-4c0e-935b-69dff924337b
content-length: 63
set-cookie: 284c72073c9d87b5fbe261defd9c0b1d=a697867349606d7b0f58d9e662eb78ca; path=/; HttpOnly

{"id":"2d9df0c1-a29d-4c0e-935b-69dff924337b","workflowdata":{}}
```

* Fire the following two commands within 60 seconds of command above, as the workflow timeout is 60s. 
* Trigger event1, substitute the id you copied.
```shell
curl -i -X POST -H 'Content-Type: application/json' -d '{"datacontenttype": "application/json", "specversion":"1.0","id":"<Your ID>","source":"/local/curl","type":"event1_event_type","data": "{\"eventData\":\"Event1 sent from Command Line\"}", "kogitoprocrefid": "<Your ID>" }' http://<Your route>/event-timeout
```

* Sample response
```shell
HTTP/1.1 201 Created
content-type: application/json
location: http://event-timeout-arhkp-kustomize.apps.rhdh-dev01.kni.syseng.devcluster.openshift.com/event-timeout/1a3a5821-4b7f-4eaf-9f35-d3e7a46bafcb
content-length: 319
set-cookie: 284c72073c9d87b5fbe261defd9c0b1d=a697867349606d7b0f58d9e662eb78ca; path=/; HttpOnly

{"id":"1a3a5821-4b7f-4eaf-9f35-d3e7a46bafcb","workflowdata":{"datacontenttype":"application/json","specversion":"1.0","id":"2d9df0c1-a29d-4c0e-935b-69dff924337b","source":"/local/curl","type":"event1_event_type","data":"{\"eventData\":\"Event1 sent from UI\"}","kogitoprocrefid":"2d9df0c1-a29d-4c0e-935b-69dff924337b"}}
```

* Trigger event2, substitute the id you copied.
```shell
curl -i -X POST -H 'Content-Type: application/json' -d '{"datacontenttype": "application/json", "specversion":"1.0","id":"<Your ID>","source":"/local/curl","type":"event2_event_type","data": "{\"eventData\":\"Event2 sent from Command Line\"}", "kogitoprocrefid": "<Your ID>" }' http://<Your route>/event-timeout
```

* Sample response
```shell
HTTP/1.1 201 Created
content-type: application/json
location: http://event-timeout-arhkp-kustomize.apps.rhdh-dev01.kni.syseng.devcluster.openshift.com/event-timeout/d378f63d-01a7-4e78-9ec7-5f2fe7fe4cbe
content-length: 319
set-cookie: 284c72073c9d87b5fbe261defd9c0b1d=a697867349606d7b0f58d9e662eb78ca; path=/; HttpOnly

{"id":"d378f63d-01a7-4e78-9ec7-5f2fe7fe4cbe","workflowdata":{"datacontenttype":"application/json","specversion":"1.0","id":"2d9df0c1-a29d-4c0e-935b-69dff924337b","source":"/local/curl","type":"event2_event_type","data":"{\"eventData\":\"Event2 sent from UI\"}","kogitoprocrefid":"2d9df0c1-a29d-4c0e-935b-69dff924337b"}}
```

* At any point, use the following command to get running workflow instances
```shell
curl -i -X GET -H 'Content-Type:application/json' -H 'Accept:application/json' -d '{}' 'http://<Your route>/event-timeout'
```

### Delete the deployment
```shell
./undeploy.sh
```