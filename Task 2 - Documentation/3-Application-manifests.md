The application manifest files consists of a namespacedeployment, service, and ingress.
A directory, `manifests` created in `infrastructure/terraform-kubernetes(EKS)/` holds the `deployment.yaml`, `service.yaml` and `ingress.yaml` files.
- deployment.yaml: This contains the namespace and the deployment configuration.
- service.yaml: Configuration for the ClusterIP service of application deployment.
- ingress.yaml: Configuration of ingress rules for routing requests to its required service.

In the manifests directory:
1. Create kubernetes objects using the manifest files:
`kubectl apply -f .`
The above command creates a namespace, `daimler-truck`, a deployment of daimler api application, `daimler`, an internal service, `daimler-svc` and ingress, `daimler-ing`.
N/B: If their is an existing domain, the `spec.hostname` field should be present. For simplicity, no domain was configured in this task.
2. Confirm all resources are running:
`kubectl get all -n daimler-truck`
3. To obtain the endpoint from the ingress controller:
`watch kubectl get ingress daimler-ing -n daimler-truck`
N/B: It might take 30 - 60 seconds for the address to propagate.
4. When the the address is provided, navigate to a browser and hit:
`ingress_address/api/v1/daimler_truck`