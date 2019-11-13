# template

```bash
# kubectl run my-flask-web --image=flask_web:v1 --replicas=2 --generator=run-pod/v1 --dry-run -o yaml > ./flask-pod.yaml



# kubectl run my-flask-web --image=flask_web:v1 --replicas=2 --service-generator='service/v2' --expose --port=5000 --dry-run -o yaml > ./flask-service.yaml




# kubectl run my-flask-web --image=flask_web:v1 --replicas=2 --generator=deployment/apps.v1 --dry-run -o yaml > ./flask-deployment.yaml

```
