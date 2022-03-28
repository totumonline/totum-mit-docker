#!/bin/bash



if [[ $(ps aux | grep -i apt | wc -l) -ne 1 ]]
then
  echo
  echo "THIS SERVER IS NOW INSTALLING SOMETHING, WAIT 5 MIN AND TRY AGAIN"
  echo
  exit 0
else
  echo
  echo "Let's go..."
  echo
fi


echo "                                             "
echo "           ..       .*:-.                    "
echo "          -*:-.     -+*:.   .*:-.            "
echo "          -+*:-     -**:.   :+*-.            "
echo "          .++*-.    -*:-.   :**-.      ..-.  "
echo "           :+*:.    -**:.   **:-.     .:::-  "
echo "           .*+**.   :**:.  .++:-     .***:   "
echo "            ***:-.  ::::.  -:::-    .:-::.   "
echo " ::--.      .*++::. :*::. -*::-.  .-*+**.    "
echo " -+:--.      .+:::-:::---:**+:. .::::::.     "
echo "  **:-.       *+***::*::*:-::::::-+**-       "
echo "  -+*:--.    .*::-------::::::::**+-         "
echo "   -++:--------:-----------------::          "
echo "    .++*::-----------------------::          "
echo "     .*++***:--------------------::          "
echo "       -+++++*::::::::**::::---:**:          "
echo "          -*+++++++++++*+++:::-:**.          "
echo "            .*+++++++++***+++****:           "
echo "               -++++++++***++++++.           "
echo "                *++++++*++++++++:            "
echo "                :++++++*++***+++-            "
echo "                -+*++++++++***+*:            "
echo "                -**+**+***+***+*:            "
echo "                -******::****:**:            "
echo
echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo
echo "This install script will help you to install Totum online on clean Ubuntu 20.04 with SSL certificate and DKIM."
echo
echo "For sucsess you have to delegate a valid domain to this server."
echo
echo "If you not shure about you domain — cansel this install and check: ping YOU_DOMAIN"
echo
echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo

read -p "If you ready to go type (A) or cancel Cntrl + C and check you domain with ping: " TOTUMRUN

if [[ $TOTUMRUN = "A" ]]
then
echo
echo "Started"
echo
elif [[ $TOTUMRUN = "a" ]]
then
echo
echo "Started"
echo
else
echo
  exit 0
fi

DOCKERTIMEZONE=$(tzselect)

read -p "Enter pass for database: " DOCKERBASEPASS

read -p "Enter you email: " CERTBOTEMAIL

read -p "Enter Totum superuser pass: " TOTUMADMINPASS

read -p "Enter domain without http/https delegated! to this server like totum.online: " CERTBOTDOMAIN

echo
echo "1) EN"
echo "2) RU"
echo

read -p "Select language: " TOTUMLANG

if [[ $TOTUMLANG -eq 1 ]]
then
  TOTUMLANG=en
elif [[ $TOTUMLANG -eq 2 ]]
then
  TOTUMLANG=ru
else
  TOTUMLANG=en
fi

echo
echo "- - - - - - - - - - - - - - - - - - - - - -"
echo
echo -e "\033[1mCheck you settings:\033[0m"
echo
echo -e "\033[1mTimezone:\033[0m " $DOCKERTIMEZONE
echo
echo -e "\033[1mPass for database:\033[0m "$DOCKERBASEPASS
echo
echo -e "\033[1mEmail:\033[0m " $CERTBOTEMAIL
echo
echo -e "\033[1mPass for Totum admin:\033[0m " $TOTUMADMINPASS
echo
echo -e "\033[1mDomain:\033[0m " $CERTBOTDOMAIN
echo
echo -e "\033[1mLang:\033[0m " $TOTUMLANG
echo
echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo

read -p "If you ready to install with this params type (A) or cancel Cntrl + C: " TOTUMRUN2

if [[ $TOTUMRUN2 = "A" ]]
then
echo
echo "Star installation"
echo
elif [[ $TOTUMRUN2 = "a" ]]
then
echo
echo "Start installation"
echo
else
echo
  exit 0
fi

# Prepare

