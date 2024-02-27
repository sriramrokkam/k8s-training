# Exercise 3 - Ports and Volumes

In this exercise, you will run the _nginx_ webserver image built in exercise 1 to serve a custom website to the outside world.

## Step 0: forward NGINX' port

Start a new `nginx` container and export the ports of the _nginx_ webserver to random ports that are chosen by Docker with the `-P` switch. Since you have exposed 2 ports (80 + 8080) during the image's build process, Docker will create a forwarding to both.

Use the `docker ps` command to find you which ports the webserver is forwarded to and use your web browser to connect to both of them - the result should be the same.

You can use the lengthy image name (with the remote repository's hostname), the short name (`nginx:awesome-<some random characters>`) or the image's ID to run the container.

## Step 1: forward NGINX' to a specified port

In some environments you don't want your webservers to be available on port 80 - which is considered a privileged port - but on some other port like 8080. Therefore, start another `nginx` container but this time, make sure the exposed port 80 of the webserver is forwarded to port 8080 on your host (and ignore port 8080 exposed by the container).

**Hint:** You can use `docker inspect` to find out which port is exposed by the image.

Again, use your web browser to connect to your container via port 8080.

## Step 2: import a volume

Create a directory on your computer. Inside that directory, create a file `index.html` and put some simple HTML into it. Start a new container that bind-mounts this directory to `/usr/share/nginx/html` as a volume so that NGINX will publish your custom HTML file instead of its default message.

**Shortcut:** If you do not want to type your own HTML, just use this:

```html
<html>
<head>
    <title>Custom Website from my container</title>
</head>
<body>
    <h1>This is a custom website.</h1>
    <p>This website is served from my <a href="http://www.docker.com" target="_blank">Docker</a> container.</p>
</body>
</html>
```

**Hint:** the syntax of the `--mount` switch is

```shell
--mount type=bind,source=<some dir>,target=<some dir>
```
