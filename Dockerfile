# Docker image for running Apache with mod_fastcgi in a Docker container

FROM centos:centos6
MAINTAINER Chris Collins <collins.christopher@gmail.com>

RUN yum install -y rpm-build rpmdevtools redhat-rpm-config gcc glibc-static autoconf automake httpd-devel apr-devel git which tar httpd mod_ssl
ADD build-rpm.sh /build-rpm.sh
RUN /build-rpm.sh
RUN yum remove -y rpm-build rpmdevtools redhat-rpm-config glibc-static httpd-devel apr-devel git which tar

RUN mkdir /var/www/fastcgi-bin
ADD vhost.conf /etc/httpd/conf.d/vhost.conf
ADD pre-config.sh /pre-config.sh

EXPOSE 80 
EXPOSE 443 

ENTRYPOINT ["/pre-config.sh"]