apt update
apt -y install git nano htop
apt update
apt -y install ca-certificates curl gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get -y install docker-ce docker-ce-cli containerd.io
curl -L "https://github.com/docker/compose/releases/download/v2.2.2/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
useradd -s /bin/bash -m totum
groupadd -g 201608 totum_d
groupadd -g 201609 totum_c
usermod -aG 201608 totum
usermod -aG 201609 totum
usermod -aG docker totum
git clone https://github.com/totumonline/totum-mit-docker.git /home/totum/totum-mit-docker
chown totum:totum /home/totum/totum-mit-docker
cd /home/totum/totum-mit-docker
chown -R 201609:201609 .
chmod 777 ./exim_log
chown -R 201608:201608 ./totum
chmod 600 .env
sed -i "s:Europe/London:${DOCKERTIMEZONE}:g" /home/totum/totum-mit-docker/.env /home/totum/totum-mit-docker/nginx_fpm_conf/totum_fpm.conf
sed -i "s:TotumBasePass:${DOCKERBASEPASS}:g" /home/totum/totum-mit-docker/.env
docker-compose up -d

echo
echo "Wait 10 sec..."
sleep 1
echo "Wait 9 sec..."
sleep 1
echo "Wait 8 sec..."
sleep 1
echo "Wait 7 sec..."
sleep 1
echo "Wait 6 sec..."
sleep 1
echo "Wait 5 sec..."
sleep 1
echo "Wait 4 sec..."
sleep 1
echo "Wait 3 sec..."
sleep 1
echo "Wait 2 sec..."
sleep 1
echo "Wait 1 sec..."
sleep 1
echo "Wait 0 sec..."
sleep 1
echo



# Install Totum in Docker

CONTAINERID=$(docker ps -f name=ttm-totum --quiet)
docker exec -i $CONTAINERID bin/totum install --pgdump=pg_dump --psql=psql -e -- $TOTUMLANG multi totum $CERTBOTEMAIL $CERTBOTDOMAIN admin $TOTUMADMINPASS totum ttm-postgres totum $DOCKERBASEPASS

# Obtain SSL cert 

docker exec -i $CONTAINERID sudo certbot register --email $CERTBOTEMAIL --agree-tos --no-eff-email
docker exec -i $CONTAINERID sudo certbot certonly -d $CERTBOTDOMAIN && SSLDOMAIN=$(find /home/totum/totum-mit-docker/certbot/etc_letsencrypt/live/* -type d)
SSLDOMAIN=$(basename $SSLDOMAIN)
sed -i "s:YOU_DOMAIN:${SSLDOMAIN}:g" /home/totum/totum-mit-docker/nginx_fpm_conf/totum_nginx_SSL.conf
echo "SSLON=_SSL" >> /home/totum/totum-mit-docker/.env

# Create DKIM

cd /home/totum/totum-mit-docker/dkim
openssl genrsa -out private.pem 1024 && openssl rsa -pubout -in private.pem -out public.pem
openssl pkey -in private.pem -out domain.key
chmod 644 domain.key
chown -R 201609:201609 domain.key
cat public.pem | tr -d '\n' > key_for_dkim.txt
sed -i "s:-----BEGIN PUBLIC KEY-----::g" key_for_dkim.txt
sed -i "s:-----END PUBLIC KEY-----::g" key_for_dkim.txt
DKIMKEY=$(cat key_for_dkim.txt)
echo -e "\nReplace YOU_DOMAIN and add TXT record for you domain:\n\nmail._domainkey.YOU_DOMAIN.\n\nv=DKIM1; k=rsa; t=s; p=PUBLIC_KEY\n\nReplace YOU_SERVER_IP and add TXT record for SPF:\n\nv=spf1 ip4:YOU_SERVER_IP ~all\n\nMost hosts have port 25 for sending emails blocked by default to combat spam - check with your hoster's support to see what you need to do to get them to unblock your emails.\n\n" > TXT_record_for_domain.txt
sed -i "s:PUBLIC_KEY:${DKIMKEY}:g" TXT_record_for_domain.txt


echo
echo "- - - - - - - - - - - - - - - - - - - - - - -"
echo "IMPORTANT!"

cat TXT_record_for_domain.txt

echo "- - - - - - - - - - - - - - - - - - - - - - -"

# Add launch docker at startup

echo -e "$(crontab -l)\n@reboot cd /home/totum/totum-mit-docker && docker-compose up -d" | crontab -u root -


# Clear env

DOCKERBASEPASS=null
TOTUMADMINPASS=null

# Start containers

cd /home/totum/totum-mit-docker/
docker-compose up --force-recreate -d

# Final text

echo
echo "NOW YOU CAN OPEN YOU BROWSER AT https://"$CERTBOTDOMAIN
echo
echo "LAUNCH DOCKER CONTAINERS ADDED TO CRONTAB AT SYSTEM STARTUP"
echo
