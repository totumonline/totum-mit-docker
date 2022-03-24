## Установка на чистую Ubuntu 20.04 в автоматическом режиме (рассчитано на минимальную квалификацию)

#### Если вам нужен пошаговый разбор действий выполняемых в этой инструкции — [смотрите здесь](https://github.com/totumonline/totum-mit-docker/blob/main/FULL_CONFIG_ON_CLEAR_UBUNTU_RU.md)


Зарегистрируйте домен и направьте его на `ip` вашего сервера. В крайнем случае можно установить без использования домена открыв по `ip` сервера. Также вы можете использовать домены 3 и 4 уровня.



Удостоверьтесь, что ваш сервер ничего не устанавливает и не обновляет например выполнив:

```
ps aux | grep -i apt
```

В ответе должна быть только одна строка!



Определите нужный вам часовой пояс `tzselect`:

```
tzselect
```

1. Вы должны ввести номер области и нажать Enter. Затем появится список стран.
2. Аналогично, нужно ввести номер страны.
3. Появится список городов. Вводим номер города.
4. В результате вы сможете увидеть название вашей временной зоны.



Устанавливаем переменные, замените `YOU_TIMEZONE` и `YOU_PASS_FOR_BASE` на ваши и выполните:

```
DOCKERTIMEZONE=YOU_TIMEZONE && DOCKERBASEPASS=YOU_PASS_FOR_BASE
```

Например:

```
DOCKERTIMEZONE=Europe/Madrid && DOCKERBASEPASS=totumsuperbasepass
```



Устанавливаем все, создаем пользователя, настраиваем права папкам и файлам (выполняем полностью без изменений):

```
apt update && apt -y install git nano htop && apt update && apt -y install ca-certificates curl gnupg lsb-release && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && apt-get update && apt-get -y install docker-ce docker-ce-cli containerd.io && curl -L "https://github.com/docker/compose/releases/download/v2.2.2/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose && useradd -s /bin/bash -m totum && groupadd -g 201608 totum_d && groupadd -g 201609 totum_c && usermod -aG 201608 totum  && usermod -aG 201609 totum && usermod -aG docker totum && git clone https://github.com/totumonline/totum-mit-docker.git /home/totum/totum-mit-docker && chown totum:totum /home/totum/totum-mit-docker && cd /home/totum/totum-mit-docker && chown -R 201609:201609 . && chmod 777 ./exim_log && chown -R 201608:201608 ./totum && chmod 600 .env && sed -i "s:Europe/London:${DOCKERTIMEZONE}:g" /home/totum/totum-mit-docker/.env /home/totum/totum-mit-docker/nginx_fpm_conf/totum_fpm.conf && sed -i "s:TotumBasePass:${DOCKERBASEPASS}:g" /home/totum/totum-mit-docker/.env && docker-compose up -d
```



#### Конфигурируем Totum:

- откройте `url` (если не подключали `url` — `ip` сервера), который вы адресовали на этот сервер в браузере;

- заполните:

    - язык установки;

    - пароль базы (если меняли);

    - пароль суперпользователя totum, который будет создан при установке;

    - email суперпользователя totum;

    - жмем Создать;

С этого момента можно использовать по `http` по вашему домену или по `ip`.

#### Важно:

Если вы еще не адресовали домен, то можно открыть в браузере по `IP` сервера и выполнить установку, но в этом случае после того как вы подключите домен вам нужно будет:

- открыть `nano /home/totum/totum-mit-docker/totum/Conf.php` 

    - найти и заменить IP на адрес домена `78.98.345.12` `>` `totum.monster`

- если вы загружали файлы переименовать папку (замените `YOU_IP` и `YOU_DOMAIN`):

```
mv /home/totum/totum-mit-docker/totum/fls/YOU_IP  /home/totum/totum-mit-docker/totum/fls/YOU_DOMAIN
```

Для примера:

```
mv /home/totum/totum-mit-docker/totum/fls/78.98.345.12  /home/totum/totum-mit-docker/totum/fls/totum.monster
```



### Создаем и подключаем бесплатный сертификат SSL

**Можно получить только если вы адресовали работающий домен!**

Замените `YOU_EMAIL` и `YOU_DOMAIN` на ваши и выполните:

```
CERTBOTEMAIL=YOU_EMAIL && CERTBOTDOMAIN=YOU_DOMAIN
```

Например:

```
CERTBOTEMAIL=totum@totum.online && CERTBOTDOMAIN=totum.monster
```


Теперь выполняем (выполняем полностью без изменений):

```
CONTAINERID=$(docker ps -f name=ttm-totum --quiet) && docker exec -i $CONTAINERID sudo certbot register --email $CERTBOTEMAIL --agree-tos --no-eff-email && docker exec -i $CONTAINERID sudo certbot certonly -d $CERTBOTDOMAIN && SSLDOMAIN=$(find /home/totum/totum-mit-docker/certbot/etc_letsencrypt/live/* -type d) && SSLDOMAIN=$(basename $SSLDOMAIN) && sed -i "s:YOU_DOMAIN:${SSLDOMAIN}:g" /home/totum/totum-mit-docker/nginx_fpm_conf/totum_nginx_SSL.conf && echo "SSLON=_SSL" >> /home/totum/totum-mit-docker/.env && cd /home/totum/totum-mit-docker/ && docker-compose up --force-recreate -d
```


### DKIM для писем

Для того, что бы письма отправлялись подписанные сертификатом домена выполните (выполняем полностью без изменений):

```
cd /home/totum/totum-mit-docker/dkim && openssl genrsa -out private.pem 1024 && openssl rsa -pubout -in private.pem -out public.pem && openssl pkey -in private.pem -out domain.key && chmod 644 domain.key && chown -R 201609:201609 domain.key && cat public.pem | tr -d '\n' > key_for_dkim.txt && sed -i "s:-----BEGIN PUBLIC KEY-----::g" key_for_dkim.txt && sed -i "s:-----END PUBLIC KEY-----::g" key_for_dkim.txt && DKIMKEY=$(cat key_for_dkim.txt) && echo -e "\nReplace YOU_DOMAIN and add TXT record for you domain:\n\nmail._domainkey.YOU_DOMAIN.\n\nv=DKIM1; k=rsa; t=s; p=PUBLIC_KEY\n\nReplace YOU_SERVER_IP and add TXT record for SPF:\n\nv=spf1 ip4:YOU_SERVER_IP ~all\n\n" > TXT_record_for_domain.txt && sed -i "s:PUBLIC_KEY:${DKIMKEY}:g" TXT_record_for_domain.txt && cat TXT_record_for_domain.txt && cd /home/totum/totum-mit-docker/ && docker-compose up --force-recreate -d
```

Далее вам нужно добавить две TXT записи для вашего домена согласно инструкции на экране 👆

**У большинства хостеров 25 порт для отправки писем по умолчанию заблокирован для борьбы со спамом — уточните у поддержки хостура, что вам нужно сделать, что бы они разблокировали вам отправку писем.**


### Как попасть внутрь контейнера для доступа к консольной утилите Totum

Выполните:

```
CONTAINERID=$(docker ps -f name=ttm-totum --quiet) && docker exec -ti $CONTAINERID /bin/bash
```

Посмотреть команды консольной утилиты:

```
bin/totum list
```

Что бы выйти:

```
exit
```

