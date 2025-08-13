#!/bin/sh
set -e

# 设置默认端口
CORE_PORT=${ET_CORE_PORT:-11010}
API_PORT=${ET_API_PORT:-11211}
CONFIG_PORT=${ET_CONFIG_PORT:-22020}
WEB_PORT=${ET_WEB_PORT:-8080}

# API主机配置
if [ -n "$ET_API_HOST" ]; then
  API_HOST="$ET_API_HOST"
else
  API_HOST="http://localhost:$API_PORT"
fi

# 启动核心服务 - 使用新的参数格式
echo "启动 easytier-core..."
/usr/local/bin/easytier-core \
  --rpc-portal "0.0.0.0:$CORE_PORT" \
  --listeners "tcp:$CORE_PORT" \
  --listeners "udp:$CORE_PORT" \
  --listeners "wg:11011" \
  --api-port "$API_PORT" \
  --config-port "$CONFIG_PORT" &

# 启动Web服务
echo "启动 easytier-web-embed..."
/usr/local/bin/easytier-web-embed \
  --web-server-port "$WEB_PORT" \
  --api-host "$API_HOST" \
  --api-server-port "$API_PORT" \
  --config-server-port "$CONFIG_PORT" &

# 等待所有服务
wait
