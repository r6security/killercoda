
Time-based Trigger is a general in-house built backend to implement scheduled triggers for the AMTD Operator in order to restart applications in a timely based manner.

Deploy `Time-based Trigger`:

```
kubectl apply -n time-based-trigger -f ./deploy-time-based-trigger
kubectl -n time-based-trigger wait --for=condition=ready pod --all
kubectl -n time-based-trigger get pods
```{{exec}}
