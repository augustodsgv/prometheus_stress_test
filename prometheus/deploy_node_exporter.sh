docker run -p 9100:9100 --name node-exporter -d \
  --net="host" \
  --pid="host" \
  -v /proc:/host/proc \
  -v /sys:/host/sys \
  -v /:/rootfs:ro \
  quay.io/prometheus/node-exporter \
  --path.procfs=/host/proc \
  --path.sysfs=/host/sys \
  --path.rootfs=/rootfs