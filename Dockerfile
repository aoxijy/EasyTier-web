#!/bin/sh
set -x  # 启用详细日志

# ===== 默认端口配置 =====
CORE_PORT=${ET_CORE_PORT:-11010}
WG_PORT=${ET_WG_PORT:-11011}
WS_PORT=${ET_WS_PORT:-11012}
API_PORT=${ET_API_PORT:-11211}
CONFIG_PORT=${ET_CONFIG_PORT:-22020}
WEB_PORT=${ET_WEB_PORT:-8080}

# ===== API 主机配置 =====
if [ -n "$ET_API_HOST" ]; then
  API_HOST="$ET_API_HOST"
elif [ -n "$ET_API_HOST_FILE" ]; then
  API_HOST=$(cat "$ET_API_HOST_FILE")
else
  API_HOST="localhost"
fi

# 打印环境变量
echo "===== 环境变量 ====="
env | grep ET_
echo "===================="

# ===== 核心服务启动 =====
echo "启动 easytier-core..."
CMD_CORE="/usr/local/bin/easytier-core --rpc-portal \"0.0.0.0:$CORE_PORT\" --wg-port \"$WG_PORT\" --ws-port \"$WS_PORT\" --api-port \"$API_PORT\" --config-port \"$CONFIG_PORT\""
echo "执行命令: $CMD_CORE"
eval $CMD_CORE &

# ===== Web 服务启动 =====
echo "启动 easytier-web-embed..."
echo "API 服务器: $API_HOST:$API_PORT"
CMD_WEB="/usr/local/bin/easytier-web-embed --web-server-port \"$WEB_PORT\" --api-host \"$API_HOST\" --api-port \"$API_PORT\""
echo "执行命令: $CMD_WEB"
eval $CMD_WEB &

# ===== 等待所有服务 =====
wait
