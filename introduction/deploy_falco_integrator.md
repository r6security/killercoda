
Falco-integrator serves as an intergation point between Falco and AMTD Operator as it translates Falco warnings and alerts to trigger the AMTD Operator to carry out specific actions in response.

Deploy `Falco-integrator`:

```
kubectl apply -n falco-integrator -f ./deploy-falco-integrator
kubectl -n falco-integrator wait --for=condition=ready pod --all
kubectl -n falco-integrator get pods
```{{exec}}

Load configuration to Falco that fits for the demo use-cases:
```
kubectl delete configmap -n falco falco
kubectl create configmap -n falco falco --from-file ./config-falco/falco.yaml
kubectl create configmap -n falco falco-rules --from-file ./config-falco/falco-rules.yaml
kubectl patch -n falco daemonsets.apps falco --patch-file ./config-falco/falco-patch.yaml
kubectl delete pods -n falco -l app.kubernetes.io/name=falco
kubectl -n falco get pods
```{{exec}}

