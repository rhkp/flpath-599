# Kustomize based approach

## Platforms
* [Minikube Instructions](minikube/README.md)
* [Openshift Instructions](openshift/README.md)

## Note 1 - Postgres Secret
* The Postgres secret file is not provided as it is not a good practice to commit secret files
* Please use the following sample to create one and place it in `kustomize-based/sonataflow-infra-services` directory
```yaml
kind: Secret
apiVersion: v1
metadata:
  name: postgres-secrets
  labels: 
    app: kogito
data:
  POSTGRES_USER: <Your base64 encoded value>
  POSTGRES_PASSWORD: <Your base64 encoded value>
type: Opaque
```

## Note 2 - Switching between Openshift and Minikube

* If you are going to test the deployment outlined here on both Openshift and Minikube on the same machine such as a developer machine, please be sure to follow this to avoid unexpected errors due to switching from Openshift to Minikube and vice versa.

### Switching from Openshift to Minikube
* If you have tested the Openshift instructions and now going to test on Minikube, please be sure to... 
    * Logout of Openshift
    ```shell
    oc logout
    ```
    * Start Minikube, so as your kubeconfig will then point to Minikube cluster
    ```shell
    minikube start
    ```
    * Be sure to go into right directory such as minikube
    ```shell
    cd kustomize-based/minikube
    ```
    * When working with Minikube, commands should start with `kubectl`

### Switching from Minikube to Openshift 
* If you have tested the Minikube instructions and now going to test on Openshift, please be sure to... 
    * Stop Minikube
    ```shell
    minikube stop
    ```
    * Login to your openshift cluster
    ```shell
    oc login --token=<Your token> --server=<Your server>
    ```
    * Be sure to go into right directory such as openshift
    ```shell
    cd kustomize-based/openshift
    ```
    * When working with Openshift, commands should start with `oc`