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
RUN yum -y install httpd && systemctl enable httpd
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


#ADD index.php /var/www/html

RUN sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf \
  && chgrp -R 0 /var/log/httpd /var/run/httpd \
  && chmod -R g=u /var/log/httpd /var/run/httpd

EXPOSE 8080
USER 1001
CMD httpd -D FOREGROUND
