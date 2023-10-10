# flpath-599

## Prerequisites
* An Openshift or Kubernetes cluster
* You must be logged in to the cluster from command line
* Necessary permissions to deploy and delete services

## PostgreSQL

### Deploy
* Deploy postgres database with the password secret and persistence volume claim
```shell
kubectl apply -f <Your postgres-secret.yaml> 
kubectl apply -f postgres.yaml
```

### Test
* Test postgres from client machine such as Mac, by forwarding client machine port to postgres server pod port
```shell
kubectl port-forward pod/postgres-db-0 15432:5432
```
* In another terminal window
```shell
 psql -h localhost -p 15432 -U postgres -d sonataflow
 ```
 * Check whether the database list is shown with `\l` command
 ```shell
 sonataflow=# \l
 ```

## Zookeeper
* Deploy zookeeper
```shell
kubectl apply -f zookeeper.yaml
```

## Kafka
* Deploy kafka
```shell
kubectl apply -f kafka.yaml
```

## DataIndex
* Deploy Data Index
```shell
kubectl apply -f data-index.yaml
```

## Jobs Service
* Deploy Jobs Service
```shell
kubectl apply -f jobs-service.yaml
```

## Delete Deployments
* Delete all the services deployed earlier
```shell
kubectl delete -f jobs-service.yaml
kubectl delete -f data-index.yaml
kubectl delete -f kafka.yaml
kubectl delete -f zookeeper.yaml
kubectl delete -f postgres.yaml
kubectl delete -f <Your postgres-secret.yaml>
```