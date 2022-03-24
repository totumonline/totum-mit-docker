#### If you want this on RU — [README_RU](https://github.com/totumonline/totum-mit-docker/blob/main/README_RU.md)

This Docker container is designed for users with minimal qualifications. We tried to pack everything you need to run Totum with as much security as possible. Because we wanted to take care of all possible usage scenarios for non-programmers, we didn't do any super-optimization inside this image. If this approach isn't for you and you're skilled in Docker, you can make your own image for your specific task.




## If you want a quick look and you have Docker and Docker-compose installed

- clone the repository of the docker installation;

- assign `777` to all folders and `666` to all files, since containers works from user `uid` `201608:201608` and `201609:201609`

```
git clone https://github.com/totumonline/totum-mit-docker.git && cd totum-mit-docker && sudo find . -type d -exec chmod 777 {} \; && sudo find . -type f -exec chmod 666 {} \;
```


Start Docker-compose:

```
docker-compose up -d
```



Open the browser by `ip` or by `localhost` if it is a local machine, choose the installation language and fill in under Create a superuser Totum:

> If port 80 is busy, change `docker-compose.yml` to connect to another port.

- password to be used for the Totum superuser

- your Email for Cron notifications (not sent anywhere, it will be written in the config)

- After filling in, click Create Configure and Fill Scheme

**Wait, click the link, it's done!**



#### If you have looked and want to configure it completely — [see these instructions](https://github.com/totumonline/totum-mit-docker/blob/main/IF_YOU_ALREADY_HAVE_DOCKER_RU.md)



## If you need to configure a clean system: 

- **In automatic mode (designed for minimal skills)** - [watch this instruction for ubuntu + video](https://github.com/totumonline/totum-mit-docker/blob/main/FULL_AUTO_CONFIG_ON_CLEAR_UBUNTU_RU.md)

- In manual mode with explanations - [see this manual for ubuntu](https://github.com/totumonline/totum-mit-docker/blob/main/FULL_CONFIG_ON_CLEAR_UBUNTU_RU.md)

- If you need to configure the system without Docker - [see this instruction for ubuntu + video](https://docs.totum.online/ubuntu)