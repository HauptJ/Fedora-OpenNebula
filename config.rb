# NOTE: The provided inline shell provisioner will only work with my CentOS 7.4 Vagrant box.
# https://github.com/HauptJ/Vagrant-CentOS-7-HyperV-Gen-2
# If you wish to use another Vagrant box, you will have to uncomment the
# commented out commands. See: Vagrantfile

$centos_box = "hauptj/CentOS76lite"
$centos_box_ver = "1.0.2"
$ssh_user = "root"

$opennebula_master_vmname = "opennebula_master"
$opennebula_master_mac = "ECB8B9AFE1A1"
$opennebula_master_vcpus = "4"
$opennebula_master_vmem  = "4096"

$opennebula_node_vmname = "opennebula_master"
$opennebula_node_mac = "ECB8B9AFE1B1"
$opennebula_node_vcpus = "4"
$opennebula_node_vmem  = "4096"