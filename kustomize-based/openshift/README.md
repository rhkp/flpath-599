# Openshift

## Prerequisites
* An Openshift or Openshift Local cluster
* You must be logged in to the cluster from command line
* Necessary permissions to deploy and delete services

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
cd kustomize-based/openshift
oc project <your desired namespace>
./deploy.sh
```
* Watch the deployment progress with
```shell
oc get pod  --watch
```
* Wait until you see the deployment complete.
* Once you see the workflow pods appear like this example, proceed to the next step. 
    * `event-timeout-58b45fd67d-rmh2w   1/1     Running             0          16s`
    * `greeting-7f596f94b6-t5tb6        1/1     Running             0          16s`

## Testing the Sample Work Flow - Greetings
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

## Testing the Sample Work Flow - TimeOut
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
location: http://event-timeout-arhkp-kustomize.apps.rhdh-dev01.kni.syseng.devcluster.openshift.com/event-timeout/bc3a6a77-6680-42bf-a5f4-71dd4e1e497e
content-length: 63
set-cookie: 284c72073c9d87b5fbe261defd9c0b1d=6cb8e816347562019ac2b0ae26e23025; path=/; HttpOnly

{"id":"bc3a6a77-6680-42bf-a5f4-71dd4e1e497e","workflowdata":{}}
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
location: http://event-timeout-arhkp-kustomize.apps.rhdh-dev01.kni.syseng.devcluster.openshift.com/event-timeout/d014afa4-3812-4426-b021-c6dc29b5d6df
content-length: 319
set-cookie: 284c72073c9d87b5fbe261defd9c0b1d=6cb8e816347562019ac2b0ae26e23025; path=/; HttpOnly

{"id":"d014afa4-3812-4426-b021-c6dc29b5d6df","workflowdata":{"datacontenttype":"application/json","specversion":"1.0","id":"bc3a6a77-6680-42bf-a5f4-71dd4e1e497e","source":"/local/curl","type":"event1_event_type","data":"{\"eventData\":\"Event1 sent from UI\"}","kogitoprocrefid":"bc3a6a77-6680-42bf-a5f4-71dd4e1e497e"}}
```

* Trigger event2, substitute the id you copied.
```shell
curl -i -X POST -H 'Content-Type: application/json' -d '{"datacontenttype": "application/json", "specversion":"1.0","id":"<Your ID>","source":"/local/curl","type":"event2_event_type","data": "{\"eventData\":\"Event2 sent from Command Line\"}", "kogitoprocrefid": "<Your ID>" }' http://<Your route>/event-timeout
```

* Sample response
```shell
HTTP/1.1 201 Created
content-type: application/json
location: http://event-timeout-arhkp-kustomize.apps.rhdh-dev01.kni.syseng.devcluster.openshift.com/event-timeout/645a11ed-23ba-4bda-bf19-a6bfe2c64b1e
content-length: 319
set-cookie: 284c72073c9d87b5fbe261defd9c0b1d=6cb8e816347562019ac2b0ae26e23025; path=/; HttpOnly

{"id":"645a11ed-23ba-4bda-bf19-a6bfe2c64b1e","workflowdata":{"datacontenttype":"application/json","specversion":"1.0","id":"bc3a6a77-6680-42bf-a5f4-71dd4e1e497e","source":"/local/curl","type":"event2_event_type","data":"{\"eventData\":\"Event2 sent from UI\"}","kogitoprocrefid":"bc3a6a77-6680-42bf-a5f4-71dd4e1e497e"}}
```

* At any point, use the following command to get running workflow instances
```shell
curl -i -X GET -H 'Content-Type:application/json' -H 'Accept:application/json' -d '{}' 'http://<Your route>/event-timeout'
```

## Delete the deployment
```shell
./undeploy.sh
```