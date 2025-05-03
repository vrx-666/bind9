#!/bin/sh
. /usr/local/include/bind

if [ ! -d /etc/bind ];then
	do_config_dir
else
	prepare_config_dir
fi

if [ ! -s /etc/bind/bind.keys ];then
	bind_keys
fi

start_webmin
if [ $? != 0 ];then
	restart_webmin
fi

change_username
update_password

if [ "${IPV6}" == "enable" ]; then 
	enable_ipv6
fi
if [ "${IPV6}" == "disable" ]; then 
	disable_ipv6
fi
if [ "${EXTEND_LOGGING}" == "true" ];then
	enable_extended_logging
fi
if [ "${EXTEND_LOGGING}" == "false" ];then
	disable_extended_logging
fi

check_rndc_key

exec "$@"
