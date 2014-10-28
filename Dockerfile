# Docker container for an Apache webserver with PHP-FPM
# http://www.apache.org
#
# Due to a bug we MUST USE el6 until patch upstream makes it into packages
# unless the image will be built on a RHEL-based (CentOS, Scientific Linux) host
#
# See:
# https://github.com/docker/docker/pull/5930
#
# If you have a RHEL-based server and want to use a CentOS 7 image, checkout
# the 'el7-fpm' branch

FROM centos:centos6
MAINTAINER Chris Collins <collins.christopher@gmail.com>

ENV FASTCGI https://github.com/clcollins/mod_fastcgi-rpm.git

RUN yum install -y rpm-build rpmdevtools redhat-rpm-config gcc glibc-static autoconf automake httpd-devel apr-devel git which tar httpd mod_ssl

WORKDIR /root
RUN git clone $FASTCGI 
RUN ./mod_fastcgi-rpm/build.sh mod_fastcgi 
RUN yum install -y ./rpmbuild/RPMS/*/*.rpm
# need to keep gcc autoconf automake until mod_fastcgi RPM is fixed
RUN yum remove -y rpm-build rpmdevtools redhat-rpm-config glibc-static httpd-devel apr-devel git which tar
WORKDIR /
RUN mkdir /var/www/fastcgi-bin
RUN echo -e '\
  DirectoryIndex index.php index.html\n\
\n\
  ScriptAlias /fastcgi-bin/ "/var/www/fastcgi-bin/"\n\
  FastCGIExternalServer /var/www/fastcgi-bin/chris_wuz_here.fcgi -host ${FPM_PORT_9000_TCP_ADDR}:${FPM_PORT_9000_TCP_PORT} -idle-timeout 90\n\
  AddHandler php-fastcgi .php\n\
  Action php-fastcgi /fastcgi-bin/chris_wuz_here.fcgi\n\
\n\
  <Directory "/var/www/fastcgi-bin/">\n\
    Order deny,allow\n\
    Deny from all\n\
    <Files "chris_wuz_here.fcgi">\n\
      Order allow,deny\n\
      Allow from all\n\
    </Files>\n\
  </Directory>\n\
' >> /etc/httpd/conf.d/fpm.conf
ADD run-apache.sh /run-apache.sh

EXPOSE 80 
EXPOSE 443 

ENTRYPOINT ["/run-apache.sh"]
