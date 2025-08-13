#!/bin/sh
set -e

# 设置默认值
CORE_PORT=${ET_CORE_PORT:-11010}
WG_PORT=${ET_WG_PORT:-11011}
WS_PORT=${ET_WS_PORT:-11012}
CONFIG_PORT=${ET_CONFIG_PORT:-22020}
API_PORT=${ET_API_PORT:-11211}
WEB_PORT=${ET_WEB_PORT:-8080}
NETWORK_NAME=${ET_NETWORK_NAME:-default}
NETWORK_SECRET=${ET_NETWORK_SECRET:-}
CONFIG_PROTOCOL=${ET_CONFIG_PROTOCOL:-udp}
DB_PATH=${ET_DB:-/opt/ct/easytier.db}

# API主机配置
if [ -n "$ET_API_HOST" ]; then
  API_HOST="$ET_API_HOST"
else
  API_HOST="http://localhost:$API_PORT"
fi

# 创建数据库目录
mkdir -p "$(dirname "$DB_PATH")"

# 启动核心服务
echo "启动 easytier-core..."
args="--rpc-portal 0.0.0.0:$CORE_PORT"
args="$args --vpn-portal 0.0.0.0:$CORE_PORT"
args="$args --network-name \"$NETWORK_NAME\""
args="$args --listeners tcp:$CORE_PORT"
args="$args --listeners udp:$CORE_PORT"
args="$args --listeners wg:$WG_PORT"
args="$args --listeners ws:$WS_PORT"

# 添加可选参数
if [ -n "$NETWORK_SECRET" ]; then
  args="$args --network-secret \"$NETWORK_SECRET\""
fi
if [ -n "$ET_CONFIG_PROTOCOL" ]; then
  args="$args --config-protocol \"$CONFIG_PROTOCOL\""
fi
if [ -n "$ET_EXTERNAL_NODE" ]; then
  args="$args --external-node \"$ET_EXTERNAL_NODE\""
fi
if [ -n "$ET_PROXY_NETWORKS" ]; then
  args="$args --proxy-networks \"$ET_PROXY_NETWORKS\""
fi
if [ -n "$ET_EXIT_NODES" ]; then
  args="$args --exit-nodes $ET_EXIT_NODES"
fi
if [ -n "$ET_ENABLE_EXIT_NODE" ]; then
  args="$args --enable-exit-node"
fi
if [ -n "$ET_SOCKS5" ]; then
  args="$args --socks5 $ET_SOCKS5"
fi
if [ -n "$ET_COMPRESSION" ]; then
  args="$args --compression $ET_COMPRESSION"
fi
if [ -n "$ET_PRIVATE_MODE" ]; then
  args="$args --private-mode"
fi

# 设置数据库路径环境变量
export EASYTIER_DB_PATH="$DB_PATH"

# 执行命令
eval "/usr/local/bin/easytier-core $args &"

# 启动Web服务
echo "启动 easytier-web-embed..."
web_args="--web-server-port $WEB_PORT"
web_args="$web_args --api-server-port $API_PORT"
web_args="$web_args --config-server-port $CONFIG_PORT"
web_args="$web_args --config-server-protocol $CONFIG_PROTOCOL"
web_args="$web_args --api-host \"$API_HOST\""
web_args="$web_args --db \"$DB_PATH\""

# 添加可选参数
if [ -n "$ET_GEOIP_DB" ]; then
  web_args="$web_args --geoip-db \"$ET_GEOIP_DB\""
fi

# 执行命令
eval "/usr/local/bin/easytier-web-embed $web_args &"

# 等待所有服务
wait
