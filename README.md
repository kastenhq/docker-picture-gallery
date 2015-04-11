# docker-picture-gallery
Web based picture gallery for sharing and caring of images - based on lychee!

# Base Docker Image
[mkodockx/docker-supervisor](https://registry.hub.docker.com/u/mkodockx/docker-supervisor/)

# Quickstart

    docker run -it -d -p 80:80 mkodockx/docker-picture-gallery
    
# Volumes

Add volumes for your uploads and for the stored data via '*/uploads/*' and '*/data/*'.

    docker run -it -d -p 80:80 -v /your-path/uploads/:/uploads/ -v /your-path/data/:/data/ kdelfour/lychee-docker

# Database

We integrated a database to make it possible to run out of the box. The main data of the default database (MySql) inside: 

  * url : *localhost*
  * database name : *lychee*
  * user name : *lychee*
  * user password : *lychee*
    
# Thanks

To [kdelfour](https://github.com/kdelfour) for inspiration and ideas.