#Mediawiki ORACLELinux DOCKERFILES PROJECT
# --------------------------
# Mediawiki latest on Oracle Linux 8.9
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# (1) Install MediaWiki tarball ("sources")
# (2)  mediawiki webapp(apache,php) docker build image 
# (3) database mariadb packages(mariadb-server,mariadb) will be created separately   
# ref https://www.mediawiki.org/wiki/Manual:Running_MediaWiki_on_Red_Hat_Linux
# HOW TO BUILD THIS IMAGE
# -----------------------
# Run:
#      $ docker build -t dockerhubusername/reponame:tag .
#      $ docker build -t sridharkdb/hyd-devops:mediawiki-1.41.0-orlnx8.9 .
#

FROM oraclelinux:8.9
# version
ENV MEDIAWIKI_MAJOR_VERSION 1.41
ENV MEDIAWIKI_VERSION 1.41.0
ENV HTTPDCONF /etc/httpd/conf/httpd.conf
#Install required packages and configurations for mediawiki
RUN dnf -y module enable php:7.4 httpd:2.4 && \
    dnf -y install httpd httpd-filesystem httpd-tools mod_http2 mod_ssl openssl \
     php php-cli php-common php-json php-mbstring php-mysqlnd php-pdo php-xml php-apcu php-gd php-intl && \
    rm -rf /var/cache/dnf && \
    # Disable event module and enable prefork so that mod_php is enabled
    sed -i 's/#LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/LoadModule mpm_prefork_module modules\/mod_mpm_prefork.so/' /etc/httpd/conf.modules.d/00-mpm.conf && \
    sed -i 's/LoadModule mpm_event_module modules\/mod_mpm_event.so/#LoadModule mpm_event_module modules\/mod_mpm_event.so/' /etc/httpd/conf.modules.d/00-mpm.conf && \
    # Disable HTTP2 as it is not supported with the prefork module
    sed -i 's/LoadModule http2_module modules\/mod_http2.so/#LoadModule http2_module modules\/mod_http2.so/' /etc/httpd/conf.modules.d/10-h2.conf && \
    sed -i 's/LoadModule proxy_http2_module modules\/mod_proxy_http2.so/#LoadModule proxy_http2_module modules\/mod_proxy_http2.so/' /etc/httpd/conf.modules.d/10-proxy_h2.conf \
    && \
    # Create self-signed certificate for mod_ssl
    openssl req -x509 -nodes -newkey rsa:4096 \
                -keyout /etc/pki/tls/private/localhost.key \
                -out /etc/pki/tls/certs/localhost.crt \
                -days 3650 -subj '/CN=localhost' \
    && \
    # Redirect logging to stdout/stderr for container logging to work
    sed -i 's/;error_log = syslog/error_log = \/dev\/stderr/' /etc/php.ini && \
    ln -sf /dev/stdout /var/log/httpd/access_log && \
    ln -sf /dev/stderr /var/log/httpd/error_log && \
    ln -sf /dev/stdout /var/log/httpd/ssl_access_log && \
    ln -sf /dev/stderr /var/log/httpd/ssl_error_log && \
    # Disable userdirs and the auto-generated welcome message
    rm -f /etc/httpd/conf.d/{userdir.conf,welcome.conf} && \
    #download the source code mediawiki
    curl -O "https://releases.wikimedia.org/mediawiki/${MEDIAWIKI_MAJOR_VERSION}/mediawiki-${MEDIAWIKI_VERSION}.tar.gz" && \
	curl -O "https://releases.wikimedia.org/mediawiki/${MEDIAWIKI_MAJOR_VERSION}/mediawiki-${MEDIAWIKI_VERSION}.tar.gz.sig" && \
	gpg --fetch-keys "https://www.mediawiki.org/keys/keys.txt" && \
	gpg --verify mediawiki-${MEDIAWIKI_VERSION}.tar.gz.sig mediawiki-${MEDIAWIKI_VERSION}.tar.gz && \
	#change the httpd conf for mediawiki
        sed -i -e 's|DocumentRoot "/var/www/html"|DocumentRoot "/var/www"|g' $HTTPDCONF&& \
        sed -i -e 's|Directory "/var/www"|Directory "/var/www/mediawiki"|g' $HTTPDCONF && \
	sed -i -e 's|Directory "/var/www/html"|Directory "/var/www/mediawiki"|g' $HTTPDCONF && \
	sed -i -e 's|DirectoryIndex index.html|DirectoryIndex index.html index.html.var index.php|g' $HTTPDCONF && \
	sed -i -e 's|Indexes||g' $HTTPDCONF && \
	tar -zxf mediawiki-${MEDIAWIKI_VERSION}.tar.gz -C /var/www && \
	cd /var/www && \
        touch mediawiki-${MEDIAWIKI_VERSION}/.htaccess && \
	ln -s mediawiki-${MEDIAWIKI_VERSION}/ mediawiki && \
	chown -R apache:apache /var/www/mediawiki-${MEDIAWIKI_VERSION} && \
	chown -R apache:apache /var/www/mediawiki && \
	rm -rf /mediawiki-${MEDIAWIKI_VERSION}* /keys.txt

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
