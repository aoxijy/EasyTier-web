# 使用官方基础镜像结构
FROM alpine:latest AS base

# 构建阶段
FROM base AS builder

# 安装构建依赖
RUN apk add --no-cache git nodejs npm go gcc musl-dev

# 克隆 EasyTier 主仓库 - 使用特定版本
ARG EASYTIER_VERSION=latest
RUN git clone --depth 1 --branch ${EASYTIER_VERSION} https://github.com/EasyTier/EasyTier.git /src/easytier
WORKDIR /src/easytier

# 克隆并构建 EasyTier-Web-Embed (使用令牌认证)
RUN git config --global url."https://oauth2:${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/" && \
    git clone --depth 1 https://github.com/EasyTier/EasyTier-Web-Embed.git web

WORKDIR /src/easytier/web
RUN npm ci --silent && npm run build

# 返回主目录构建主程序
WORKDIR /src/easytier
RUN go build -o easytier-core -ldflags "-s -w" ./cmd/easytier

# 准备最终输出
RUN mkdir -p /tmp/output && \
    cp easytier-core /tmp/output/easytier-core

# 最终镜像阶段
FROM base

# 安装运行时依赖
RUN apk add --no-cache tzdata tini iptables wireguard-tools

# 复制构建好的二进制文件
COPY --from=builder --chmod=755 /tmp/output/* /usr/local/bin/

# 设置时区 (用户可通过 -e TZ=xxx 覆盖)
ENV TZ=Asia/Shanghai

# 暴露所有官方默认端口
EXPOSE 11010/tcp
EXPOSE 11010/udp
EXPOSE 11011/udp
EXPOSE 11011/tcp
EXPOSE 11012/tcp
EXPOSE 8080/tcp

# 设置入口点 (保留官方 tini 用法)
ENTRYPOINT ["/sbin/tini", "--", "easytier-core"]
