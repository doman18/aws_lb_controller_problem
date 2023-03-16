
# Intro
Based on https://github.com/antonputra/tutorials/tree/main/lessons/112/terraform

1. Reorganized resources placement
2. Added rbs driver (for prometheus and grafana)
2. Added k8s provider and monitoring resources

# To replicate problem
1. Create all resources  
```
terraform init
terraform apply # most probably you will get prometheus error, just repeat terraform apply
```

2. Get the kubeconfig for your cluster
```
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

3. Attempt to destroy your cluster
```
terraform destroy
```
resource kubernetes_ingress_v1.grafana_ingress would not be destroyed. Both `grafana-ingress` ingress and `monitoring` namespace will have finalizers set
```
kubectl -n monitoring get ingress -o=yaml
apiVersion: v1
items:
- apiVersion: networking.k8s.io/v1
  kind: Ingress
  metadata:
    annotations:
      alb.ingress.kubernetes.io/healthcheck-path: /login
      alb.ingress.kubernetes.io/load-balancer-name: grafana-ingress
      alb.ingress.kubernetes.io/target-type: ip
    creationTimestamp: "2023-03-16T12:09:05Z"
    deletionGracePeriodSeconds: 0
    deletionTimestamp: "2023-03-16T12:19:22Z"
    finalizers:
    - ingress.k8s.aws/resources
    generation: 2
    name: grafana
    namespace: monitoring
    resourceVersion: "8809"
    uid: 31270854-05b1-4aa6-9480-2f23646ea932
  spec:
    ingressClassName: alb
    rules:
    - host: grafana.djangoapp.lan
      http:
        paths:
        - backend:
            service:
              name: grafana
              port:
                number: 80
          path: /*
          pathType: ImplementationSpecific
  status:
    loadBalancer:
      ingress:
      - hostname: internal-grafana-ingress-85476811.us-east-1.elb.amazonaws.com
kind: List
metadata:
  resourceVersion: ""

```

# steps to manually destroy resources
## grafana ingress
```
kubectl patch ingress grafana-ingress -nmonitoring -p '{"metadata":{"finalizers":[]}}' --type=merge
```
## monitoring namespace
on one terminal
```
kubectl proxy
```
on second terminal
```
kubectl get namespace monitoring -o json > tmp.json
nano tmp.json # delete finalizer
curl -k -H "Content-Type: application/json" -X PUT --data-binary @tmp.json http://127.0.0.1:8001/api/v1/namespaces/monitoring/finalize
```
