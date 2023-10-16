
In this scenario we configure AMTD operator to delete the demo-page pod every time when gets a trigger from Falco, that is a 3rd party security analytics tool. So this case there is no scheduled deletes only on-demand ones.

# Deploy demo-page application:

```
kubectl apply -n demo-page -f ./demo-falco-integrator/demo-page-deployment.yaml
kubectl -n demo-page wait --for=condition=ready pod --all
kubectl -n demo-page get pods -o wide
```{{exec}}

# Apply AMTD configuration:

Before triggering the operator let's check that the we can open a terminal into the pod (this will be denied later, when we activite the configuration for the AMTD operator to consider such thing a security threat and terminate the pod immediately):

`kubectl exec -it -n demo-page deployments/demo-page -c nginx -- sh`{{exec}}

We can see that we are in the terminal, so let's exit from it:

`exit`{{exec}}

Now we can activate the AMTD configuration to take action in case of terminal opening events:
`kubectl apply -n demo-page -f ./demo-falco-integrator/falco-integrator-delete-demo-amtd.yaml`{{exec}}

# Trigger the operator

To trigger a Falco event let's open a terminal into a pod that is considered a security threat according to the current Falco configuration:

`kubectl exec -it -n demo-page deployments/demo-page -c nginx -- sh`{{exec}}

Watch pods to see that the pod where we opened the terminal was deleted (which restarted the application) and that is why the terminal was closed automatically:

`watch kubectl -n demo-page get pods`{{exec}}

To exit from watch loop press `CTRL + C` in the terminal window.

# Clean up this scenario:

`kubectl delete ns demo-page`{{exec}}