# If you change, Keep the structure with the dot. [0-9 a-f]
$token = "12345f.0123456789abcdef"
# Total memory of master
$master_memory = 16384
$master_cpus = 8
# Increment to have more nodes
$worker_count = 3
# Total memory of nodes
$worker_memory = 16384
$worker_cpus = 8
# Add Grafana with InfluxDB (work with heapster)
$grafana = false
# Deploy Ingress Controller
$ingress_controller = false
# Local Domain Name
$domain = "cluster.local"
# Deploy Prometheus
$prometheus = false
