# Pod Startup Triage

`triage-api` is a small notes API that must run on a local Kubernetes cluster. The manifests in `k8s/` do not produce a running, stable pod. Investigate with `kubectl`, repair the manifests, and prove the API is healthy through its Service.

No cloud account, billing, registry login, or real credential is used. The instructor prepares the cluster and loads the image before the timer.

## Application contract

| Item | Value |
|---|---|
| Image (already loaded on the cluster node) | `triage-api:1.0.0` |
| Container port | `5000` |
| Health endpoint | `GET /health` returns HTTP 200 with `"status": "ok"` |
| Service | `triage-api`, ClusterIP, port `80` → container port `5000` |

## Resource budget

The pod must fit on a small shared lab node. Use exactly these values:

| | CPU | Memory |
|---|---|---|
| Requests | `100m` | `64Mi` |
| Limits | `250m` | `128Mi` |

## Probes

Keep both probes. Both must check `GET /health` on the container port. Do not delete a probe or change its timings to hide a failure.

## Files

```text
app/app.py            # application (do not edit)
Dockerfile            # image build, used by the instructor (do not edit)
k8s/deployment.yaml   # Deployment triage-api
k8s/service.yaml      # Service triage-api
scripts/request.sh    # sends a request from inside the cluster (do not edit)
```

## Commands

Your instructor gives you a namespace. The examples use `triage-ca`; replace it if yours is different.

```bash
kubectl -n triage-ca get pods
kubectl -n triage-ca describe pod -l app=triage-api
kubectl -n triage-ca get events --sort-by=.lastTimestamp
kubectl -n triage-ca logs deploy/triage-api
kubectl -n triage-ca apply -f k8s/
kubectl -n triage-ca rollout status deploy/triage-api
kubectl -n triage-ca get endpointslices -l kubernetes.io/service-name=triage-api
bash scripts/request.sh triage-ca http://triage-api/health
```

## Rules

- The repository has exactly three planted faults, all in `k8s/deployment.yaml`. Fix them in task order; fixing one fault reveals the next.
- Edit only `k8s/deployment.yaml`. Do not edit the app, Dockerfile, Service, or scripts.
- Do not rebuild or retag the image. Do not delete probes.
- Work only in your assigned namespace.

## Instructor setup (before the timer)

```bash
docker build -t triage-api:1.0.0 .
# Load the image into your cluster, for example:
#   kind load docker-image triage-api:1.0.0 --name <cluster>
#   minikube image load triage-api:1.0.0
kubectl create namespace triage-ca
kubectl -n triage-ca apply -f k8s/
```
