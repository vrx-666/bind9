FROM alpine:3.14.1

LABEL maintainer="developer@s.vrx.pl"
LABEL version="1.2"
LABEL description="Bind with Webmin GUI."

ENV WEBMIN_VER=1.979
ENV GUI_USER=${GUI_USER:-admin}
ENV GUI_PASSWORD=${GUI_PASSWORD:-difficult}
ENV GUI_PORT=${GUI_PORT:-10000}

RUN apk update && apk upgrade && apk add --no-cache supervisor bind bind-tools perl perl-net-ssleay && \
    wget -q http://prdownloads.sourceforge.net/webadmin/webmin-${WEBMIN_VER}.tar.gz -O /opt/webmin.tar.gz && \
    tar xf /opt/webmin.tar.gz -C /opt && \
    rm -rf /opt/webmin.tar.gz && \
    rm -rf /var/cache/apk/* && \
    ln -s /opt/webmin-${WEBMIN_VER} /opt/webmin && \
    rm -rf /opt/webmin/adsl-client /opt/webmin/ajaxterm /opt/webmin/apache /opt/webmin/backup-config /opt/webmin/bacula-backup /opt/webmin/bandwidth /opt/webmin/change-user /opt/webmin/cluster-copy /opt/webmin/cluster-cron /opt/webmin/cluster-passwd /opt/webmin/cluster-shell /opt/webmin/cluster-software /opt/webmin/cluster-useradmin /opt/webmin/cluster-usermin /opt/webmin/cluster-webmin /opt/webmin/cpan /opt/webmin/custom /opt/webmin/dhcpd /opt/webmin/dovecot /opt/webmin/exim /opt/webmin/fail2ban /opt/webmin/fetchmail /opt/webmin/filemin /opt/webmin/firewall /opt/webmin/firewall6 /opt/webmin/firewalld /opt/webmin/fsdump /opt/webmin/grub /opt/webmin/heartbeat /opt/webmin/htaccess-htpasswd /opt/webmin/idmapd /opt/webmin/inetd /opt/webmin/init /opt/webmin/inittab /opt/webmin/ipsec /opt/webmin/iscsi-client /opt/webmin/iscsi-server /opt/webmin/iscsi-target /opt/webmin/iscsi-tgtd /opt/webmin/jabber /opt/webmin/krb5 /opt/webmin/ldap-client /opt/webmin/ldap-server /opt/webmin/ldap-useradmin /opt/webmin/logrotate /opt/webmin/lpadmin /opt/webmin/lvm /opt/webmin/mailboxes /opt/webmin/mailcap /opt/webmin/man /opt/webmin/mon /opt/webmin/mount /opt/webmin/mysql /opt/webmin/net /opt/webmin/openslp /opt/webmin/pam /opt/webmin/pap /opt/webmin/passwd /opt/webmin/phpini /opt/webmin/postfix /opt/webmin/postgresql /opt/webmin/ppp-client /opt/webmin/pptp-client /opt/webmin/pptp-server /opt/webmin/procmail /opt/webmin/proftpd /opt/webmin/qmailadmin /opt/webmin/quota /opt/webmin/raid /opt/webmin/samba /opt/webmin/sarg /opt/webmin/shell /opt/webmin/shorewall /opt/webmin/shorewall6 /opt/webmin/smart-status /opt/webmin/software /opt/webmin/spam /opt/webmin/squid /opt/webmin/sshd /opt/webmin/stunnel /opt/webmin/syslog-ng /opt/webmin/syslog /opt/webmin/tcpwrappers /opt/webmin/telnet /opt/webmin/tunnel /opt/webmin/updown /opt/webmin/useradmin /opt/webmin/usermin /opt/webmin/vgetty /opt/webmin/webalizer /opt/webmin/wuftpd /opt/webmin/xinetd /opt/webmin/filter /opt/webmin/exports /opt/webmin/fdisk && \
    export config_dir=/etc/webmin && \
    export var_dir=/var/log/webmin && \
    export perl=/usr/bin/perl && \
    export os_type=gentoo-linux && \
    export os_version=12.1 && \
    export port=${GUI_PORT} && \
    export login=${GUI_USER} && \
    export password=${GUI_PASSWORD} && \ 
    export password2=${GUI_PASSWORD} && \
    export ssl=0 && \
    export atboot=0 && \
    export nostart=1 && \
    sh /opt/webmin-${WEBMIN_VER}/setup.sh && \
    mkdir /data && \
    rm /etc/bind/named.conf.authoritative && \
    rm /etc/bind/named.conf.recursive && \
    mv /etc/bind /data/. && \
    echo '' > /etc/apk/repositories && \
    echo 'gotomodule=bind8' >> /etc/webmin/config && \
    sed -i 's/^rndc_conf=.*$/rndc_conf=\/etc\/bind\/rndc\.key/g' /etc/webmin/bind8/config && \
    rm -rf /etc/webmin/status/services/nfs.serv
    
COPY supervisord.conf /etc/supervisord.conf
COPY startbind /usr/local/sbin/startbind
COPY webmin.acl /etc/webmin/webmin.acl
COPY bind8-lib.pl /opt/webmin/bind8/bind8-lib.pl
COPY conf_rndc.cgi /opt/webmin/bind8/conf_rndc.cgi
COPY save_rndc.cgi /opt/webmin/bind8/save_rndc.cgi
COPY named /etc/init.d/named

VOLUME ["/etc/bind"]

EXPOSE 53/udp 53/tcp 10000/tcp

ENTRYPOINT /usr/local/sbin/startbind ${GUI_PASSWORD}
