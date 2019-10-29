kubectl apply -f alfresco-namespace.yaml
kubectl apply -f alfresco-pvc.yaml

sleep 10

tr --delete '\n' <alfresco.postgres.password.txt >.strippedpassword.txt && mv .strippedpassword.txt alfresco.postgres.password.txt
kubectl --namespace alfresco create secret generic alfresco-pass --from-file=alfresco.postgres.password.txt

kubectl apply -f alfresco-deployment.yaml