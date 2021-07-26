# Monitoring 
Prometheus is an open source monitoring system for which Grafana provides out-of-the-box support. 
Grafana supports querying Prometheus.

- The main.tf file provides the detailed information about ingress and egress operations.
- In the user-data.sh file you'll get a deep insight of the configurations being made in order to enable Prometheus and Grafana.
- Thereby script mentions the various executions 

### Grafana Intallation and desired configurations done as follows:

- `sudo yum install -y grafana`

- `sudo systemctl daemon-reload`

- `sudo systemctl start grafana-server`

- `sudo systemctl status grafana-server`

- `sudo systemctl enable grafana-server.service`

- Refer the user-data.sh file for more information...
