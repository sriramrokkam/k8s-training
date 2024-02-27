# Solution to Exercise 1 - Images

In this exercise, you will build an image with a Dockerfile, tag it and upload it to a registry. You will use the Dockerfile to extend the NGINX image to another port and deliver a custom website that is embedded into the image.

## Step 0: Set up a build context

Create an empty directory on your VM and change into it.

```bash
mkdir dbuild
cd dbuild
```

Download the files into your build context:

```bash
cp <path-to-cloned-training-repo>/docker/res/evil.jpg .
cp <path-to-cloned-training-repo>/docker/res/evil.html .
mv evil.html index.html
```

## Step 3: Create a configuration for _nginx_

Create a new file `docker-nginx.conf` inside your build context and paste the following configuration into it.

```bash
cat << __EOF > nginx.conf
server {
    listen       8080;
    server_name  localhost;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
}
__EOF
```

## Step 1, 2, 3, 4 - Create the Dockerfile

Create a Dockerfile with the following contents:

```Dockerfile
FROM nginx:mainline

# copy the custom website into the image
COPY index.html /usr/share/nginx/html
COPY evil.jpg /usr/share/nginx/html

# copy the configuration file into the image
COPY docker-nginx.conf /etc/nginx/conf.d/nginx.conf

# expose the new port
EXPOSE 8080
```

## Step 6: Build the image

Be sure you are still in the `dbuild` directory. Use the `docker build` command to build image.

```bash
docker build .
```

Write down (or memorize) the ID that Docker returns, you will need it for the next step.

# Solution to the "type along" section for publishing the image.

## Step 1: Tag the image

For this step, you will need the image ID from step 7. Assuming that ID is `28ffc0efbc9b` and your tag is `pilfering_platypus`, tag your image like this:

```bash
docker tag 28ffc0efbc9b secure-nginx:pilfering_platypus
```

## Step 2: Push the image to a registry

Tag your image (again) so that it will have a reference to a registry. The URL for the registry is  **h.ingress.*\<cluster-name\>*.*\<project-name\>*.shoot.canary.k8s-hana.ondemand.com/training**, the values for `<cluster-name>` and `<project-name>` **must be substituted** with those given to you by your trainer.

Assuming that `<cluster-name>` is `wdfcw01`, that `<project-name>` is `k8s-train`, that your tag is `pilfering_platypus` and that the image ID returned to you in Step 7 is `28ffc0efbc9b`, tag your image like this:

```bash
docker tag 28ffc0efbc9b h.ingress.wdfcw01.k8s-train.shoot.canary.k8s-hana.ondemand.com/training/secure-nginx:pilfering_platypus
```

In order to push to the registry, you need to log on to it first. Run the command and enter the password `2r4!rX6u5-qH`:

```bash
docker login -u participant h.ingress.wdfcw01.k8s-train.shoot.canary.k8s-hana.ondemand.com
```

Finally, push the image to the registry:

```bash
docker push h.ingress.wdfcw01.k8s-train.shoot.canary.k8s-hana.ondemand.com/training/secure-nginx:pilfering_platypus
```
