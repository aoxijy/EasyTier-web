#!/bin/sh
set -e

# 设置默认值
CORE_PORT=${ET_CORE_PORT:-11010}
WEB_PORT=${ET_WEB_PORT:-8080}
NETWORK_NAME=${ET_NETWORK_NAME:-default}
NETWORK_SECRET=${ET_NETWORK_SECRET:-}

# API主机配置
if [ -n "$ET_API_HOST" ]; then
  API_HOST="$ET_API_HOST"
else
  API_HOST="http://localhost:$CORE_PORT"  # 注意端口改为CORE_PORT
fi

# 启动核心服务
echo "启动 easytier-core..."
/usr/local/bin/easytier-core \
  --rpc-portal "0.0.0.0:$CORE_PORT" \
  --vpn-portal "0.0.0.0:$CORE_PORT" \
  --network-name "$NETWORK_NAME" \
  ${NETWORK_SECRET:+--network-secret "$NETWORK_SECRET"} \
  --listeners "tcp:$CORE_PORT" \
  --listeners "udp:$CORE_PORT" \
  --listeners "wg:11011" &

# 启动Web服务
echo "启动 easytier-web-embed..."
/usr/local/bin/easytier-web-embed \
  --web-server-port "$WEB_PORT" \
  --api-host "$API_HOST" &

# 等待所有服务
wait
