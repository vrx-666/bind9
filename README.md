# Bind9
From alpine-linux dockerized bind9 with Webmin GUI<br>
```
bind9
bind9-tools
bind9-dnssec
perl
webmin with bind module only

```
Build docker by
```
docker build -t IMAGE_NAME(:tag) .
```
Example compose file
```
bind:
    image: IMAGE_NAME:tag
    volumes:
      - "/LOCAL/PATH/TO/BIND/CONFIG:/etc/bind"
    restart: always
    environment:
      TZ: "Region/City"
    ports:
      - "53:53"          #dns service
      - "10000:10000"    #webmin http
```
For simpler use, You can do:
    network_mode: host
instead "ports" directive
