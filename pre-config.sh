#!/bin/sh
SITENAME="${SITENAME}"
SSLKEY='/conf/localhost.key'
SSLCRT='/conf/localhost.crt'
CACRT='/conf/ca-cert.crt'

HTTPDDIR='/etc/httpd/conf.d'
CONFFILE="$HTTPDDIR/vhost.conf"
SSLFILE="$HTTPDDIR/ssl.conf"
FCGICONF="$HTTPDDIR/fastcgi.conf"

LOGDIR='/var/log'
TLSDIR='/etc/pki/tls'

SSLPROTO='SSLProtocol all -SSLv2 -SSLv3'
SSLCIPHERS_OLD='SSLCipherSuite ALL:!ADH:!EXPORT:!SSLv2:RC4+RSA:+HIGH:+MEDIUM:+LOW'
SSLCIPHERS='SSLCipherSuite ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-DSS-AES128-GCM-SHA256:kEDH+AESGCM:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA384:ECDHE-RSA-AES256-SHA:ECDHE-ECDSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-DSS-AES128-SHA256:DHE-RSA-AES256-SHA256:DHE-DSS-AES256-SHA:DHE-RSA-AES256-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:ECDHE-RSA-RC4-SHA:ECDHE-ECDSA-RC4-SHA:AES128:AES256:RC4-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!3DES:!MD5:!PSK'

CHECKFILE='/etc/envvars-fpm'

for FILE in $SSLKEY $SSLCRT ; do
  if [[ ! -f $FILE ]] ; then
    echo "NO $FILE"
    exit 1
  fi
done

if [[ ! -f $CHECKFILE ]] ; then
  # This script hasn't yet run.  Do everything.
  # IE: Make the SSL.conf use our settings, and remove the default vhost
  if [[ -f $CACRT ]] ; then 
    sed -i 's/#SSLCACertificateFile/SSLCACertificateFile/' $SSLFILE
  fi
  
  sed -i "s/SSLProtocol all -SSLv2/$SSLPROTO/" $SSLFILE
  sed -i "s/$SSLCIPHERS_OLD/$SSLCIPHERS/" $SSLFILE

  sed -i "s/SSLEngine on/#SSLEngine on/" $SSLFILE
  sed -i "s|<VirtualHost _default_:443>|#<VirtualHost _default_:443>|" $SSLFILE
  sed -i "s|</VirtualHost>|#</VirtualHost>|" $SSLFILE
  
cat << EOF >> $SSLFILE
SSLHonorCipherOrder On
SSLOptions +StrictRequire
SetEnvIf User-Agent ".*MSIE.*" \
         nokeepalive ssl-unclean-shutdown \
         downgrade-1.0 force-response-1.0
EOF

cat << EOF >> $FCGICONF
  ScriptAlias /fastcgi-bin/ "/var/www/fastcgi-bin/"
  FastCGIExternalServer /var/www/fastcgi-bin/chris_wuz_here.fcgi -host \${FPM_PORT_9000_TCP_ADDR}:\${FPM_PORT_9000_TCP_PORT} -idle-timeout 90
  AddHandler php-fastcgi .php
  Action php-fastcgi /fastcgi-bin/chris_wuz_here.fcgi

  <Directory "/var/www/fastcgi-bin/">
    Order deny,allow
    Deny from all
    <Files "chris_wuz_here.fcgi">
      Order allow,deny
      Allow from all
    </Files>
  </Directory>
EOF

  sed -i "s/HOSTNAME/$SITENAME/g" $CONFFILE
  
  mkdir -p $LOGDIR/httpd
  chown -R apache.root $LOGDIR/httpd
  echo "${FPM_PORT_9000_TCP_ADDR}:${FPM_PORT_9000_TCP_PORT}" >> $CHECKFILE

fi

if [[ -f $CACRT ]] ; then 
  cat $CACRT > $TLSDIR/certs/ca-bundle.crt
fi
cat $SSLKEY > $TLSDIR/private/localhost.key
cat $SSLCRT > $TLSDIR/certs/localhost.crt

if [ -f /etc/sysconfig/httpd ]; then
  . /etc/sysconfig/httpd
fi

exec /usr/sbin/httpd.worker -DFOREGROUND
