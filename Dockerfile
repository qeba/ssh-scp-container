FROM alpine:latest

RUN apk add --no-cache \
    openssh-server \
    openssh-client \
    sudo \
    bash \
    shadow

RUN mkdir -p /var/run/sshd

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
    && echo 'AllowUsers *' >> /etc/ssh/sshd_config

RUN mkdir -p /etc/skel/.ssh

EXPOSE 22

ENTRYPOINT []
CMD ["/entrypoint.sh"] 