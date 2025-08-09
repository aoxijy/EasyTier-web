# 使用轻量级基础镜像
FROM alpine:latest

# 安装运行时依赖
RUN apk add --no-cache tzdata tini iptables wireguard-tools bash

# 设置时区
ENV TZ=Asia/Shanghai

# 创建日志目录
RUN mkdir -p /var/log/easytier

# 复制二进制文件和启动脚本
COPY easytier-core /usr/local/bin/
COPY easytier-web-embed /usr/local/bin/
COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

# 复制Web资源
COPY web /var/www/html

# 暴露端口
EXPOSE 11010/tcp   # TCP控制端口
EXPOSE 11010/udp   # UDP数据端口
EXPOSE 11011/udp   # WireGuard UDP
EXPOSE 11011/tcp   # WireGuard TCP
EXPOSE 11012/tcp   # WebSocket
EXPOSE 11211/tcp   # REST API服务器端口
EXPOSE 22020/udp   # 配置服务器端口 (新增)
EXPOSE 8080/tcp    # Web管理界面端口

# 使用tini启动容器
ENTRYPOINT ["/sbin/tini", "--"]

# 使用自定义启动脚本
CMD ["/usr/local/bin/start.sh"]
