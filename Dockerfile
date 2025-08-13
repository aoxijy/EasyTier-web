# 原始Dockerfile内容不变
FROM alpine:latest
RUN apk add --no-cache tzdata tini iptables wireguard-tools bash ttf-dejavu fontconfig
ENV TZ=Asia/Shanghai
RUN mkdir -p /var/log/easytier
COPY easytier-core /usr/local/bin/
COPY easytier-web-embed /usr/local/bin/
COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh
COPY web /var/www/html
EXPOSE 11010/tcp
EXPOSE 11010/udp
EXPOSE 11011/udp
EXPOSE 11011/tcp
EXPOSE 11012/tcp
EXPOSE 11211/tcp
EXPOSE 22020/udp
EXPOSE 8080/tcp
ENTRYPOINT ["/sbin/tini", "--"]
CMD ["/usr/local/bin/start.sh"]
