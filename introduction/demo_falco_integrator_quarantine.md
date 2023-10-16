
In this scenario we configure AMTD operator to put the threathend pod into quarantine instead of deleting it. This makes further investigation possible. here the trigger is based again on Falco.

# Deploy demo-page application:

```
kubectl apply -n demo-page -f ./demo-falco-integrator/demo-page-deployment.yaml
kubectl -n demo-page wait --for=condition=ready pod --all
kubectl -n demo-page get pods -o wide
```{{exec}}

# Apply AMTD configuration:

Before triggering the operator let's check that the network connection of the demo-page is working fine (this will be suspended later, when we define a rule that open a terminal results putting the application pod into quarantine):

`kubectl exec -it -n demo-page deployments/demo-page -c nginx -- sh`{{exec}}

We can see that google.com is reachable from the pod:

`curl google.com`{{exec}}

Let's exit:

`exit`{{exec}}

Now we can activate the AMTD configuration to take action in case of terminal opening events:
`kubectl apply -n demo-page -f ./demo-falco-integrator/falco-integrator-quarantine-demo-amtd.yaml`{{exec}}

# Trigger the operator

To trigger a Falco event let's do the same as in the previous step: open a terminal into a pod that is considered a security threat according to the current Falco configuration:

`kubectl exec -it -n demo-page deployments/demo-page -c nginx -- sh`{{exec}}

Notice that in this case the pod does not terminate the connection, however there will be no access to any external resources, e.g. curl google.com, because of the quarantine. 

Try curl on google.com again (we should see no connection):

`curl google.com`{{exec}}

To interrupt the stucked curl command press `CTRL + C` in the terminal window.

Let's exit from the pod and check the list of the pods:

`exit`{{exec}}

`watch kubectl -n demo-page get pods --show-labels`{{exec}}

Notice that the pod where we opened the terminal was kept and new pod is started automatically. Also notice the `amtd.r6security.com/network-policy` label on the pod that is in quarantine now.

To exit from watch loop press `CTRL + C` in the terminal window.

# Clean up this scenario:

`kubectl delete ns demo-page`{{exec}}