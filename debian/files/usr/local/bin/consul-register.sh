#!/usr/bin/env bash
export SERVICE_ADDRESS=$(hostname -I | awk '{print $1}')
export SERVICE_NAME=$(hostname)
export SERVICE_PORT=22
export CONSUL_HTTP_ADDR=10.0.30.11:8500
export SERVICE_PATH="/etc/consul.d/consul-service.json"

BOOTSTRAP_SERVICE=$(cat <<EOF
{
	"service": {
		"id": "$SERVICE_NAME",
		"name": "$SERVICE_NAME",
		"port": $SERVICE_PORT,
		"address": "$SERVICE_ADDRESS",
		"meta": {
			"pve_node_name": "$PVE_NODE_NAME"
		},
		"checks": [
			{
				"id": "${SERVICE_NAME}-ssh",
				"name": "SSH TCP on port ${SERVICE_PORT}",
				"tcp": "${SERVICE_ADDRESS}:${SERVICE_PORT}",
				"interval": "20s",
				"timeout": "2s"
			}
		]
	}
}
EOF
)

if [ ! -f "$SERVICE_PATH" ]; then
	echo "Consul service definition does not exists, creating..."
	echo "$BOOTSTRAP_SERVICE" > "$SERVICE_PATH"
fi

consul services register "$SERVICE_PATH"
