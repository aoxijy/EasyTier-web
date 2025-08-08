# 第一阶段：下载对应架构的二进制
ARG BUILD_VERSION
ARG TARGETARCH

FROM alpine:latest AS downloader

# 安装依赖
RUN apk add --no-cache wget

# 根据目标架构设置下载路径
RUN case "${TARGETARCH}" in \
    "amd64") ARCH="amd64" ;; \
    "arm64") ARCH="aarch64" ;; \
    *) echo "Unsupported architecture: ${TARGETARCH}"; exit 1 ;; \
    esac

# 下载官方发布包
RUN wget -O /tmp/easytier.tar.gz \
    "https://github.com/EasyTier/EasyTier/releases/download/${BUILD_VERSION}/easytier-${BUILD_VERSION}-linux-${ARCH}.tar.gz"

# 解压文件
RUN tar -xzf /tmp/easytier.tar.gz -C /tmp

# 第二阶段：构建最终镜像
FROM alpine:latest

# 安装运行时依赖
RUN apk add --no-cache tzdata tini iptables wireguard-tools

# 设置时区
ENV TZ=Asia/Shanghai

# 从下载器阶段复制二进制
COPY --from=downloader /tmp/easytier-${BUILD_VERSION}-linux-*/easytier-core /usr/local/bin/

# 暴露端口
EXPOSE 11010/tcp  # TCP 控制端口
EXPOSE 11010/udp  # UDP 数据端口
EXPOSE 11011/udp  # WireGuard UDP
EXPOSE 11011/tcp  # WebSocket
EXPOSE 11012/tcp  # Secure WebSocket
EXPOSE 8080/tcp   # Web 管理界面端口

# 设置入口点
ENTRYPOINT ["/sbin/tini", "--", "easytier-core"]
