# If you change, Keep the structure with the dot. [0-9 a-f]
$token = "12345f.0123456789abcdef"
# Total memory of master
$master_memory = 2560
# Increment to have more nodes
$worker_count = 0
# Total memory of nodes
$worker_memory = 1536
# Add Grafana with InfluxDB (work with heapster)
$grafana = true
# Deploy Ingress Controller
$ingress_controller = true
# Local Domain Name
$domain = "devops.kubernetes.my"
# Deploy Prometheus
$prometheus = false