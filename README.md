# nginx-rtmp

[**Docker**](https://www.docker.com/) image with [**Nginx**](http://nginx.org/en/) using the [**nginx-rtmp-module**](https://github.com/arut/nginx-rtmp-module) module for live video streaming.

This is an adaptation to the image created by [tiangolo](https://github.com/tiangolo/nginx-rtmp-docker), which was inspired by other similar previous images from [dvdgiessen](https://hub.docker.com/r/dvdgiessen/nginx-rtmp-docker/), [jasonrivers](https://hub.docker.com/r/jasonrivers/nginx-rtmp/), [aevumdecessus](https://hub.docker.com/r/aevumdecessus/docker-nginx-rtmp/) and by an [OBS Studio post](https://obsproject.com/forum/resources/how-to-set-up-your-own-private-rtmp-server-using-nginx.50/).

## Description

The main purpose for this project is to allow streaming from [**OBS Studio**](https://obsproject.com/) to different clients at the same time. This [**Docker**](https://www.docker.com/) image can be used to create an RTMP server for video streaming using [**Nginx**](http://nginx.org/en/) and [**nginx-rtmp-module**](https://github.com/arut/nginx-rtmp-module), built from the following sources: `Nginx 1.15.0` and `nginx-rtmp-module 1.2.1`.

If you wish to use different versions of either component, update the environment variables in this project's [Dockerfile](Dockerfile):

```Dockerfile
# Versions of Nginx and nginx-rtmp-module to use
ENV NGINX_VERSION nginx-1.18.0
ENV NGINX_RTMP_MODULE_VERSION 1.2.1
```

## Testing locally with OBS Studio and VLC

- First you'll need to set up a stream key which will be used as a unique identifier that allows a user to connect to the RTMP and broadcast their video feed
  - I've provided an [`update_stream_keys.sh`](./update_stream_keys.sh) script that you can run to update the key in [`index.html`](./index.html). Simply set an environment variable like so: `export STREAM_KEY_1=some-key`, then run the script to update.
  - If you intend on broadcasting 2 video feeds concurrently, do the same with another variable named `STREAM_KEY_2`
  If these variables aren't set, the default values for each key will be `test-1` and `test-2` respectively

- Build the image and run the container:
```bash
docker build -t nginx-rtmp .
docker run -d -p 1935:1935 -p 8088:8088 nginx-rtmp

# Or with docker-compose
docker compose up -d
```

##### OBS
* Open [OBS Studio](https://obsproject.com/)
* Click the "Settings" button
* Go to the "Stream" section
* In "Stream Type" select "Custom Streaming Server"
* In the "URL" field, enter `rtmp://<ip_of_host>/live` replacing `<ip_of_host>` with the IP of the host in which the container is running. For example: `rtmp://127.0.0.1/live`
* In the "Stream key" field, use a "key" that will be used later in the client URL to display that specific stream. For example: `test`
* Click the "OK" button
* In the section "Sources" click de "Add" button (`+`) and select a source (for example "Screen Capture") and configure it as you need
* Click the "Start Streaming" button

##### VLC
* Open a [VLC](http://www.videolan.org/vlc/index.html) player (it also works in Raspberry Pi using `omxplayer`)
* Click in the "Media" menu
* Click in "Open Network Stream"
* Enter the URL from above as `rtmp://<ip_of_host>/live/<key>` replacing `<ip_of_host>` with the IP of the host in which the container is running and `<key>` with the key you created in OBS Studio. For example: `rtmp://127.0.0.1/live/test`
* Click "Play"
* Now VLC should start playing whatever you are transmitting from OBS Studio

##### RTMP Stats/Restream via web browser
* Open a web browser

* To view RTMP statistics, browse to `http://<ip_of_host>:8080/stat`
* To view the full RTMP stream, browse to `http://<ip_of_host>:8088/hls`
* Replace `<ip_of_host>` above with the IP of the host in which the container is running. For example: `http://127.0.0.1:8080/stat` or `http://127.0.0.1:8088/hls`


## Debugging

If something is not working you can check the logs of the container with:

```bash
docker logs nginx-rtmp
```

## Technical details

* This image is built from the same base official images that most of the other official images, as Python, Node, Postgres, Nginx itself, etc. Specifically, [buildpack-deps](https://hub.docker.com/_/buildpack-deps/) which is in turn based on [debian](https://hub.docker.com/_/debian/). So, if you have any other image locally you probably have the base image layers already downloaded

* It is built from the official sources of **Nginx** and **nginx-rtmp-module** without adding anything else. (Surprisingly, most of the available images that include **nginx-rtmp-module** are made from different sources, old versions or add several other components). Here's the [documentation related to `nginx-rtmp-module`](https://github.com/arut/nginx-rtmp-module/wiki/Directives)

* It has a simple default configuration that should allow you to send one or more streams to it and have several clients receiving multiple copies of those streams simultaneously. (It includes `rtmp_auto_push` and an automatic number of worker processes)
