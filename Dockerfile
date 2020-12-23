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

RUN yum --disableplugin=subscription-manager -y module enable php:7.3 \
  && yum --disableplugin=subscription-manager -y install httpd php \
  && yum --disableplugin=subscription-manager clean all

#ADD index.php /var/www/html

RUN sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf \
  && sed -i 's/listen.acl_users = apache,nginx/listen.acl_users =/' /etc/php-fpm.d/www.conf \
  && mkdir /run/php-fpm \
  && chgrp -R 0 /var/log/httpd /var/run/httpd /run/php-fpm \
  && chmod -R g=u /var/log/httpd /var/run/httpd /run/php-fpm

EXPOSE 8080
USER 1001
CMD php-fpm & httpd -D FOREGROUND
