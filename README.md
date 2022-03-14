#### If you want this on RU — [README_RU](https://github.com/totumonline/totum-mit-docker/blob/main/README_RU.md)

This Docker container is designed for users with minimal qualifications. We tried to pack everything you need to run Totum with as much security as possible. Because we wanted to take care of all possible usage scenarios for non-programmers, we didn't do any super-optimization inside this image. If this approach isn't for you and you're skilled in Docker, you can make your own image for your specific task.


### If you want a quick look

If you have Docker, Docker-compose, and Git installed and want to give it a try, then:

— clone the repository of the docker installation;

— assign 777 to all folders and 666 to all files, since the container runs from user uid 201608:201608 and 201609:201609

```
git clone https://github.com/totumonline/totum-mit-docker.git && cd totum-mit-docker && sudo find . -type d -exec chmod 777 {} \; && sudo find . -type f -exec chmod 666 {} \;
```



Start Docker-compose:

```
docker-compose up -d
```



Open the browser on localhost, select the installation language and fill in the Create a Totum superuser section:

— password to be used for the Totum superuser

— your Email for Cron notifications (not sent anywhere, it will be written in the config)

— After filling in, click Create config and fill in the scheme

**Wait, follow the link, it's done!**



#### If you already have Docker and you want to make a full config — [look at this](https://github.com/totumonline/totum-mit-docker/blob/main/IF_YOU_ALREADY_HAVE_DOCKER.md)



#### If you have a clear system and you want to make a full config — [look at this](https://github.com/totumonline/totum-mit-docker/blob/main/FULL_CONFIG_ON_CLEAR_UBUNTU.md)


