## If you have installed for a quick view and now you need to reconfigure the totum to use


Create groups `201608, totum_d` and `201609 totum_c`, assign these groups to your system user, assign the totum container user and rights to the cloned directory.

Replace `YOU_USER` with your user and run from the `totum-mit-docker` directory:

```
sudo groupadd -g 201608 totum_d && sudo groupadd -g 201609 totum_c && usermod -aG 201608,201609 YOU_USER && sudo chown -R 201609:201609 . && sudo chmod 777 ./exim_log && sudo chown -R 201608:201608 ./totum && chmod 600 .env
```



### Configuring the Totum


Change the time zone and database password in `.env`:

```
sudo nano .env
```

And also in the file `totum_fpm.conf`:

```
nano nginx_fpm_conf/totum_fpm.conf
```

Time zones can be viewed by executing `tzselect`.


#### Configure Totum:

Delegate your domain.

Open the Totum config file and change the base password and email for the notification cron (if you specified a random one), and also find and replace `localhost` (or `ip`) with the domain.

For example: `70.145.23.56` `>` `totum.monster`:

```
nano /home/totum/totum-mit-docker/totum/Conf.php
```

- if you downloaded files rename the folder (replace `YOU_IP` and `YOU_DOMAIN`):

```
mv /home/totum/totum-mit-docker/totum/fls/YOU_IP  /home/totum/totum-mit-docker/totum/fls/YOU_DOMAIN
```

For example:

```
mv /home/totum/totum-mit-docker/totum/fls/78.98.345.12  /home/totum/totum-mit-docker/totum/fls/totum.monster
```

If you installed by `localhost` then instead of `ip` it will be `localhost`.


Run:

```
docker-compose up -d
```


### Connect letsencrypt-ssl (optional)

Get the number of the totum container:

```
docker container ps
```

Copy CONTAINER ID where IMAGE is ttmonline/totum-mit:***


Go to the container (replace `CONTAINER_ID` with your `id` copied in the previous step):

```
docker exec -ti CONTAINER_ID /bin/bash
```


Call the script that registers your `certbot` (replace `YOU_EMAIL` with your email):

```
sudo certbot register --email YOU_EMAIL
```

Answer questions `A` and `N`.



Test the certificate in test mode (replace `YOU_DOMAIN` with your domain):

```
sudo certbot certonly --dry-run -d YOU_DOMAIN
```

If successful, you should see:

```
IMPORTANT NOTES:
 - The dry run was successful.
 - Your account credentials have been saved in your Certbot
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.
```



Get a certificate in working mode (replace `YOU_DOMAIN` with your domain):

```
sudo certbot certonly -d YOU_DOMAIN
```

If successful, you should see:

```
- Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/ubuntu.totum.online/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/ubuntu.totum.online/privkey.pem
   Your cert will expire on 2022-06-07. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot
   again. To non-interactively renew *all* of your certificates, run
   "certbot renew"
```



Exiting the container:

```
exit
```



### Connect the certificate (if you have completed the previous section)

Stop docker-compose:

```
docker-compose stop
```



Edit the nginx config (replace `YOU_DOMAIN` inside with your domain in the certificate addresses in lines `9-11`):

```
nano ./nginx_fpm_conf/totum_nginx_SSL.conf
```


Connect config `nginx` for `ssl`, replace in `.env`. Add the line `SSLON=_SSL` to the end and save it:

```
sudo nano .env
```


Start `docker-compose`:

```
docker-compose up -d
```



### To add a domain to the certificate

Get the number of the totum container:

```
docker container ps
```

Copy `CONTAINER ID` where `IMAGE` is `ttmonline/totum-mit:***`


Go to the container (replace `CONTAINER_ID` with your `id` copied in the previous step):

```
docker exec -ti CONTAINER_ID /bin/bash
```


Run: 

```
sudo certbot certonly --expand -d YOU_DOMAIN,SECOND_DOMAIN,THIRD_DOMAIN
```

All domains in the certificate must be listed, the first must be the primary domain for which the certificate was gotten first!



Exiting the container:

```
exit
```


To see a list of all domains in the certificate:

```
su root && cat ./certbot/etc_letsencrypt/live/*/cert.pem | openssl x509 -text | grep -o 'DNS:[^,]*' | cut -f2 -d:
```




### Connecting the DKIM (optional)

Go to the `dkim` folder:

```
cd dkim
```


Create a new certificate to replace the default one:

```
sudo openssl genrsa -out private.pem 1024 && sudo openssl rsa -pubout -in private.pem -out public.pem && sudo openssl pkey -in private.pem -out domain.key && sudo chmod 644 domain.key && sudo chown -R 201609:201609 domain.key
```

Examine the public key of the certificate:

```
sudo cat public.pem
```
```
-----BEGIN PUBLIC KEY-----
!COPY TEXT ONLY FROM THIS LIKE MIGfMA0G....KwIDAQAB END DELETE LINE BREAKES!
-----END PUBLIC KEY-----
```


Go to the `DNS` management of your domain and add a `TXT` record:

Name (replace `HOST` with the host from which the mail will be sent)

```
mail._domainkey.HOST.
```

Contents (replace `PUBLIC_KEY` with the text copied from the certificate, removing line breaks)

```
v=DKIM1; k=rsa; t=s; p=PUBLIC_KEY
```

And also add SPF by replacing `YOU_IP` with your `ip`:

```
v=spf1 ip4:YOU_SERVER_IP ~all
```


Restart `docker-compose`:

```
cd .. && docker-compose stop && docker-compose up -d
```

**Most hosts have port 25 for sending emails blocked by default to combat spam - check with your hoster's support to see what you need to do to get them to unblock your emails.**


### Configure server performance (optional)

Basically `FPM` in the container is set to 2GB RAM.

To change that, you have to stop the containers. Execute from the `totum-mit-docker` folder:

```
docker-compose stop
```

Open `totum_fpm.conf` in the `nginx_fpm_conf` folder and edit the `pm-parameters`:

```
nano nginx_fpm_conf/totum_fpm.conf
```

The same file changes the parameters of the allocated for `totum`:

- RAM - `php_admin_value[memory_limit]`

- maximum size of the uploaded file - `php_admin_value[upload_max_filesize]`

> If you change the maximum file size, you must also change the `client_max_body_size` parameter in the nginx settings file `nginx_fpm_conf/totum_nginx.conf`

Save and run `docker-compose`:

```
docker-compose up -d
```