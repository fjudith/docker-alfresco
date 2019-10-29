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

  tr --delete '\n' <alfresco.postgres.password.txt >.strippedpassword.txt && mv .strippedpassword.txt alfresco.postgres.password.txt
  kubectl --namespace alfresco create secret generic alfresco-pass --from-file=alfresco.postgres.password.txt
  
  kubectl apply -f storage/hostpath/local-volumes.yaml
  
  kubectl --namespace alfresco apply -f ./alfresco-deployment.yaml

  kubectl --namespace alfresco get svc share

# Create using Conduit service mesh
elif [ -v create ] && [ "$create" == "conduit" ]; then

  tr --delete '\n' <alfresco.postgres.password.txt >.strippedpassword.txt && mv .strippedpassword.txt alfresco.postgres.password.txt
  kubectl --namespace alfresco create secret generic alfresco-pass --from-file=alfresco.postgres.password.txt
  
  kubectl apply -f storage/hostpath/local-volumes.yaml
  
  cat ./alfresco-deployment.yaml | conduit inject --skip-outbound-ports=5432,8100 --skip-inbound-ports=5432,8100 - | kubectl --namespace alfresco apply -f -

  kubectl --namespace alfresco get svc share  -o jsonpath="{.status.loadBalancer.ingress[0].*}"

  kubectl --namespace alfresco get svc share

# Create using Istio service mesh with automatic sidecar
elif [ -v create ] && [ "$create" == "istio" ]; then
  kubectl label namespace alfresco istio-injection=enabled

  tr --delete '\n' <alfresco.postgres.password.txt >.strippedpassword.txt && mv .strippedpassword.txt alfresco.postgres.password.txt
  kubectl --namespace alfresco create secret generic alfresco-pass --from-file=alfresco.postgres.password.txt
  
  kubectl apply -f storage/hostpath/local-volumes.yaml
  
  kubectl --namespace alfresco apply -f ./alfresco-deployment.yaml
  
  kubectl --namespace alfresco apply -f ./alfresco-ingress.yaml

  export GATEWAY_URL=$(kubectl get po -l istio=ingress -n istio-system -o 'jsonpath={.items[0].status.hostIP}'):$(kubectl get svc istio-ingress -n istio-system -o 'jsonpath={.spec.ports[0].nodePort}')

  printf "Istio Gateway: $GATEWAY_URL"
fi


# Delete
if [ -z delete ] || [ "$delete" == "conduit" ]; then
  kubectl delete -f storage/hostpath/local-volumes.yaml

  kubectl delete namespace alfresco
fi

if [ -v delete ] && [ "$delete" == "istio" ]; then
  kubectl delete -f storage/hostpath/local-volumes.yaml

  kubectl delete namespace alfresco
fi