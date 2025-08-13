#!/bin/sh
set -e

# 设置默认端口变量
CORE_PORT=${ET_CORE_PORT:-11010}
WG_PORT=${ET_WG_PORT:-11011}
WS_PORT=${ET_WS_PORT:-11012}
API_PORT=${ET_API_PORT:-11211}
CONFIG_PORT=${ET_CONFIG_PORT:-22020}
WEB_PORT=${ET_WEB_PORT:-8080}

# 启动核心服务（带端口参数）
/usr/local/bin/easytier-core \
  --control-port $CORE_PORT \
  --wg-port $WG_PORT \
  --ws-port $WS_PORT \
  --api-port $API_PORT \
  --config-port $CONFIG_PORT &

# 启动Web服务（带端口参数）
/usr/local/bin/easytier-web-embed \
  --web-port $WEB_PORT \
  --api-server "http://localhost:$API_PORT" &

wait
