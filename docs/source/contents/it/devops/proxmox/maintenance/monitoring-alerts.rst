==================
Monitoring & Alerts
==================

.. highlight:: console

System monitoring, alerting, and performance tracking for Proxmox infrastructure.

📊 Monitoring Overview
=====================

Comprehensive monitoring strategy:

- **System Metrics**: CPU, memory, disk, network usage
- **Service Health**: VM/container status and performance
- **Storage Monitoring**: Disk health, ZFS status, backup verification
- **Network Monitoring**: Connectivity, bandwidth, latency
- **Alert Management**: Proactive notifications for issues

🔧 Built-in Proxmox Monitoring
=============================

Proxmox Web Interface Monitoring
-------------------------------

**System Status Dashboard**:
- Node summary with resource usage
- VM/container status overview
- Storage utilization
- Network interface statistics

**Performance Graphs**:
- CPU usage over time
- Memory utilization trends
- Network traffic patterns
- Storage I/O statistics

Command Line Monitoring
-----------------------

.. code-block:: bash

   # System resource usage
   htop
   iotop
   iftop
   
   # Proxmox-specific commands
   pvesh get /nodes/$(hostname)/status
   pvesh get /nodes/$(hostname)/storage
   pvesh get /cluster/resources
   
   # VM/Container status
   qm list
   pct list
   
   # Storage status
   zpool status
   df -h

📈 Advanced Monitoring Stack
===========================

Prometheus + Grafana Setup
--------------------------

**Deploy monitoring stack in LXC container**:

.. code-block:: bash

   # Create monitoring container
   pct create 300 \
     local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst \
     --hostname monitoring \
     --memory 4096 \
     --cores 2 \
     --net0 name=eth0,bridge=vmbr0,ip=192.168.1.50/24,gw=192.168.1.1 \
     --storage local-lvm \
     --rootfs local-lvm:20

**Install Prometheus**:

.. code-block:: bash

   # Update system
   apt update && apt upgrade -y
   
   # Create prometheus user
   useradd --no-create-home --shell /bin/false prometheus
   
   # Download and install Prometheus
   cd /tmp
   wget https://github.com/prometheus/prometheus/releases/download/v2.40.0/prometheus-2.40.0.linux-amd64.tar.gz
   tar xvf prometheus-2.40.0.linux-amd64.tar.gz
   
   # Install binaries
   cp prometheus-2.40.0.linux-amd64/prometheus /usr/local/bin/
   cp prometheus-2.40.0.linux-amd64/promtool /usr/local/bin/
   
   # Set permissions
   chown prometheus:prometheus /usr/local/bin/prometheus
   chown prometheus:prometheus /usr/local/bin/promtool
   
   # Create directories
   mkdir /etc/prometheus
   mkdir /var/lib/prometheus
   chown prometheus:prometheus /etc/prometheus
   chown prometheus:prometheus /var/lib/prometheus

**Prometheus Configuration**:

.. code-block:: yaml

   # /etc/prometheus/prometheus.yml
   global:
     scrape_interval: 15s
     evaluation_interval: 15s
   
   rule_files:
     - "alert_rules.yml"
   
   alerting:
     alertmanagers:
       - static_configs:
           - targets:
             - localhost:9093
   
   scrape_configs:
     - job_name: 'prometheus'
       static_configs:
         - targets: ['localhost:9090']
   
     - job_name: 'node-exporter'
       static_configs:
         - targets: ['192.168.1.240:9100']  # Proxmox host
   
     - job_name: 'pve-exporter'
       static_configs:
         - targets: ['192.168.1.240:9221']  # Proxmox PVE exporter

**Install Grafana**:

.. code-block:: bash

   # Add Grafana repository
   wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
   echo "deb https://packages.grafana.com/oss/deb stable main" > /etc/apt/sources.list.d/grafana.list
   
   # Install Grafana
   apt update
   apt install grafana
   
   # Enable and start Grafana
   systemctl enable grafana-server
   systemctl start grafana-server

Node Exporter Setup
-------------------

**Install on Proxmox host**:

.. code-block:: bash

   # Create node_exporter user
   useradd --no-create-home --shell /bin/false node_exporter
   
   # Download and install
   cd /tmp
   wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz
   tar xvf node_exporter-1.5.0.linux-amd64.tar.gz
   cp node_exporter-1.5.0.linux-amd64/node_exporter /usr/local/bin/
   chown node_exporter:node_exporter /usr/local/bin/node_exporter

