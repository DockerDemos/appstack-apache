# Docker image for running Apache with mod_fastcgi in a Docker container

FROM centos:centos6
MAINTAINER Chris Collins <collins.christopher@gmail.com>

ENV BUILDPKGS rpm-build rpmdevtools redhat-rpm-config glibc-static httpd-devel apr-devel git which tar

ENV HTTPDCONF /etc/httpd/conf/httpd.conf
ENV SSLFILE /etc/httpd/conf.d/ssl.conf
ENV SSLPROTO SSLProtocol all -SSLv2 -SSLv3
ENV SSLCIPHERS SSLCipherSuite ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128:AES256:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!3DES:!MD5:!PSK

RUN yum install -y --nogpgcheck $BUILDPKGS gcc autoconf automake httpd mod_ssl
ADD build-rpm.sh /build-rpm.sh
RUN /build-rpm.sh && rm /build-rpm.sh
RUN yum remove -y $BUILDPKGS

RUN mkdir /var/www/fastcgi-bin
ADD vhost.conf /etc/httpd/conf.d/vhost.conf

# SSL Hardening
RUN sed -i "s/SSLProtocol all -SSLv2.*/$SSLPROTO/" $SSLFILE
RUN sed -i "s/^SSLCipherSuite.*/$SSLCIPHERS/" $SSLFILE
RUN sed -i "s/SSLEngine on/#SSLEngine on/" $SSLFILE
RUN sed -i "s|<VirtualHost _default_:443>|#<VirtualHost _default_:443>|" $SSLFILE
RUN sed -i "s|</VirtualHost>|#</VirtualHost>|" $SSLFILE

RUN echo -e "\
SSLHonorCipherOrder On\n\
SSLOptions +StrictRequire\n\
" >> $SSLFILE

# Use only the modules we need
RUN sed -i '/^LoadModule/d' $HTTPDCONF
RUN sed -i '/# LoadModule foo_module modules\/mod_foo.so/c\
LoadModule include_module modules\/mod_include.so\n\\
LoadModule authz_host_module modules\/mod_authz_host.so\n\\
LoadModule log_config_module modules\/mod_log_config.so\n\\
LoadModule mime_module modules\/mod_mime.so\n\\
LoadModule status_module modules\/mod_status.so\n\\
LoadModule autoindex_module modules\/mod_autoindex.so\n\\
LoadModule negotiation_module modules\/mod_negotiation.so\n\\
LoadModule alias_module modules\/mod_alias.so\n\\
LoadModule rewrite_module modules\/mod_rewrite.so\n\\
LoadModule proxy_module modules\/mod_proxy.so\n\\
LoadModule proxy_http_module modules\/mod_proxy_http.so\n\\
LoadModule deflate_module modules\/mod_deflate.so\n\\
LoadModule vhost_alias_module modules\/mod_vhost_alias.so\n\\
LoadModule dir_module modules\/mod_dir.so\n\\
LoadModule actions_module modules\/mod_actions.so\n\\
LoadModule setenvif_module modules\/mod_setenvif.so' $HTTPDCONF

ADD pre-config.sh /pre-config.sh

EXPOSE 80 
EXPOSE 443 

ENTRYPOINT ["/pre-config.sh"]
