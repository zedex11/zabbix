############Install docker and docker compose

sudo yum install -y yum-utils
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

sudo yum install docker-ce docker-ce-cli containerd.io -y
sudo systemctl start docker
sudo curl -L "https://github.com/docker/compose/releases/download/1.27.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose




###########Create docker compose file#################

sudo cat<<EOF>docker-compose.yaml
version: '3.2'
services:
  prometheus:
    image: prom/prometheus:latest
    volumes:
      - ./prometheus:/etc/prometheus/
    command:
      - --config.file=/etc/prometheus/prometheus.yml
    ports:
      - 9090:9090
    restart: always
  node-exporter:
    image: prom/node-exporter
    ports:
      - 9100:9100
    restart: always
    deploy:
      mode: global
  blackbox:
    image: bitnami/blackbox-exporter:latest
    ports:
      - 9115:9115
  grafana:
    image: grafana/grafana
    depends_on:
      - prometheus
    ports:
      - 3000:3000
    restart: always
EOF


#############Create config for prometheus######################

#IP_remote - input terraform valiable; getting IP remote node-exporter

IP_self=`ip addr list eth0 | grep "  inet " | head -n 1 | cut -d " " -f 6 | cut -d / -f 1`     #Getting self IP addres
sudo mkdir prometheus
sudo cat<<EOF>./prometheus/prometheus.yml
scrape_configs:
  - job_name: node
    scrape_interval: 5s
    static_configs:
    - targets: ['$IP_self:9100','${IP_remote}:9100']

  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_2xx]  # Look for a HTTP 200 response.
    static_configs:
      - targets:
        - http://onliner.by    # Target to probe with http.
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: $IP_self:9115  # The blackbox exporter's real hostname:port.
EOF



######running services########

docker-compose up -d