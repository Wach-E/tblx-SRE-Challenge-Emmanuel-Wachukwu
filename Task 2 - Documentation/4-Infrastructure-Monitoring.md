# Task 2 - Monitoring kubernetes with Prometheus and Grafana

Infrastructure monitoring is very critical to know the behaviour of systems in production. Unlike testing which gives confidence based on how the infrastructure will likely behave in production, monitoring tells what the production behaviour of the system is. Monitoring is one of the core pillars of observability (other are logging, tracing etc). My thoughts about monitoring in a simple form is knowing what is happening in a system and the trend of such occurrence. 

In this documentation, we'll be performing a walkthrough of how to implement system monitoring in the deployed kubernetes cluster from task-2 challenge. My tool of choice for system monitoring is `Prometheus` and for visualization, `Grafana`. Prometheus and Grafana Kubernetes Cluster monitoring provides information on the internal state of the cluster through performance, health and other metrics as well as tracing what, where and how those metrics come to surface through visualizing network usage, resource usage patterns of pods, etc.

To get started with Prometheus and Grafana in Kubernetes, some tools are required to be installed. They have already been setup in the `Setup_Environmennt` workflow but just to be explicit, the following are required:
- Linux environment for access to Kubernetes API server using kubectl (Ubuntu 20.04 was the choice here)
- Kubernetes cluster (EKS has been deployed using terraform)
- Helm package manager (installed during Setup_Environment)
- Kubectl cli (installed during Setup_Environment)


## Installation of kube-prometheus-stack
1. The first and recommended step for adding external resources to the Kubernetes cluster is to create a namespace for easy management and isolation. For this monitoring setup, the `monitoring` namespace will be used:
`kubectl create namespace monitoring`

2. Add prometheus-community repo to collection of helm repos
`helm repo add prometheus-community https://prometheus-community.github.io/helm-charts`

3. Update helm repos
`helm repo update`

4. Create a release of the kube-prometheus-stack helm chart to be used for the cluster
`helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring`

5. To check the status of the release:
`kubectl get pods -n monitoring`

Now the kube-prometheus-stack has been deployed to the EKS cluster, the metrics from the server needs to be accessed through Prometheus port 9090.

## Accessing the Prometheus Instance
To access the prometheus instance, a local/server port, `9090` will be forwarded to the cluster via the Prometheus service.
N/B: All local/server ports mentioned in this section must have inbound allow rule else, it will not work.

