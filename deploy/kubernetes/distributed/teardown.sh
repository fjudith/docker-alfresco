kubectl apply -f alfresco-deployment.yaml

sleep 10

kubectl apply -f alfresco-pvc.yaml
kubectl apply -f alfresco-namespace.yaml

