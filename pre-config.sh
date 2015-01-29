#!/bin/sh
SITENAME="${SITENAME}"
SSLKEY='/conf/localhost.key'
SSLCRT='/conf/localhost.crt'
CACRT='/conf/ca-cert.crt'

LOGDIR='var/log'
HTTPDDIR='/etc/httpd/conf.d'
THREADCONF="$HTTPDDIR/threads.conf"
CONFFILE="$HTTPDDIR/vhost.conf"
SSLFILE="$HTTPDDIR/ssl.conf"
FCGICONF="$HTTPDDIR/fastcgi.conf"
THREADYML="/conf/threads.yaml"

TLSDIR='/etc/pki/tls'
CHECKFILE='/etc/envvars-fpm'

f_set_threads () {
  if [[ $1 == '--default' ]] ; then
	cat <<- EOF > $THREADCONF
	<IfModule worker.c>
	StartServers          40
	MaxClients           125
	MinSpareThreads       20
	MaxSpareThreads       80
	ThreadsPerChild      125
	MaxRequestsPerChild    0
	</IfModule>
	# Prefork probably not used
	<IfModule prefork.c>
	StartServers           10
	MinSpareServers         5
	MaxSpareServers        20
	ServerLimit            30
	MaxClients             30
	MaxRequestsPerChild  1000
	</IfModule>
	EOF
  else
	cat <<- EOF > $THREADCONF
	<IfModule worker.c>
	StartServers         $(awk '/web_startservers/ {print $2}' $THREADYML)
	MaxClients           $(awk '/web_maxclients/ {print $2}' $THREADYML)
	MinSpareThreads      $(awk '/web_minspare/ {print $2}' $THREADYML)
	MaxSpareThreads      $(awk '/web_maxspare/ {print $2}' $THREADYML)
        ThreadsPerChild      $(awk '/web_threadsperchild/ {print $2}' $THREADYML)
	MaxRequestsPerChild  $(awk '/web_maxreqperchild/ {print $2}' $THREADYML)
	</IfModule>
	# Prefork probably not used
	<IfModule prefork.c>
	StartServers         $(awk '/web_startservers/ {print $2}' $THREADYML)
	MinSpareServers      $(awk '/web_minspare/ {print $2}' $THREADYML)
	MaxSpareServers      $(awk '/web_maxspare/ {print $2}' $THREADYML)
	ServerLimit          $(awk '/web_maxclients/ {print $2}' $THREADYML)
	MaxClients           $(awk '/web_maxclients/ {print $2}' $THREADYML)
	MaxRequestsPerChild  $(awk '/web_maxreqperchild/ {print $2}' $THREADYML)
	</IfModule>
	EOF
  fi
}

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

if [[ -f /conf/threads.yaml ]] ; then
  f_set_threads
else
  f_set_threads --default
fi

if [ -f /etc/sysconfig/httpd ]; then
  . /etc/sysconfig/httpd
fi

exec /usr/sbin/httpd.worker -DFOREGROUND