1. To obtain the prometheus service, run:
`kubectl get svc -n monitoring -l "release=prometheus"`
Our focus is on the `prometheus-kube-prometheus-prometheus` service with port 9090/TCP
![Prometheus Service Snapshot](https://github.com/Wach-E/tblx-SRE-Challenge-Emmanuel-Wachukwu/blob/develop/Task%202%20-%20Documentation/images/prometheus-service.png)

2. Port-forward traffic from the local/server port to the prometheus service on port 9090 from any host:
`kubectl port-forward --address 0.0.0.0 svc/prometheus-kube-prometheus-prometheus -n monitoring 9090`
N/B: For instances running on public cloud providers, the (--address 0.0.0.0) flag allows external access to the local port of the server’s public IP address.
Navigate to a browser and enter: `http//:server_ip:9090` or `server_dns_endpoint:9090`
The output should look like the image below
![Prometheus Instance Snapshot](https://github.com/Wach-E/tblx-SRE-Challenge-Emmanuel-Wachukwu/blob/develop/Task%202%20-%20Documentation/images/prometheus-instance.png)

Now the prometheus instance works, its time to view the Kubernetes internal state metrics with Prometheus. Press `Ctrl+C` to stop the port-forwarding


## Viewing Prometheus Kubernetes Cluster Internal State Metrics
Viewing the Kubernetes cluster’s internal state metrics is made possible with the kube-state-metrics (KSM) tool. [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics) (KSM) is a simple service that listens to the Kubernetes API server and generates metrics about the state of its objects. The KSM tool is focused on the health of the various kubernetes objects such as nodes, deployments and pods. Hence, the metrics that can be viewed using the KSM tool are node metrics, deployment metrics, and pod metrics.
The KSM tool comes pre-packaged in the kube-prometheus-stack and is deployed automatically with the rest of the monitoring components. 

1. To get the service of the kube-state-metrics, run
`kubectl get svc -n monitoring -l "release=prometheus"`
As observed from the output of the above command, the kube-state-metrics listens on port 8080. To access this kube-state-metrics instance, a local/server port, `8080` will be forwarded to the cluster kube-state-metrics service.

2. Port-forward traffic from the local/server port to the kube-state-metrics service on port 8080 from any host:
`kubectl port-forward --address 0.0.0.0 svc/prometheus-kube-state-metrics -n monitoring 8080`
Navigate to a browser and enter: `http//:server_ip:8080` or `server_dns_endpoint:8080`. Clicking on `metrics` produces a webpage as shown below
The output should look like the image below
![kube-state-metrics Snapshot](https://github.com/Wach-E/tblx-SRE-Challenge-Emmanuel-Wachukwu/blob/develop/Task%202%20-%20Documentation/images/kube-state-metrics-instance.png)

The metrics generated by the KSM tool is exported to the Prometheus instance for visualization. To visualize the metrics from KSM tool in the Prometheus instance, the port forwarding needs to be stopped and the Prometheus targets needs to be analyzed.

## Visualizing the Cluster’s Internal State Metric on Prometheus
The deployment of kube-prometheus-stack using helm chart made the kube-state-metrics scrape data and send to prometheus instance. As a result, CoreDNS, kube-api server, Prometheus operator, and other Kubernetes components have been automatically set up as targets on Prometheus. 
To see this, port-forward to the prometheus instance navigate to `http//:server_ip:9090` or `server_dns_endpoint:9090`, click `Status` dropdown and select `Targets`. The targets in show less form should look like the image below:
![Prometheus Targets Snapshot](https://github.com/Wach-E/tblx-SRE-Challenge-Emmanuel-Wachukwu/blob/develop/Task%202%20-%20Documentation/images/prometheus-targets.png)

Prometheus can be used to graphically visualize the exported metrics as well as run queries on these metrics using a language called **PromQL**. To access such graphs, click the `Graph` navigation tab. Though prometheus has graphical support, it is limited with only one graph option. This is where Grafana comes in.


## Setting up Grafana
Prometheus aggregates the metrics exported by the server components such as node exporter, CoreDNS, etc. while Grafana, collects the aggregated metrics from prometheus and displays them through numerous visualization options. Grafana is part of the kube-prometheus stack deployed earlier. 

1. To access Grafana dashoard, a username and password is required. To obtain these credentials, run:
`kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-user}" | base64 --decode ; echo`
`kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo`
2. Get the Grafana service for port forwarding 
`kubectl get svc -n monitoring`
As observed, Grafance service runs on port 80. Unlike the other services, to access Grafan, a port binding is required to be made with port 80 in the port forwarding:
`kubectl port-forward --address 0.0.0.0 svc/prometheus-grafana -n monitoring 3000:80`
3. Enter the username and password from the decoded values.

Grafana deployed with kube-prometheus stack comes with several dashboards that have been connnected to the prometheus server as its data source. There are two types of metrics available for Kubernetes monitoring; system-level and application-level metrics. Various criterias are used for selecting Grafana dashboards but the most important metrics that should always be monitored are classfied into cluster, node and pod/container metrics. To keep things simple, a pre-created dashboard will be used for monitoring the pods in the `daimler-truck namespace`
In From the left pane, under `Dashboard`, select `Kubernetes / Compute Resources / Cluster` dashboard for cluster monitoring and from here, the other dashboards can be found.

![Kubernetes / Compute Resources / Cluster Dashboard Snapshot](https://github.com/Wach-E/tblx-SRE-Challenge-Emmanuel-Wachukwu/blob/develop/Task%202%20-%20Documentation/images/kubernetes-cluster-grafana-dashboard.png)


## Setting up Prometheus and Grafana for direct reachability
To this point, access to the Prometheus and Grafana instance has been reachable by port forwarding. There is a better approach to expose the services of Prometheus and Grafana. The 3 methods are:
1. Exposing the prometheus and grafana service using NodePort service and accessing through.
2. Exposing the prometheus and grafana service as LoadBalancer service and access it through.
3. Configuring an ingress that routes to configured prometheus and grafana paths. This is the most optimal method but, it requires that a service be created for prometheus and grafana first. This means that a Cluster IP will need to be exposed before creating the ingress. The approach for creating the ingress is the same technique used to create an ingress for the web application is applied. 

Here is a [guide](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/user-guides/exposing-prometheus-and-alertmanager.md) to perform the various configurations.