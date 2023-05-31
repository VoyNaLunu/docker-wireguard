#!/bin/bash



#returns a random host part for wireguard network
randomNetwork() {
    network[0]=10
    network[1]=172
    network[2]=192
    network[3]=100
    rand=$(($RANDOM % ${#network[@]}))
    chosen_network=${network[$rand]}
    case $chosen_network in

        172)
            second_octet_range="16-31"
            ;;
        
        192)
            second_octet_range="168-168"
            ;;
        
        100)
            second_octet_range="64-127"     
            ;;

        *)
            second_octet_range="0-255"
            ;;
    esac
    second_octet=$(shuf -i $second_octet_range -n 1)
    third_octet=$(shuf -i 0-255 -n 1)

    echo "$chosen_network.$second_octet.$third_octet"

}




#returns configuration for wireguard server and clients
#usage: docker compose run --rm docker-wireguard generate [1..254]
generateConfig() {
    if [ $1 -lt 1 ] || [ $1 -gt 254 ]
    then
        echo "error" && exit 1
    fi
    tmp_srv_key="/tmp/srvprivkey.$RANDOM"
    tmp_psk="/tmp/psk.$RANDOM"
    network=$(randomNetwork)
    echo ""
    echo "##########SERVER CONFIG##########"
    echo "[Interface]"
    echo "Address = $network.1/24"
    echo "ListenPort = 51820"
    echo "PrivateKey = $(wg genkey | tee $tmp_srv_key)"
    wg genpsk | tee $tmp_psk >/dev/null
    for ((i=1; i<=$1; i++))
    do
            echo ""
            tmp_cli_key[$i]="/tmp/cliprivkey$i.$RANDOM"
            echo "[Peer]"
            echo "PublicKey = $(wg genkey | tee ${tmp_cli_key[$i]} | wg pubkey)"
            echo "PresharedKey = $(cat $tmp_psk)"
            echo "AllowedIPs = $network.$(($i+1))/32"
        done
        echo "#############################"
    for ((i=1; i<=$1; i++))
    do
        echo -e "\n\n"
        echo "##########CLIENT №$i CONFIG##########"
        echo "[Interface]"
        echo "Address = $network.$(($i+1))/32"
        echo "PrivateKey = $(cat ${tmp_cli_key[$i]})"
        echo ""
        echo "[Peer]"
        echo "PublicKey = $(cat $tmp_srv_key | wg pubkey)"
        echo "PresharedKey = $(cat $tmp_psk)"
        echo "AllowedIPs = 0.0.0.0/0"
        echo "Endpoint = $(curl -s ifconfig.me):51820"
        echo "################################"
        rm -f ${tmp_cli_key[$i]}
    done
    rm -f $tmp_srv_key
    rm -f $tmp_psk
}




case $1 in
    generate)
        generateConfig "$2"
        ;;
esac