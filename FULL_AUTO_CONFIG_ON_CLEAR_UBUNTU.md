## Installation on clean Ubuntu 20.04 in automatic mode ( for minimal skills)

#### If you want a step-by-step explanation of the steps in these instructions, [see here](https://github.com/totumonline/totum-mit-docker/blob/main/FULL_CONFIG_ON_CLEAR_UBUNTU.md)


Register a domain and direct it to the `ip` of your server. It is possible to install without using a domain opening by the server's `ip`. You can also use level 3 and level 4 domains.



Make sure that your server does not install or update anything:

```
ps aux | grep -i apt
```

There should only be one line in the answer!



Define your required time zone `tzselect`:

```
tzselect
```

1. You must enter the area number and press Enter. Then a list of countries will appear.
2. Similarly, you need to enter the country number.
3. A list of cities will appear. Enter the city number.
4. As a result, you will see the name of your time zone.



Set the variables, replace `YOU_TIMEZONE` and `YOU_PASS_FOR_BASE` with yours and execute:

```
DOCKERTIMEZONE=YOU_TIMEZONE && DOCKERBASEPASS=YOU_PASS_FOR_BASE
```

For example:

```
DOCKERTIMEZONE=Europe/Madrid && DOCKERBASEPASS=totumsuperbasepass
```



Install everything, create a user, set permissions to folders and files (do it completely unchanged):

```
apt update && apt -y install git nano htop && apt update && apt -y install ca-certificates curl gnupg lsb-release && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && apt-get update && apt-get -y install docker-ce docker-ce-cli containerd.io && curl -L "https://github.com/docker/compose/releases/download/v2.2.2/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && useradd -s /bin/bash -m totum && groupadd -g 201608 totum_d && groupadd -g 201609 totum_c && usermod -aG 201608 totum  && usermod -aG 201609 totum && usermod -aG docker totum && git clone https://github.com/totumonline/totum-mit-docker.git /home/totum/totum-mit-docker && chown totum:totum /home/totum/totum-mit-docker && cd /home/totum/totum-mit-docker && chown -R 201609:201609 . && chmod 777 ./exim_log && chown -R 201608:201608 ./totum && chmod 600 .env && sed -i "s:Europe/London:${DOCKERTIMEZONE}:g" /home/totum/totum-mit-docker/.env /home/totum/totum-mit-docker/nginx_fpm_conf/totum_fpm.conf && sed -i "s:TotumBasePass:${DOCKERBASEPASS}:g" /home/totum/totum-mit-docker/.env && docker-compose up -d
```



#### Configure Totum:

- open the `url` (if you did not connect the `url` - `ip` server) that you addressed to this server in your browser;

- fill in:

    - installation language;

    - database password (if you changed it);

    - totum superuser password, which will be created during installation;

    - totum superuser email;

    - click Create;

From now on you can use Totum by `http` to your domain or by `ip`.

#### Important:

If you have not yet addressed the domain, you can open totem in the browser by server `IP` and do the installation, but in this case, after you connect the domain you will need:

- open `nano /home/totum/totum-mit-docker/totum/Conf.php` 

    - find and replace the IP with the domain address `78.98.345.12` `>` `totum.monster`

- if you downloaded files rename the folder (replace `YOU_IP` and `YOU_DOMAIN`):

```
mv /home/totum/totum-mit-docker/totum/fls/YOU_IP  /home/totum/totum-mit-docker/totum/fls/YOU_DOMAIN
```

For example:

```
mv /home/totum/totum-mit-docker/totum/fls/78.98.345.12  /home/totum/totum-mit-docker/totum/fls/totum.monster
```



### Create and connect a free SSL certificate

**Can only be gotten if you address a working domain!**

Replace `YOU_EMAIL` and `YOU_DOMAIN` with yours and execute:

```
CERTBOTEMAIL=YOU_EMAIL && CERTBOTDOMAIN=YOU_DOMAIN
```

For example:

```
CERTBOTEMAIL=totum@totum.online && CERTBOTDOMAIN=totum.monster
```


Now run (execute completely unchanged):

```
CONTAINERID=$(docker ps -f name=ttm-totum --quiet) && docker exec -i $CONTAINERID sudo certbot register --email $CERTBOTEMAIL --agree-tos --no-eff-email && docker exec -i $CONTAINERID sudo certbot certonly -d $CERTBOTDOMAIN && SSLDOMAIN=$(find /home/totum/totum-mit-docker/certbot/etc_letsencrypt/live/* -type d) && SSLDOMAIN=$(basename $SSLDOMAIN) && sed -i "s:YOU_DOMAIN:${SSLDOMAIN}:g" /home/totum/totum-mit-docker/nginx_fpm_conf/totum_nginx_SSL.conf && echo "SSLON=_SSL" >> /home/totum/totum-mit-docker/.env && cd /home/totum/totum-mit-docker/ && docker-compose up --force-recreate -d
```


### DKIM for letters

In order to send emails signed by a domain certificate, do the following (completely unchanged):

```
cd /home/totum/totum-mit-docker/dkim && openssl genrsa -out private.pem 1024 && openssl rsa -pubout -in private.pem -out public.pem && openssl pkey -in private.pem -out domain.key && chmod 644 domain.key && chown -R 201609:201609 domain.key && cat public.pem | tr -d '\n' > key_for_dkim.txt && sed -i "s:-----BEGIN PUBLIC KEY-----::g" key_for_dkim.txt && sed -i "s:-----END PUBLIC KEY-----::g" key_for_dkim.txt && DKIMKEY=$(cat key_for_dkim.txt) && echo -e "\nReplace YOU_DOMAIN and add TXT record for you domain:\n\nmail._domainkey.YOU_DOMAIN.\n\nv=DKIM1; k=rsa; t=s; p=PUBLIC_KEY\n\nReplace YOU_SERVER_IP and add TXT record for SPF:\n\nv=spf1 ip4:YOU_SERVER_IP ~all\n\n" > TXT_record_for_domain.txt && sed -i "s:PUBLIC_KEY:${DKIMKEY}:g" TXT_record_for_domain.txt && cat TXT_record_for_domain.txt && cd /home/totum/totum-mit-docker/ && docker-compose up --force-recreate -d
```

Next, you need to add two TXT records for your domain according to the instructions on screen 👆

**Most hosts have port 25 for sending emails blocked by default to combat spam - check with your hoster's support to see what you need to do to get them to unblock your emails.**


### How to get inside the container to access the Totum console utility

Execute:

```
CONTAINERID=$(docker ps -f name=ttm-totum --quiet) && docker exec -ti $CONTAINERID /bin/bash
```

View console utility commands:

```
bin/totum list
```

To get out:

```
exit
```