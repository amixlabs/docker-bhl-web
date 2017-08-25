FROM centos:5

MAINTAINER edison@amixsi.com.br

ENV NODE_VERSION v6.11.2
ENV PATH $PATH:/opt/node-$NODE_VERSION-linux-x64/bin

ADD install.sh /tmp/
WORKDIR /tmp
RUN ./install.sh

WORKDIR /app
EXPOSE 80

ADD entrypoint.sh /usr/local/bin/
ENTRYPOINT ["entrypoint.sh"]