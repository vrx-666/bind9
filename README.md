# Bind9
From alpine-linux dockerized bind9 with Webmin GUI<br>
```
bind9
bind9-tools
bind9-dnssec
perl
webmin with bind module only (v1.979)

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
      - "53:53/udp"          #dns service
      - "10000:10000/tcp"    #webmin http
```
For simpler use, You can do:
```
    network_mode: host
```
instead "ports" directive<br>
<br>
ENV Vars could be used:
```
GUI_USER - run with different username to Webmin Panel (default: admin)
ENV GUI_PASSWORD - run with different password (default: dificult)
```
