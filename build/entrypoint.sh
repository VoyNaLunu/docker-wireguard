#!/bin/bash



startInterfaces() {

    #check if wireguard config files are present
    config_files=$(find /etc/wireguard/ -maxdepth 1 -name "*.conf")
    if [ ${#config_files[@]} -eq 0 ]
    then
        echo "wireguard config files not found" && exit 1
    fi

    #start all wireguard interfaces
    for filename in /etc/wireguard/*.conf
    do
        echo $filename
        wg-quick up ${filename}    
    done
    iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
}

healthCheck() {

    #check if wireguard interfaces are up and keep container alive
    while true
    do
        if [[ ! $(wg) ]]
        then
            echo "Error: missing wireguard interfaces" && exit 1
        fi
    sleep 5
    done
}


main() {

    startInterfaces
    healthCheck
}




case $1 in

    generate)
        ./helpers.sh "$1" "$2"
        exit 0
        ;;
    
    *)
        main
esac