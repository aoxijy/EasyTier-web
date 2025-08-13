#!/bin/sh
set -e

# 设置默认端口
CONFIG_SERVER_PORT=${ET_CONFIG_PORT:-22020}
API_SERVER_PORT=${ET_API_PORT:-11211}
WEB_SERVER_PORT=${ET_WEB_PORT:-8080}

# API主机配置
if [ -n "$ET_API_HOST" ]; then
  API_HOST="$ET_API_HOST"
elif [ -n "$ET_API_HOST_FILE" ]; then
  API_HOST=$(cat "$ET_API_HOST_FILE")
else
  API_HOST="localhost"
fi

# 启动核心服务
echo "启动 easytier-core..."
/usr/local/bin/easytier-core \
  --rpc-portal "0.0.0.0:${ET_CORE_PORT:-11010}" \
  --wg-port "${ET_WG_PORT:-11011}" \
  --ws-port "${ET_WS_PORT:-11012}" \
  --api-port "$API_SERVER_PORT" \
  --config-port "$CONFIG_SERVER_PORT" &

# 启动Web服务
echo "启动 easytier-web-embed..."
/usr/local/bin/easytier-web-embed \
  --web-server-port "$WEB_SERVER_PORT" \
  --api-host "$API_HOST" \
  --api-server-port "$API_SERVER_PORT" \
  --config-server-port "$CONFIG_SERVER_PORT" \
  --config-server-protocol "${ET_CONFIG_PROTOCOL:-udp}" &

# 等待所有服务
wait
