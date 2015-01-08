#!/bin/sh
SITENAME="${SITENAME}"
SSLKEY='/conf/localhost.key'
SSLCRT='/conf/localhost.crt'
CACRT='/conf/ca-cert.crt'

LOGDIR='var/log'
HTTPDDIR='/etc/httpd/conf.d'
CONFFILE="$HTTPDDIR/vhost.conf"
SSLFILE="$HTTPDDIR/ssl.conf"
FCGICONF="$HTTPDDIR/fastcgi.conf"

TLSDIR='/etc/pki/tls'
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
  
  echo "${FPM_PORT_9000_TCP_ADDR}:${FPM_PORT_9000_TCP_PORT}" >> $CHECKFILE

  # Create Apache Log Dirs
  mkdir -p $LOGDIR/httpd
  chown -R apache.root $LOGDIR/httpd

fi

# DO THE REST EVERY TIME
if [[ -f $CACRT ]] ; then 
  cat $CACRT > $TLSDIR/certs/ca-bundle.crt
fi
cat $SSLKEY > $TLSDIR/private/localhost.key
cat $SSLCRT > $TLSDIR/certs/localhost.crt

if [ -f /etc/sysconfig/httpd ]; then
  . /etc/sysconfig/httpd
fi

exec /usr/sbin/httpd.worker -DFOREGROUND