**Create systemd service**:

.. code-block:: bash

   cat > /etc/systemd/system/node_exporter.service << 'EOF'
   [Unit]
   Description=Node Exporter
   Wants=network-online.target
   After=network-online.target
   
   [Service]
   User=node_exporter
   Group=node_exporter
   Type=simple
   ExecStart=/usr/local/bin/node_exporter
   
   [Install]
   WantedBy=multi-user.target
   EOF
   
   # Enable and start service
   systemctl daemon-reload
   systemctl enable node_exporter
   systemctl start node_exporter

PVE Exporter for Proxmox
------------------------

.. code-block:: bash

   # Install PVE exporter
   pip3 install prometheus-pve-exporter
   
   # Create configuration
   cat > /etc/prometheus/pve.yml << 'EOF'
   default:
     user: monitoring@pve
     password: your-monitoring-password
     verify_ssl: false
   EOF
   
   # Create systemd service
   cat > /etc/systemd/system/pve-exporter.service << 'EOF'
   [Unit]
   Description=Proxmox VE Exporter
   
   [Service]
   ExecStart=/usr/local/bin/pve_exporter --config.file /etc/prometheus/pve.yml
   Restart=always
   
   [Install]
   WantedBy=multi-user.target
   EOF
   
   systemctl enable pve-exporter
   systemctl start pve-exporter

🚨 Alert Configuration
=====================

Alertmanager Setup
-----------------

.. code-block:: bash

   # Download and install Alertmanager
   cd /tmp
   wget https://github.com/prometheus/alertmanager/releases/download/v0.25.0/alertmanager-0.25.0.linux-amd64.tar.gz
   tar xvf alertmanager-0.25.0.linux-amd64.tar.gz
   cp alertmanager-0.25.0.linux-amd64/alertmanager /usr/local/bin/
   cp alertmanager-0.25.0.linux-amd64/amtool /usr/local/bin/

**Alertmanager Configuration**:

.. code-block:: yaml

   # /etc/prometheus/alertmanager.yml
   global:
     smtp_smarthost: 'smtp.gmail.com:587'
     smtp_from: 'alerts@yourdomain.com'
     smtp_auth_username: 'alerts@yourdomain.com'
     smtp_auth_password: 'your-app-password'
   
   route:
     group_by: ['alertname']
     group_wait: 10s
     group_interval: 10s
     repeat_interval: 1h
     receiver: 'web.hook'
   
   receivers:
   - name: 'web.hook'
     email_configs:
     - to: 'admin@yourdomain.com'
       subject: 'Proxmox Alert: {{ .GroupLabels.alertname }}'
       body: |
         {{ range .Alerts }}
         Alert: {{ .Annotations.summary }}
         Description: {{ .Annotations.description }}
         {{ end }}

Alert Rules
----------

