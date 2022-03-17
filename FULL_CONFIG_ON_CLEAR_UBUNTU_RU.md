### Установим `docker` и `docker-compose` и необходимые пакеты:

```
apt update && apt -y install software-properties-common git nano htop && apt update && apt -y install ca-certificates curl gnupg lsb-release && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && apt-get update && apt-get -y install docker-ce docker-ce-cli containerd.io && curl -L "https://github.com/docker/compose/releases/download/v2.2.2/docker-compose-linux-x86_64" -o /usr/local/bin/docker-compose && chmod +x /usr/local/bin/docker-compose
```



### Создаем пользователя и перейдем в него

Добавляем пользователя  `totum` и добавим рабочие группы контейнеров и назначим пользователю эти группы, а также `sudo` и `docker` (введите пароль для этого пользователя, запомните пароль):

```
useradd -s /bin/bash -m totum && groupadd -g 201608 totum_d && groupadd -g 201609 totum_c && usermod -aG 201608 totum  && usermod -aG 201609 totum && usermod -aG sudo totum && usermod -aG docker totum && passwd totum && su totum
```



### Устанавливаем Totum

Копируем файлы с `git`:

```
cd ~ && git clone https://github.com/totumonline/totum-mit-docker.git && cd totum-mit-docker && sudo chown -R 201609:201609 . && sudo chmod 777 ./exim_log && sudo chown -R 201608:201608 ./totum
```



Изменить часовой пояс (4 места) и пароль БД в `docker-compose.yml`:

```
nano docker-compose.yml
```

А также в файле `totum_fpm.conf`:

```
nano nginx_fpm_conf/totum_fpm.conf
```



Запускаем:

```
docker-compose up -d
```



**Конфигурируем Totum:**

— откройте url, который вы адресовали на этот сервер в браузере;

— заполните:

— -- язык установки

— -- пароль базы (если меняли)

— -- пароль суперпользователя totum, который будет создан при установке

— -- email суперпользователя totum

— -- жмем Создать

С этого момента можно использовать по `http`.



### Подключаем letsencrypt-ssl (опционально)

Узнаем номер контейнера totum:

```
docker container ps

# copy CONTAINER ID where IMAGE is ttmonline/totum-mit:***
```



Переходим в контейнер (замените `CONTAINER_ID` на ваш `id` скопированный на предыдущем шаге):

```
docker exec -ti CONTAINER_ID /bin/bash
```



Вызываем скрипт регистрирующий ваш `certbot` (замените `YOU_EMAIL` на ваш email):

```
sudo certbot register --email YOU_EMAIL

# it is need to answer A and N to next two questions
```



Проверяем получение сертификата в холостом режиме (замените `YOU_DOMAIN` на ваш домен):

```
sudo certbot certonly --dry-run -d YOU_DOMAIN
```

В случае успешного выполнения вы должны увидеть:

```
IMPORTANT NOTES:
 - The dry run was successful.
 - Your account credentials have been saved in your Certbot
   configuration directory at /etc/letsencrypt. You should make a
   secure backup of this folder now. This configuration directory will
   also contain certificates and private keys obtained by Certbot so
   making regular backups of this folder is ideal.
```



Получаем сертификат в рабочем режиме (замените `YOU_DOMAIN` на ваш домен):

```
sudo certbot certonly -d YOU_DOMAIN
```

В случае успешного выполнения должны увидеть:

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



Выходим из контейнера:

```
exit
```



### Подключаем сертификат (если выполнили предыдущий раздел)

Останавливаем docker-compose:

```
docker-compose stop
```



Редактируем конфиг nginx (замените внутри `YOU_DOMAIN` на ваш домен в адресах сертификата в строках 9-11):

```
nano ./nginx_fpm_conf/totum_nginx_SSL.conf
```



Подключаем конфиг `nginx` для `ssl`, заменим в `docker-compose.yml`:

```
nano docker-compose.yml

# change totum_nginx.conf on totum_nginx_SSL.conf in row 12
```



Стартуем `docker-compose`:

```
docker-compose up -d
```



### Что бы добавить домен в сертификат

Узнаем номер контейнера totum:

```
docker container ps

# copy CONTAINER ID where IMAGE is ttmonline/totum-mit:***
```

Переходим в контейнер (замените `CONTAINER_ID` на ваш `id` скопированный на предыдущем шаге):

```
docker exec -ti CONTAINER_ID /bin/bash
```



Выполняем: 

```
sudo certbot certonly --expand -d YOU_DOMAIN,SECOND_DOMAIN,THIRD_DOMAIN
```

Обязательно должны быть перечислены вссе домены в сертификате, первым должен быть основной домен на который сертификат получен первым!



Выходим из контейнера:

```
exit
```



Что бы посмотреть список всех доменов в сертификатах:

```
su root

cat ./certbot/etc_letsencrypt/live/*/cert.pem | openssl x509 -text | grep -o 'DNS:[^,]*' | cut -f2 -d:
```




### Подключаем DKIM (опционально)

Переходим в папку `dkim`:

```
cd dkim
```



Создаем новый сертификат взамен сертификата по умолчанию:

```
sudo openssl genrsa -out private.pem 1024 && sudo openssl rsa -pubout -in private.pem -out public.pem && sudo openssl pkey -in private.pem -out domain.key && sudo chmod 644 domain.key && sudo chown -R 201609:201609 domain.key
```

Смотрим публичный ключ сертификата:

```
sudo cat public.pem

-----BEGIN PUBLIC KEY-----
!COPY TEXT ONLY FROM THIS LIKE MIGfMA0G....KwIDAQAB END DELETE LINE BREAKES!
-----END PUBLIC KEY-----


```



Перезапускаем `docker-compose`:

```
cd ..

docker-compose stop

docker-compose up -d
```





Идем в управление `DNS` вашего домена и добавляем `TXT` запись:

Название (замените `HOST` на тот хост с которого будут отправлятся письма )

```
mail._domainkey.HOST.
```

Содержимое (замените `PUBLIC_KEY` на текст скопированный из сертификата удалив переносы строк)

```
v=DKIM1; k=rsa; t=s; p=PUBLIC_KEY
```


### Настраиваем производительность сервера (опционально)

Базово `FPM` в контейнере настроен на 2GB оперативной памяти.

Что бы изменить надо остановить контейнеры. Выполните из папки `totum-mit-docker`:

```
docker-compose stop
```

Открыть `totum_fpm.conf` в папке `nginx_fpm_conf`и отредактировать `pm-параметры`:

```
nano nginx_fpm_conf/totum_fpm.conf
```

В этом же файле изменяются параметры выделяемой для `totum`:

— оперативной памяти — `php_admin_value[memory_limit]`

— максимальный размер загружаемого файла — `php_admin_value[upload_max_filesize]`

> при изменении максимального размера фийла необходимо также изменить параметр `client_max_body_size` в файле настроек nginx `nginx_fpm_conf/totum_nginx.conf`

Сохраняем и запускаем `docker-compose`:

```
docker-compose up -d
```