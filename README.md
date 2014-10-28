appstack-apache
===============

Docker images for running Apache; for use with other AppStack images

_Branches_

* master: Centos6, Apache with mod_fastcgi to connect to PHP-FPM container
* el7-fpm: Centos7, Apache with mod_proxy_fcgi to connect to PHP-FPM container
* el7-mod_php: Centos7, Apache with mod_php installed

##Running##

The master branch is designed to be run with the appstack-phpfpm and appstack-data containers.

First run the data container, and map a directories on your host to /conf and /var/www/html:

    sudo docker run -d --name data -v /srv/conf:/conf -v /srv/html:/var/www/html data

Place your SSL certificate and Key into /srv/conf.  (Non-SSL support will be added in a future update.)

Run the php-fpm container:

    sudo docker run --name fpm --volumes-from data -d php-fpm

Run the Apache container, with volumes from the data container, ports 80 and 443 exposed to your host, and linked to the php-fpm container.

    sudo docker run -p 80:80 -p 443:443 --name web --link fpm:fpm --volumes-from data -d apache

Finally, place whatever content you want served into /srv/html, and you're done.

##Customization##

There are a few ways to customize the Apache container to your environment:

_HTTPS/SSL_

The SSL key and certificate should be named "localhost.key" and "localhost.crt", and be placed into the directory you have mapped to /conf on the appstack-data container.  SSL is __REQUIRED.__

For help generating a self-signed SSL certificate, read: [https://gist.github.com/clcollins/95a62c38b06a6304b78b](https://gist.github.com/clcollins/95a62c38b06a6304b78b)


##Issues##

Tracked on Github: [https://github.com/DockerDemos/appstack-apache/issues](https://github.com/DockerDemos/appstack-apache/issues)

##Copyright Information##

Copyright (C) 2014 Chris Collins

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.




