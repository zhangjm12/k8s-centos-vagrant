# If you change, Keep the structure with the dot. [0-9 a-f]
$token = "12345f.0123456789abcdef"
# Total memory of master
$master_memory = 4096
# Increment to have more nodes
$worker_count = 2
# Total memory of nodes
$worker_memory = 4096
# Add Grafana with InfluxDB (work with heapster)
$grafana = false
# Deploy Ingress Controller
$ingress_controller = false
# Local Domain Name
$domain = "cluster.local"
# Deploy Prometheus
$prometheus = false