.. code-block:: yaml

   # /etc/prometheus/alert_rules.yml
   groups:
   - name: proxmox_alerts
     rules:
     - alert: HighCPUUsage
       expr: 100 - (avg by(instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
       for: 5m
       labels:
         severity: warning
       annotations:
         summary: "High CPU usage on {{ $labels.instance }}"
         description: "CPU usage is above 80% for more than 5 minutes"
   
     - alert: HighMemoryUsage
       expr: (node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100 > 90
       for: 5m
       labels:
         severity: critical
       annotations:
         summary: "High memory usage on {{ $labels.instance }}"
         description: "Memory usage is above 90%"
   
     - alert: DiskSpaceLow
       expr: (node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100 < 10
       for: 5m
       labels:
         severity: critical
       annotations:
         summary: "Low disk space on {{ $labels.instance }}"
         description: "Disk space is below 10% on {{ $labels.mountpoint }}"
   
     - alert: VMDown
       expr: pve_up == 0
       for: 2m
       labels:
         severity: critical
       annotations:
         summary: "VM/Container is down"
         description: "{{ $labels.instance }} has been down for more than 2 minutes"

📱 Notification Channels
=======================

Email Notifications
------------------

**Configure SMTP in Proxmox**:

1. **Datacenter** → **Notifications**
2. **Add** → **SMTP Endpoint**
3. Configure SMTP settings:
   - Server: smtp.gmail.com
   - Port: 587
   - Username/Password: Your credentials
   - Enable TLS

**Test email notifications**:

.. code-block:: bash

   # Test email from command line
   echo "Test message" | mail -s "Proxmox Test" admin@yourdomain.com

Slack Integration
----------------

.. code-block:: yaml

   # Add to alertmanager.yml
   receivers:
   - name: 'slack-notifications'
     slack_configs:
     - api_url: 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK'
       channel: '#alerts'
       title: 'Proxmox Alert'
       text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'

Discord Integration
------------------

.. code-block:: bash

   # Discord webhook script
   cat > /usr/local/bin/discord-alert.sh << 'EOF'
   #!/bin/bash
   
   WEBHOOK_URL="https://discord.com/api/webhooks/YOUR/WEBHOOK/URL"
   MESSAGE="$1"
   
   curl -H "Content-Type: application/json" \
        -X POST \
        -d "{\"content\": \"🚨 Proxmox Alert: $MESSAGE\"}" \
        "$WEBHOOK_URL"
   EOF
   
   chmod +x /usr/local/bin/discord-alert.sh

📊 Custom Monitoring Scripts
===========================

System Health Monitor
--------------------

.. code-block:: bash

   cat > /usr/local/bin/system-health.sh << 'EOF'
   #!/bin/bash
   
   # System Health Monitoring Script
   
   ALERT_EMAIL="admin@yourdomain.com"
   CPU_THRESHOLD=80
   MEMORY_THRESHOLD=90
   DISK_THRESHOLD=90
   
   log() {
       echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
   }
   
   send_alert() {
       local subject="$1"
       local message="$2"
       echo "$message" | mail -s "$subject" "$ALERT_EMAIL"
       log "ALERT SENT: $subject"
   }
   
   # Check CPU usage
   cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')
   if (( $(echo "$cpu_usage > $CPU_THRESHOLD" | bc -l) )); then
       send_alert "High CPU Usage Alert" "CPU usage is ${cpu_usage}% (threshold: ${CPU_THRESHOLD}%)"
   fi
   
   # Check memory usage
   memory_usage=$(free | grep Mem | awk '{printf("%.1f", ($3/$2) * 100.0)}')
   if (( $(echo "$memory_usage > $MEMORY_THRESHOLD" | bc -l) )); then
       send_alert "High Memory Usage Alert" "Memory usage is ${memory_usage}% (threshold: ${MEMORY_THRESHOLD}%)"
   fi
   
   # Check disk usage
   df -h | awk 'NR>1 {print $5 " " $6}' | while read output; do
       usage=$(echo $output | awk '{print $1}' | sed 's/%//')
       partition=$(echo $output | awk '{print $2}')
       if [ $usage -ge $DISK_THRESHOLD ]; then
           send_alert "Low Disk Space Alert" "Disk usage on $partition is ${usage}% (threshold: ${DISK_THRESHOLD}%)"
       fi
   done
   
   # Check ZFS pool health
   if command -v zpool >/dev/null 2>&1; then
       zpool_status=$(zpool status | grep -E "DEGRADED|FAULTED|OFFLINE|UNAVAIL")
       if [ -n "$zpool_status" ]; then
           send_alert "ZFS Pool Health Alert" "ZFS pool issues detected: $zpool_status"
       fi
   fi
   
   log "System health check completed"
   EOF
   
   chmod +x /usr/local/bin/system-health.sh

Service Monitoring
-----------------

.. code-block:: bash

   cat > /usr/local/bin/service-monitor.sh << 'EOF'
   #!/bin/bash
   
   # Service Monitoring Script
   
   SERVICES=(
       "pveproxy"
       "pvedaemon"
       "pve-cluster"
       "docker"
   )
   
   ALERT_EMAIL="admin@yourdomain.com"
   
   log() {
       echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
   }
   
   send_alert() {
       local subject="$1"
       local message="$2"
       echo "$message" | mail -s "$subject" "$ALERT_EMAIL"
       log "ALERT SENT: $subject"
   }
   
   for service in "${SERVICES[@]}"; do
       if ! systemctl is-active --quiet "$service"; then
           send_alert "Service Down Alert" "Service $service is not running on $(hostname)"
           log "ERROR: Service $service is down"
           
           # Attempt to restart service
           systemctl restart "$service"
           sleep 5
           
           if systemctl is-active --quiet "$service"; then
               send_alert "Service Recovered" "Service $service has been restarted successfully on $(hostname)"
               log "INFO: Service $service restarted successfully"
           else
               send_alert "Service Restart Failed" "Failed to restart service $service on $(hostname)"
               log "ERROR: Failed to restart service $service"
           fi
       else
           log "OK: Service $service is running"
       fi
   done
   EOF
   
   chmod +x /usr/local/bin/service-monitor.sh

⏰ Monitoring Schedule
====================

Cron Configuration
-----------------

.. code-block:: bash

   # Edit root crontab
   crontab -e
   
   # Add monitoring schedules
   # System health check every 5 minutes
   */5 * * * * /usr/local/bin/system-health.sh
   
   # Service monitoring every 2 minutes
   */2 * * * * /usr/local/bin/service-monitor.sh
   
   # Backup verification daily at 6 AM
   0 6 * * * /usr/local/bin/backup-verify.sh
   
   # Generate daily status report at 8 AM
   0 8 * * * /usr/local/bin/backup-status.sh | mail -s "Daily Proxmox Status" admin@yourdomain.com

📱 Dashboard Setup
=================

Grafana Dashboard Configuration
------------------------------

**Import Proxmox Dashboard**:

1. **Access Grafana**: http://monitoring-ip:3000
2. **Login**: admin/admin (change password)
3. **Add Prometheus data source**: http://localhost:9090
4. **Import dashboard**: Use dashboard ID 10347 for Proxmox

**Custom Dashboard Panels**:
- CPU usage by VM/container
- Memory utilization trends
- Storage I/O performance
- Network traffic patterns
- Backup job status
- Alert summary

Web-based Status Page
--------------------

.. code-block:: bash

   # Simple status page generator
   cat > /usr/local/bin/generate-status.sh << 'EOF'
   #!/bin/bash
   
   STATUS_FILE="/var/www/html/status.html"
   
   cat > "$STATUS_FILE" << EOL
   <!DOCTYPE html>
   <html>
   <head>
       <title>Proxmox Status</title>
       <meta http-equiv="refresh" content="60">
   </head>
   <body>
       <h1>Proxmox Infrastructure Status</h1>
       <p>Last updated: $(date)</p>
       
       <h2>System Resources</h2>
       <pre>$(df -h)</pre>
       
       <h2>Running VMs</h2>
       <pre>$(qm list)</pre>
       
       <h2>Running Containers</h2>
       <pre>$(pct list)</pre>
       
       <h2>Recent Alerts</h2>
       <pre>$(tail -20 /var/log/syslog | grep -i alert || echo "No recent alerts")</pre>
   </body>
   </html>
   EOL
   EOF
   
   chmod +x /usr/local/bin/generate-status.sh

📋 Monitoring Checklist
=======================

Daily Monitoring Tasks:

- [ ] **Review dashboard** for anomalies
- [ ] **Check alert notifications** and resolve issues
- [ ] **Verify backup completion** status
- [ ] **Monitor resource usage** trends
- [ ] **Check service health** status

Weekly Monitoring Tasks:

- [ ] **Review performance trends** over the week
- [ ] **Update alert thresholds** if needed
- [ ] **Test notification channels**
- [ ] **Clean up old monitoring data**
- [ ] **Review and tune** monitoring rules

Monthly Monitoring Tasks:

- [ ] **Capacity planning** based on trends
- [ ] **Update monitoring tools** and dashboards
- [ ] **Review alert effectiveness**
- [ ] **Document any monitoring changes**
- [ ] **Test disaster recovery** monitoring

🚨 Troubleshooting
=================

Common Monitoring Issues
-----------------------

**Prometheus Not Scraping**:

.. code-block:: bash

   # Check Prometheus targets
   curl http://localhost:9090/api/v1/targets
   
   # Check service status
   systemctl status prometheus
   
   # Check configuration
   promtool check config /etc/prometheus/prometheus.yml

**Grafana Connection Issues**:

.. code-block:: bash

   # Check Grafana logs
   journalctl -u grafana-server
   
   # Test data source connection
   curl http://localhost:9090/api/v1/query?query=up

**Alert Not Firing**:

.. code-block:: bash

   # Check alert rules
   promtool check rules /etc/prometheus/alert_rules.yml
   
   # Check Alertmanager status
   systemctl status alertmanager

📚 Additional Resources
======================

- `Prometheus Documentation <https://prometheus.io/docs/>`__
- `Grafana Documentation <https://grafana.com/docs/>`__
- `Proxmox Monitoring Best Practices <https://pve.proxmox.com/wiki/Performance_Tweaks>`__
- `Node Exporter Metrics <https://github.com/prometheus/node_exporter>`__
