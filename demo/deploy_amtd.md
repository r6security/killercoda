
AMTD operator handles triggers from different backends, that are responsible for funneling all the security related events towards the operator. The Operator in response of these events carries out various actions in order to harden the operation evironment of the applications.

Deploy `AMTD Operator`:

```
kubectl apply -n moving-target-defense -f deploy/manifests/deploy-phoenix
kubectl -n moving-target-defense wait --for=condition=ready pod --all
kubectl -n moving-target-defense get pods
```{{exec}}
