FROM registry.access.redhat.com/ubi7/ubi:7.8
LABEL maintainer="pschryve@nga.be"
LABEL version="2.0"
LABEL description="Front end for Orainfrastructure 2.0"

# Install additional products
RUN yum -y install unzip && \
    yum -y install epel-release.noarch yum-utils && \
    yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && \
    yum -y install pam && \
    yum -y install ncurses-devel && \
    yum -y install unixODBC && \
    yum -y install epel-release && \
    yum -y install wget && \
    yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm && \
    yum-config-manager --enable remi-php73 && \
    yum -y install epel-release yum-utils
#
# Install java
RUN yum -y install java
#
# Install http
RUN yum -y install httpd
#
# Install and configure php
RUN yum -y install php php-bcmath php-common php-cli php-gd php-json php-ldap php-mbstring php-soap php-xml php-zip php-pgsql php-pear
RUN php -v
RUN echo "max_execution_time = 3600" >> /etc/php.ini && \
    echo "max_input_time = 3600" >> /etc/php.ini && \
    echo "max_input_vars = 10000" >> /etc/php.ini && \
    echo "memory_limit = 1024M" >> /etc/php.ini && \
    echo "post_max_size = 1024M" >> /etc/php.ini && \
    echo "upload_max_filesize = 1024M" >> /etc/php.ini && \
    echo "max_file_uploads = 200" >> /etc/php.ini && \
    echo "short_open_tag = On" >> /etc/php.ini && \
    echo "disable_functions =" >> /etc/php.ini && \
    echo "date.timezone = Europe/Brussels" >> /etc/php.ini && \
    echo "session.save_path = \"/tmp\"" >> /etc/php.ini
#
# Install ioncube
RUN wget https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz -P /tmp
RUN cd /tmp && tar -xvf /tmp/ioncube_loaders_lin_x86-64.tar.gz
RUN cp /tmp/ioncube/ioncube_loader_lin_7.3.so /usr/lib64/php/modules
RUN chmod 755 /usr/lib64/php/modules/ioncube_loader_lin_7.3.so
RUN echo "zend_extension = \"/usr/lib64/php/modules/ioncube_loader_lin_7.3.so\"" >> /etc/php.ini
RUN rm -rf /tmp/ioncube && rm -f /tmp/ioncube_loaders_lin_x86-64.tar.gz
#
# Install Oracle client
RUN cd /etc/yum.repos.d && rm -f public-yum-ol7.repo && wget https://yum.oracle.com/public-yum-ol7.repo
RUN wget http://public-yum.oracle.com/RPM-GPG-KEY-oracle-ol7 -O /etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
RUN yum-config-manager --enable ol7_oracle_instantclient
RUN yum list oracle-instantclient*
RUN yum -y install oracle-instantclient19.8-basic oracle-instantclient19.8-devel oracle-instantclient19.8-sqlplus
RUN echo "ORACLE_HOME=/usr/lib/oracle/19.7/client64; export ORACLE_HOME" >> /etc/profile && \
    echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ORACLE_HOME/lib; export LD_LIBRARY_PATH" >> /etc/profile && \
    echo "TNS_ADMIN=/usr/lib/oracle/19.7; export TNS_ADMIN" >> /etc/profile && \
    echo "PATH=$PATH:$ORACLE_HOME/bin" >> /etc/profile
RUN yum -y install php-oci8
    
RUN echo "<?php phpinfo(); ?>" > /var/www/html/index.php

# Install orainfra library and application
RUN mkdir -p /var/www/html/_lib/conf
RUN mkdir -p /var/www/html/_lib/tmp

RUN sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf \
  && chgrp -R 0 /var/log/httpd /var/run/httpd /var/www/html \
  && chmod -R g=u /var/log/httpd /var/run/httpd /var/www/html \
  && chmod -R 777 /var/log/httpd /var/run/httpd /var/www/html \
  && chmod 777 /var /var/www

EXPOSE 8080
USER 1001
CMD httpd -D FOREGROUND
