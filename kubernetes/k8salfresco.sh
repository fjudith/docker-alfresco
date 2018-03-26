#!/bin/bash

while [ $# -gt 0 ]; do

   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
   fi

  shift
done

# Create
if [ -z create ] ; then
  tr --delete '\n' <password.txt >.strippedpassword.txt && mv .strippedpassword.txt alfresco.postgres.password.txt
  kubectl create secret generic alfresco-pass --from-file=alfresco.postgres.password.txt
  kubectl apply -f ./local-volumes.yaml
  kubectl apply -f ./alfresco-deployment.yaml

  kubectl get svc share -n default
elif [ -v create ] && [ "$create" == "conduit" ]; then
  tr --delete '\n' <password.txt >.strippedpassword.txt && mv .strippedpassword.txt alfresco.postgres.password.txt
  kubectl create secret generic alfresco-pass --from-file=alfresco.postgres.password.txt
  kubectl apply -f ./local-volumes.yaml
  cat ./alfresco-deployment.yaml | conduit inject --skip-outbound-ports=5432,8100 --skip-inbound-ports=5432,8100 - | kubectl apply -f -

  kubectl get svc share -n default -o jsonpath="{.status.loadBalancer.ingress[0].*}"

  kubectl get svc share -n default
elif [ -v create ] && [ "$create" == "istio" ]; then
  kubectl create namespace alfresco
  kubectl label namespace alfresco istio-injection=enabled

  tr --delete '\n' <password.txt >.strippedpassword.txt && mv .strippedpassword.txt alfresco.postgres.password.txt
  kubectl create secret generic -n alfresco alfresco-pass --from-file=alfresco.postgres.password.txt
  kubectl apply -f ./local-volumes.yaml
  kubectl apply -n alfresco -f ./alfresco-deployment.yaml
  kubectl apply -n alfresco -f ./alfresco-ingress.yaml

  export GATEWAY_URL=$(kubectl get po -l istio=ingress -n istio-system -o 'jsonpath={.items[0].status.hostIP}'):$(kubectl get svc istio-ingress -n istio-system -o 'jsonpath={.spec.ports[0].nodePort}')

  printf "Istio Gateway: $GATEWAY_URL"
fi


# Delete
if [ -z delete ] || [ "$delete" == "conduit" ]; then
  kubectl delete -f ./local-volumes.yaml
  kubectl delete secret alfresco-pass
  kubectl delete -f ./alfresco-deployment.yaml
fi

if [ -v delete ] && [ "$delete" == "istio" ]; then
  kubectl delete -n alfresco -f ./local-volumes.yaml
  kubectl delete secret alfresco-passs
  kubectl delete -n alfresco -f ./alfresco-deployment.yaml
  kubectl delete -n alfresco -f ./alfresco-ingress.yaml

  kubectl delete namespace alfresco
fi