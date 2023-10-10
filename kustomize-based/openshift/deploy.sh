oc apply -k ../sonataflow-operator

sed -i ".bak" -e "s/<PG_USER>/${PG_USER}/g" -e "s/<PG_PWD>/${PG_PWD}/g" ../sonataflow-event-timeout-openshift/configmap_event-timeout-props.yaml

sleep 30
oc apply -k .
