# Docker Wireguard

## Description
Very basic and easy to modify locally built alpine container that provides wireguard vpn  
size of the image: ~20MB

## How to run

1. Clone the repository  
`git clone https://github.com/VoyNaLunu/docker-wireguard.git`  

2. Move into the cloned folder  
`cd docker-wireguard/`

3. Put your server configuration file into conf.d folder or use docker command below to generate configuration for server and client(s),  
where `n` is number of clients  
`docker compose run --rm docker-wireguard generate n`


4. Modify docker-compose.yml to your liking and run it  
`docker compose up -d`
