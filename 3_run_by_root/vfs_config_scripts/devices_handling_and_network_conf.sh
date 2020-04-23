#no need for shebang because /bin/bash does not exist and this script is being run by bash
SYS_CONF_SCRIPTS_DIR="vfs_config_scripts"

function create_network_interface_conf_file ()
{
cd /etc/sysconfig/
cat > ifconfig.eth0 << "EOF"
ONBOOT=yes
IFACE=eth0
SERVICE=ipv4-static
IP=192.168.0.100
GATEWAY=192.168.0.1
PREFIX=24
BROADCAST=192.168.1.255
EOF
}

function create_resolvconf ()
{
cat > /etc/resolv.conf << "EOF"
# Begin /etc/resolv.conf

#domain <Your Domain Name>
nameserver 192.168.0.1
#nameserver <IP address of your secondary nameserver>

# End /etc/resolv.conf
EOF
}

function create_hostname_file ()
{
    echo "lfslab" > /etc/hostname
}

function create_host_file ()
{
    cat > /etc/hosts << "EOF"
127.0.0.1       localhost

# The following lines are desirable for IPv6 capable hosts
::1     ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
EOF
}

source /$SYS_CONF_SCRIPTS_DIR/utils.sh
s_start $0
S=$?

run_cmd /lib/udev/init-net-rules.sh
#cat /etc/udev/rules.d/70-persistent-net.rules
run_cmd create_network_interface_conf_file
run_cmd create_hostname_file
run_cmd create_hosts_file
run_cmd create_resolvconf

s_end $0
E=$?
s_duration $0 $S $E
