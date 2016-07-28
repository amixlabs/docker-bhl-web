FROM centos:5

MAINTAINER edison@amixsi.com.br

ADD install.sh /tmp/
WORKDIR /tmp
RUN ./install.sh

WORKDIR /app
EXPOSE 80
ENTRYPOINT . /etc/sysconfig/httpd; /usr/sbin/apachectl -D FOREGROUND
