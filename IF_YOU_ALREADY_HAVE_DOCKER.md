### If you want to install in a production

If you have Docker, Docker-compose, and Git installed and want to install in production, then:

— clone the repository of the docker installation;

— create groups `201608, totum_d` and `201609 totum_c`;

— assign these groups to your system user;

— assign the user of the Totum container and the rights to the cloned directory;

Change `YOU_USER` to your user:

```
sudo groupadd -g 201608 totum_d && sudo groupadd -g 201609 totum_c && usermod -aG 201608,201609 YOU_USER && git clone https://github.com/totumonline/totum-mit-docker.git && cd totum-mit-docker && sudo chown -R 201609:201609 . && sudo chmod 777 ./exim_log && sudo chown -R 201608:201608 ./totum
```



Open `docker-compose.yml` and set the time zone of the containers and replace the database password `TotumBasePass` with your own arbitrary password:

```
nano docker-compose.yml
```

The time zone is also changed in the file `totum_fpm.conf`:

```
nano nginx_fpm_conf/totum_fpm.conf
```



After that we start the containers:

```
docker-compose up -d
```



Configuring Totum:

— open the url you addressed to this server in your browser;

— fill in:

— -- installation language

— -- database password (if changed)

— -- totum superuser password, which will be created during installation

— -- totum superuser email

— -- Click Create

From now on you can use it via `http`.



### Connect letsencrypt-ssl (optional)

Get the number of the totum container:

```
docker container ps

# copy CONTAINER ID where IMAGE is ttmonline/totum-mit:***
```



Go to the container (replace `CONTAINER_ID` with your `id` copied in the previous step):

```
docker exec -ti CONTAINER_ID /bin/bash
```



Call the script that registers your `certbot` (replace `YOU_EMAIL` with your email):

```
sudo certbot register --email YOU_EMAIL

# it is need to answer A and N to next two questions
```



Check that the certificate is received in idle mode (replace `YOU_DOMAIN` with your domain):

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



Exit the container:

```
exit
```



### Connect the certificate (if you have completed the previous section)

Stop docker-compose:

```
docker-compose stop
```



Edit the nginx config (replace `YOU_DOMAIN` inside with your domain in the certificate addresses on lines 9-11):

```
nano ./nginx_fpm_conf/totum_nginx_SSL.conf
```



Connect config `nginx` for `ssl`, replace in `docker-compose.yml`:

```
nano docker-compose.yml

# change totum_nginx.conf on totum_nginx_SSL.conf in row 12
```



Start `docker-compose`:

```
docker-compose up -d
```



### To add a domain to the certificate

Get the number of the totum container:

```
docker container ps

# copy CONTAINER ID where IMAGE is ttmonline/totum-mit:***
```

Go to the container (replace `CONTAINER_ID` with your `id` copied in the previous step):

```
docker exec -ti CONTAINER_ID /bin/bash
```



Run: 

```
sudo certbot certonly --expand -d YOU_DOMAIN,SECOND_DOMAIN,THIRD_DOMAIN
```

All domains in the certificate must be listed, the first must be the primary domain for which the certificate was received first!



Exit the container:

```
exit
```



To see a list of all domains in certificates:

```
su root

cat ./certbot/etc_letsencrypt/live/*/cert.pem | openssl x509 -text | grep -o 'DNS:[^,]*' | cut -f2 -d:
```




### Connect the DKIM (optional)

Go to the `dkim` folder:

```
cd dkim
```



Create a new certificate to replace the default one:

```
sudo openssl genrsa -out private.pem 1024 && sudo openssl rsa -pubout -in private.pem -out public.pem && sudo openssl pkey -in private.pem -out domain.key && sudo chmod 644 domain.key && sudo chown -R 201609:201609 domain.key
```

Check the public key of the certificate:

```
sudo cat public.pem

-----BEGIN PUBLIC KEY-----
!COPY TEXT ONLY FROM THIS LIKE MIGfMA0G....KwIDAQAB END DELETE LINE BREAKES!
-----END PUBLIC KEY-----


```



Restart `docker-compose`:

```
cd ..

docker-compose stop

docker-compose up -d
```



Go to the `DNS` management of your domain and add a `TXT` entry:

Title (replace `HOST` with the host from which the emails will be sent)

```
mail._domainkey.HOST.
```

Contents (replace `PUBLIC_KEY` with the text copied from the certificate, removing line breaks)

```
v=DKIM1; k=rsa; t=s; p=PUBLIC_KEY
```


### Configure server performance (optional)

Basically `FPM` in the container is set to 2GB RAM.

To change it, you have to stop the containers. Run from the `totum-mit-docker` folder:

```
docker-compose stop
```

Open `totum_fpm.conf` in the `nginx_fpm_conf` folder and edit the `pm-parameters`:

```
nano nginx_fpm_conf/totum_fpm.conf
```

In the same file the parameters of the allocated for `totum` are changed:

— memory limit — `php_admin_value[memory_limit]`

— maximum download size — `php_admin_value[upload_max_filesize]`

> If you change the maximum size of the fiill, you must also change the parameter `client_max_body_size` in the nginx configuration file `nginx_fpm_conf/totum_nginx.conf`

Save and run `docker-compose`:

```
docker-compose up -d
```
