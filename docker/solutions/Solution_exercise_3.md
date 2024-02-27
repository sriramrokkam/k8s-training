# Solution to Exercise 3 - Ports and Volumes

In this exercise, you will run a _nginx_ webserver in a container and serve a custom website to the outside world.

## Step 0: forward NGINX' port

If you have already deleted it, download the `nginx:mainline` image (or any other tag) again from the trainings registry using `docker pull`.

Start a new container in detached mode and export the port of the _nginx_ webserver to a semi-random port that is chosen by Docker.

```bash
docker run -d -P <image name / ID>
```

Use the `docker ps` command to find you which port the webserver is forwarded to. The result will look like this:

```bash
$ docker ps
CONTAINER ID   IMAGE          COMMAND                  CREATED          STATUS          PORTS                                            NAMES
68978135de52   55ff50397df9   "/docker-entrypoint.…"   19 minutes ago   Up 19 minutes   0.0.0.0:55002->80/tcp, 0.0.0.0:55001->8080/tcp   blissful_cannon
```

In this example, port 80 of the container was forwarded to port 55002 of the Docker host (this number might be different in your case). Port 8080 got mapped to port 55001. Use your web browser again and direct it to
`http://localhost:<your port number>` (so to `http://localhost:55001` in this example). This time you will see your custom landing page that you added to the image.

Stop and remove your container:

```bash
docker stop <container name>
docker rm <containmer name>
```

## Step 1: forward NGINX' to a specified port

Start another _nginx_ container but this time, make sure the exposed port of the webserver is forwarded to port 8080 on your host.

```bash
docker run -d -p 8080:80 <image name/ ID>
```

You can now connect to `http://localhost:8080` with your web browser and see the custom landing page.

Stop and remove your container.

```bash
docker stop <container name>
docker rm <container name>
```

**Hint:** You can use `docker inspect` to find out which port is exposed by the image like this. The exposed port is clearly visible:

```bash
$ docker inspect <container name> | grep -2 ExposedPorts
"AttachStdout": false,
"AttachStderr": false,
"ExposedPorts": {
    "80/tcp": {}
},
--
"AttachStdout": false,
"AttachStderr": false,
"ExposedPorts": {
    "80/tcp": {}
},
```

## Step 2: import a volume

Create a directory on your VM. Inside that directory, create a file `index.html` and put some simple HTML into it.

```bash
$ mkdir `pwd`/nginx-html
$ cat << _EOF > `pwd`/nginx-html/index.html
<html>
<head>
    <title>Custom Website from my container</title>
</head>
<body>
    <h1>This is a custom website.</h1>
    <p>This website is served from my <a href="http://www.docker.com" target="_blank">Docker</a> container.</p>
</body>
</html>
_EOF
```

Start a new container that bind-mounts this directory to `/usr/share/nginx/html` as a volume.

```bash
docker run -d -p 8081:80 --mount type=bind,source=`pwd`/nginx-html,target=/usr/share/nginx/html --name ex23nginx nginx
```

Now use your browser once again to go to `http://localhost:8081` - you will now see the webpage you just created.

Stop and remove your container once you are finished.

```bash
docker stop ex23nginx
docker rm ex23nginx
```
