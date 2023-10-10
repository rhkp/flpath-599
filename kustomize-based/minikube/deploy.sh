sed -i ".bak" -e "s/<PG_USER>/${PG_USER}/g" -e "s/<PG_PWD>/${PG_PWD}/g" ../sonataflow-event-timeout/configmap_event-timeout-props.yaml
kubectl apply -k ../sonataflow-operator
sleep 30
# Research this further: exec `kubectl wait deployment/sonataflow-operator-controller-manager -n sonataflow-operator-system --timeout=30s --for condition=Ready`
kubectl apply -k .
