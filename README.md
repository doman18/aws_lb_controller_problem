
Based on https://github.com/antonputra/tutorials/tree/main/lessons/112/terraform

1. Reorganized resources placement
2. Added rbs driver (for prometheus and grafana)
2. Added k8s provider and monitoring resources

To replicate problem
```
terraform init
terraform apply # most probably you will get prometheus error 

terraform destroy
# resource kubernetes_ingress_v1.grafana_ingress would not be destroyed
```

# additional
to get kubeconfig for created cluster
```
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```
