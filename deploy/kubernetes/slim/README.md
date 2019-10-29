# Alfresco Demo

```bash
git clone https://github.com/fjudith/docker-alfresco
```

## Monolith demo

```bash
cd docker-alfresco/ && \
cd kubernetes/slim/ && \
kubectl apply -f ./ && \
tr --delete '\n' <alfresco.postgres.password.txt >.strippedpassword.txt && mv .strippedpassword.txt alfresco.postgres.password.txt
kubectl -n alfresco create secret generic alfresco-pass --from-file=alfresco.postgres.password.txt
```