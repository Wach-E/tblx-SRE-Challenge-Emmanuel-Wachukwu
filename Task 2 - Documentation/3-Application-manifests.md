# Task 2 - Manifest Development

The application manifest files consists of a namespace, deployment, service, and ingress.
1. Navigate to **infrastructure/terraform-kubernetes(EKS)** directory.
2. Create a new directory, **manifests** to hold the application manifest files.
3. Navigate into the **manifests** directory and create the manifest files:
```
cd manifests
touch deployment.yaml service.yaml ingress.yaml
```
- **deployment.yaml**: Configuration for namespace and deployment.
- **service.yaml**: Configuration for the ClusterIP service of application deployment.
- **ingress.yaml**: Configuration of ingress rules for routing requests to its required service.
4. Create kubernetes objects using the manifest files:
`kubectl apply -f .`
The above command creates a namespace, `daimler-truck`, a deployment of daimler api application, `daimler`, an internal service, `daimler-svc` and ingress, `daimler-ing`.
N/B: If there is an existing domain, the `spec.hostname` field should be added with the domain as its key. For simplicity, no domain was configured in this task.
5. Confirm all deployed resources are running:
`kubectl get all -n daimler-truck`
6. To obtain the endpoint from the ingress controller:
`watch kubectl get ingress daimler-ing -n daimler-truck`
N/B: It might take 30 - 60 seconds for the address to propagate.
7. When the ingress address gets return, copy it, navigate to a browser and hit:
`ingress_address/api/v1/daimler_truck`
