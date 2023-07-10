# Exercise 01 - Make Images Available

## Scope
- In this first exercise you will write a multistage Dockerfile to build the image of the fortune cookies service.
- The cluster can't access this image, if it is just on your local machine. Therefore, we need to push it to the registry in our cluster.
- An `ImagePullSecret` is needed to download images from our secured registry. Hence, the final step is to create this secret in your namespace.

## Step 1: clone the exercise repository

In order to build the image, we need the source code. Please adapt the following commands to your preferences and run them:

```SHELL
cd ~/<some-directory> #choose a location to clone to
git clone --branch cloud-platforms https://github.tools.sap/cloud-curriculum/exercise-code-java.git cloud-platforms-java-k8s
cd ~/<some-directory>/cloud-platforms-java-k8s
```

## Step 2: write a multistage Dockerfile

The application is written in Java and uses maven as a build tool. Of course, you could install maven locally, build the application on your machine and copy the result into the build context. But there is a way better option - use a multistage build!

Go ahead and create a new `Dockerfile` within the cloned repository. Fill it with content so that you don't ship your build environment but only the runtime including the `jar` file.

#### How to get there?
- Use two stages - each stage starts with a `FROM` line.
- Give your stages a name by appending `as <name>` to the end of your `FROM` line (e.g. `FROM <some image> as builder`)
- For the builder stage you can use the image `maven:sapmachine`. More on SapMachine can be found [here](https://github.com/SAP/SapMachine).
- Use `sapmachine:lts` as your starting image for the app stage.
- For simplicity copy the complete content of the cloned git repository to the builder stage.
- Use `mvn verify` to build the `.jar`-file. Maven creates the file in the folder named `target` next to the `src` folder and places the resulting `fortune-cookies.jar` into it.
- Copy the `fortune-cookies.jar`-file from the builder to your final stage.
- The application listens on port `8080`. Make sure, this is known to anyone running the image.
- Check the [sapmachine image documentation](https://hub.docker.com/_/sapmachine) for hints how to run a Java application.
- If you're using M1 Mac add `--platform=amd64` to the `FROM` line

## Step 3: build and push the image to our training registry

Now go ahead, build your image and push it to the registry. Remember to give it a unique name, e.g. `fortune-cookies-<participant-id>`.

If you are working on a machine with x86 architecture, those commands will be fully sufficient: 

```SHELL
docker build -t <registry-url>/training/fortune-cookies-<participant-id>:<participant-id> .
docker push <registry-url>/training/fortune-cookies-<participant-id>:<participant-id>
```

However, if you are using an ARM based machine (e.g. MacBook with Apple Silicon), you need to build the image specifically for x86, because it has to match the architecture of the nodes in our K8s cluster:

```shell
# create a dedicated builder for docker and use buildkit explicitly
docker buildx create --name fortunecookiesbuilder
docker buildx use fortunecookiesbuilder
docker buildx inspect --bootstrap

# use the builder to specify the target platform's architecture
docker buildx build --platform linux/amd64 -t <registry-url>/training/fortune-cookies-<participant-id>:<participant-id> .
docker push <registry-url>/training/fortune-cookies-<participant-id>:<participant-id>

# cleanup
docker buildx rm fortunecookiesbuilder
```

In case you're missing the credentials to push, check the [solution to exercise 1](../docker/solutions/Solution_exercise_1.md#step-2--push-the-image-to-a-registry).

## Step 4: create imagePullSecret

The registry is secured with basic authentication. You need to provide the credentials as an `ImagePullSecret` in order to use the images.
Let's be prepared for that and create the secret already.

```bash
kubectl create secret docker-registry training-registry --docker-server=<registry-url> --docker-username=<registry-username> --docker-password='<registry-password>'
```

Again, if you are looking for the credentials, check [solution to exercise 1](../docker/solutions/Solution_exercise_1.md#step-2--push-the-image-to-a-registry).
Note: Single-quotes around the registry password are absolutely needed if the password contains special characters like an `!`.