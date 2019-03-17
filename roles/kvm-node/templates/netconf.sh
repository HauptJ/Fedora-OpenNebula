
mask2cidr() {
   local X=${1##*255.}
   set -- 0^^^128^192^224^240^248^252^254^ $(( (${#1} - ${#X})*2 )) ${X%%.*}
   X=${1%%$3*}
   echo $(( $2 + (${#X}/4) ))
}

configure_nat() {
    iptables --table nat -A POSTROUTING -s {{ VNET_ADDRESS }}/${NETMASK_BITS} ! \
        -d ${VNET_ADDRESS}/${NETMASK_BITS} -j MASQUERADE || return 1

    # verify nat by ping
    sleep 1
    ping -W 3 -c 1 -I ${VNET_AR_IP_START} 8.8.8.8 -q >/dev/null
}

onecli_cmd_tmpl() {
    local COMMAND=$1
    local DATA=$2
    local TMP_FILE=$(mktemp) || return 1

    cat > ${TMP_FILE}<< EOF
${DATA}
EOF

    $COMMAND $TMP_FILE
    RC=$?
    rm ${TMP_FILE}
    return ${RC}
}

update_datastores() {
    TEMPLATE=$(cat << EOF
<DATASTORE>
  <SHARED><![CDATA[YES]]></SHARED>
  <TM_MAD><![CDATA[qcow2]]></TM_MAD>
</DATASTORE>
EOF
)

    onecli_cmd_tmpl "onedatastore update 0" "${TEMPLATE}" >/dev/null ||return 1
    onecli_cmd_tmpl "onedatastore update 1" "${TEMPLATE}" >/dev/null
}

next_ip(){
    local IP=$1

    IP_HEX=$(printf '%.2X%.2X%.2X%.2X\n' `echo $IP | sed -e 's/\./ /g'`)
    NEXT_IP_HEX=$(printf %.8X `echo $(( 0x$IP_HEX + 1 ))`)
    NEXT_IP=$(printf '%d.%d.%d.%d\n' `echo $NEXT_IP_HEX | sed -r 's/(..)/0x\1 /g'`)
    echo "$NEXT_IP"
}

create_vnet() {
    FIRST_IP=$(next_ip ${VNET_AR_IP_START})
    SIZE=$((${VNET_AR_IP_COUNT} - 1))

    TEMPLATE=$(cat << EOF
NAME = "vnet"
BRIDGE = "{{ BRIDGE_INTERFACE }}"
DNS = "{{ VNET_GATEWAY }}"
GATEWAY = "{{ VNET_GATEWAY }}"
PHYDEV = ""
SECURITY_GROUPS = "0"
VN_MAD = "fw"
AR = [
    IP = {{ FIRST_IP }},
    SIZE = {{ SIZE }} ,
    TYPE = IP4
]
EOF
)
    onecli_cmd_tmpl "onevnet create" "${TEMPLATE}"  >/dev/null 2>&1
}

NETMASK_BITS=$(mask2cidr ${VNET_NETMASK})