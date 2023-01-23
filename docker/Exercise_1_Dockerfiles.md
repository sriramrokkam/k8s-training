# Exercise 1 - Images and Dockerfiles

In this exercise, you will build an image with a Dockerfile, tag it and upload it to a registry. You will use the Dockerfile to extend the NGINX image to deliver a custom website that is embedded into the image. The webserver should also listen on port 8080.

## Step 0: Set up a build context

Create an empty directory, change into it and create an empty `Dockerfile`.

We want to copy a custom (yet very simple) website to the image. You can either write your own _index.html_ or you can copy a ready-made website with an image into your build context. The prepared files can be found in the training repository's `docker/res/` subfolder:

```bash
PATH_TO_CLONED_TRAINING_REPO=<anypath>
cp $PATH_TO_CLONED_TRAINING_REPO/docker/res/evil.jpg .
cp $PATH_TO_CLONED_TRAINING_REPO/docker/res/evil.html .
mv evil.html index.html
```

## Step 1: extend an existing image

As we want to extend an existing _nginx_ image, we need to come `FROM` it. It is a good idea to also specify the release number of the image you want to extend, but `nginx:mainline` is a good idea too.

Have a look at [DockerHub](https://hub.docker.com/_/nginx) for possible image tags that you can come from.

## Step 2: copy a new default website into the image

Use the `COPY` directive to the place the custom website files you created or downloaded in Step 1 into the image at `/usr/share/nginx/html`.

## Step 3: create configuration for _nginx_

For nginx to listen on port 8080, you will have to place an additional configuration file into the image.

Create a new file `docker-nginx.conf` inside your build context and paste this into it:

```nginx
server {
    listen       8080;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}
```

**Shortcut:** You can also copy this configuration file from training repository (./docker/res/docker-nginx.conf).

Again, with the help of the `COPY` directive, make sure that this file ends up in your image at `/etc/nginx/conf.d/nginx.conf`.

## Step 4: expose the new HTTP port

The default _nginx_ image only exposes port 80 for unencrypted HTTP. Since we want it to tell the world, we are listening on a different port, we will have to expose port 8080 with the `EXPOSE` directive as well.

## Step 5: build the image

Use the `docker build` command to build the image. Make note of the UID of the new image. Start the image with `docker run`. Since we have not talked about port forwarding yet, for the time being the container should just start without an error (check with `docker logs`).
