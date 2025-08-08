# 使用轻量级基础镜像
FROM alpine:latest

# 安装运行时依赖
RUN apk add --no-cache tzdata tini iptables wireguard-tools

# 设置时区
ENV TZ=Asia/Shanghai

# 复制二进制和Web资源
COPY easytier-core /usr/local/bin/
COPY web /var/www/html  # Web界面静态文件

# 暴露端口
EXPOSE 11010/tcp  # TCP控制端口
EXPOSE 11010/udp  # UDP数据端口
EXPOSE 11011/udp  # WireGuard UDP
EXPOSE 11011/tcp  # WebSocket
EXPOSE 11012/tcp  # Secure WebSocket
EXPOSE 8080/tcp   # Web管理界面端口

# 设置入口点
ENTRYPOINT ["/sbin/tini", "--", "easytier-core"]
