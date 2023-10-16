
In this scenario we configure AMTD operator to delete the demo-page pod every time when it gets a trigger from Time-based Trigger. The trigger period for this scenario is 30 seconds.

# Deploy demo-page application:

```
kubectl apply -n demo-page -f ./demo-time-based-trigger/demo-page-deployment.yaml
kubectl -n demo-page wait --for=condition=ready pod --all
kubectl -n demo-page get pods -o wide
```{{exec}}

# Activate AMTD in the cluster

1. Apply AMTD configuration:

    `kubectl apply -n demo-page -f ./demo-time-based-trigger/time-based-trigger-demo-amtd.yaml`{{exec}}

2. Set the timer to 30s:

    `kubectl patch -n demo-page deployments.apps demo-page -p '"spec": {"template": { "metadata": {"annotations": {"time-based-trigger.amtd.r6security.com/schedule": "30s"}}}}'`{{exec}}

3. Enable time-based-trigger for the pod

    `kubectl patch -n demo-page deployments.apps demo-page -p '"spec": {"template": { "metadata": {"annotations": {"time-based-trigger.amtd.r6security.com/enabled": "true"}}}}'`{{exec}}

Watch pods to see the restarts in every 30 seconds:

`watch kubectl -n demo-page get pods`{{exec}}

To exit from watch loop press `CTRL + C` in the terminal window.

# Clean up this scenario:

`kubectl delete ns demo-page`{{exec}}

