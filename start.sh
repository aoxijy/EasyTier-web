#!/bin/sh
set -e

# ===== 默认端口配置 =====
CORE_PORT=${ET_CORE_PORT:-11010}
WG_PORT=${ET_WG_PORT:-11011}
WS_PORT=${ET_WS_PORT:-11012}
API_PORT=${ET_API_PORT:-11211}
CONFIG_PORT=${ET_CONFIG_PORT:-22020}
WEB_PORT=${ET_WEB_PORT:-8080}

# ===== API 主机配置 =====
# 支持三种配置方式（优先级从高到低）：
# 1. ET_API_HOST 环境变量（显式指定）
# 2. ET_API_HOST_FILE 从文件读取（适合 Kubernetes Secrets）
# 3. 默认值：localhost（容器内通信）
if [ -n "$ET_API_HOST" ]; then
  API_HOST="$ET_API_HOST"
elif [ -n "$ET_API_HOST_FILE" ]; then
  API_HOST=$(cat "$ET_API_HOST_FILE")
else
  API_HOST="localhost"
fi

# ===== 核心服务启动 =====
echo "启动 easytier-core..."
/usr/local/bin/easytier-core \
  --control-port $CORE_PORT \
  --wg-port $WG_PORT \
  --ws-port $WS_PORT \
  --api-port $API_PORT \
  --config-port $CONFIG_PORT &

# ===== Web 服务启动 =====
echo "启动 easytier-web-embed..."
echo "API 服务器: $API_HOST:$API_PORT"
/usr/local/bin/easytier-web-embed \
  --web-port $WEB_PORT \
  --api-host "$API_HOST" \
  --api-port $API_PORT &

# ===== 等待所有服务 =====
wait
