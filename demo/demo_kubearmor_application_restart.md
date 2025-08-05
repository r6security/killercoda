
In this scenario we configure Phoenix to restart a specific pod when a corresponding KubeArmor alert is created. Since KubeArmor is capable of doing security enforcement on its own, this scenario would like to show an example of how Phoenix can be used to serve as another layer of security measures. In this simple example, KubeArmor will be configured to block any usage of package manager inside the pod, and in response to the alerts that KuberArmor generates, Phoenix immediately restarts the pod (the specific action is configurable). For this, Phoenix relies on triggers (SecurityEvents) that are created by the KubeArmor-integrator which translates KubeArmor alerts towards Phoenix.

# KubeArmor installation

```
helm repo add kubearmor https://kubearmor.github.io/charts
helm repo update kubearmor
helm upgrade --install kubearmor-operator kubearmor/kubearmor-operator -n kubearmor --create-namespace
kubectl apply -f https://raw.githubusercontent.com/kubearmor/KubeArmor/main/pkg/KubeArmorOperator/config/samples/sample-config.yml
kubectl -n kubearmor wait --for=condition=ready pod --all
kubectl -n kubearmor get pods -o wide
```{{exec}}

# Deploy demo-page application:

```
kubectl apply -n demo-page -f deploy/manifests/demo-page/demo-page-deployment.yaml
kubectl -n demo-page wait --for=condition=ready pod --all
kubectl -n demo-page get pods -o wide
```{{exec}}

# Configure KubeArmor:

Create the policy

```
cat <<EOF | kubectl -n demo-page apply -f -
apiVersion: security.kubearmor.com/v1
kind: KubeArmorPolicy
metadata:
  name: block-pkg-mgmt-tools-exec
spec:
  severity: 1
  selector:
    matchLabels:
      app: demo-page
  process:
    matchPaths:
    - path: /usr/bin/apt
    - path: /usr/bin/apt-get
  action:
    Block
EOF
```{{exec}}

Deploy KubeArmor-integrator

```
kubectl -n kubearmor-integrator apply -f deploy/manifests/deploy-kubearmor-integrator
kubectl -n kubearmor-integrator wait --for=condition=ready pod --all
kubectl -n kubearmor-integrator get pods -o wide
```{{exec}}

Add kubearmor annotation to demo-page namespace

```
kubectl annotate namespace demo-page kubearmor-policy=enabled
kubectl -n demo-page delete pod -l app=demo-page
```{{exec}}

# Configure Phoenix

Before configuring Phoenix let's confirm that KubeArmor already blocks the package manager usage, however, the pod is not deleted yet because Phoenix configuration is not active:

`kubectl exec -it -n demo-page deployments/demo-page -c nginx -- bash -c "apt update && apt install masscan"`{{exec}}

It will be denied permission enforced by KubeArmor:

```
bash: line 1: /usr/bin/apt: Permission denied
command terminated with exit code 126
```

However, no pod restart was carried out, since Phoenix has not been configured yet.

`kubectl -n demo-page get pods`{{exec}}

Let's activate the MTD configuration to delete pod (serving as an additional layer of security measure) after it gets notification about the block event of KubeArmor.

`kubectl -n demo-page apply -f deploy/manifests/kubearmor-integrator-delete-demo-amtd.yaml`{{exec}}

# Trigger Phoenix

To trigger a KubeArmor event let's execute our previous command again that tries to run the package manager:

`kubectl exec -it -n demo-page deployments/demo-page -c nginx -- bash -c "apt update && apt install masscan"`{{exec}}

It will be denied permission enforced by KubeArmor:

```
bash: line 1: /usr/bin/apt: Permission denied
command terminated with exit code 126
```

Also, this time the pod was deleted (which restarted the application) by Phoenix.
Watch pods to see that the pod where we opened the terminal was deleted (which restarted the application) and that is why the terminal was closed automatically:

`watch kubectl -n demo-page get pods`{{exec}}

To exit from watch loop press `CTRL + C` in the terminal window.

# Clean up this scenario:

`kubectl delete ns demo-page`{{exec}}