#### If you want this on RU — [README_RU](https://github.com/totumonline/totum-mit-docker/blob/main/README_RU.md)

Main type of install it is the [installation on Ubuntu](https://github.com/totumonline/totum-mit).

In this Docker-image, we only provide the MIT-version. If you want to switch to the PRO later — use the main installation instead of this Docker.

This Docker container is designed for users with minimal qualifications. We tried to pack everything you need to run Totum with as much security as possible. Because we wanted to take care of all possible usage scenarios for non-programmers, we didn't do any super-optimization inside this image. If this approach isn't for you and you're skilled in Docker, you can make your own image for your specific task.

## If you want full install on clean Ubuntu 20 in auto-mode (designed for zero skills):

**[Video on YouTube —>](https://www.youtube.com/watch?v=ZztzQ53kMQQ)**

**[VULTR referal link —>](https://www.vultr.com/?ref=9084282)**

1. Deploy server;

2. Delegate a valid domain to it;

3. Open the terminal from root and execute:

```
sudo curl -O https://raw.githubusercontent.com/totumonline/totum-mit-docker/main/autoinstall.sh && sudo bash autoinstall.sh
```

4. Follow the on-screen prompts.

5. Open delegated domain and sign in as `admin` and the password you specified at installation.


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



#### If you have looked and want to configure it completely — [see these instructions](https://github.com/totumonline/totum-mit-docker/blob/main/IF_YOU_ALREADY_HAVE_DOCKER.md)



## If you need to configure a clean system in manual mode or without Docker: 

- Docker in manual mode with explanations - [see this manual for ubuntu](https://github.com/totumonline/totum-mit-docker/blob/main/FULL_CONFIG_ON_CLEAR_UBUNTU.md)

- **If you need to configure the system without Docker - [see this instruction for ubuntu + video](https://docs.totum.online/ubuntu)**