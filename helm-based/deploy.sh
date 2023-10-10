sed -i ".bak" -e "s/<PG_USER>/${PG_USER}/g" -e "s/<PG_PWD>/${PG_PWD}/g" templates/sonataflow-event-timeout-props-cm.yaml

helm install --set postgres.user=$BASE64_PG_USER --set postgres.pw=$BASE64_PG_PWD swf .