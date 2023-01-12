# Sample Application

Now that you know the basics Docker and Kubernetes concepts there is one more thing to do: Let's put it all together!

So within the following exercises you will dockerize an application, write deployment specifications and set up the wiring for service to service communication.

To make things easier (and hopefully relatable to your future learning journey), we are (re-)using **[materials of the Cloud Native Developer Journey](https://pages.github.tools.sap/cloud-curriculum/materials/)**. 
The sample application is emitting fortune cookie-like quotes and consists of a frontend service (in our case it will be Java based) and a Postgres instance to store some data.

## Exercises

### [01 Exercise: "Build and push the container image"](exercise_01_make_images_available.md)
- Build and push the container images for the fortune cookies app.
- Create an **ImagePullSecret** for the training-registry.

### [02 Exercise: "Setting up a database"](exercise_02_db.md)
- Create credentials for the database and store the password in a **Secret**.
- Create a **StatefulSet** for the database together with a headless **Service**.

### [03 Exercise: "Serve some fortune cookies"](exercise_03_app.md)
- Create the required **Configmap**
- Create a **Deployment** running the fortune cookies app, using the **Configmap** and the **Secret** of the DB.
- Expose the application via **Service** and **Ingress**

### [04 Exercise: "Networkpolicies & TLS"](exercise_04_networkpolicies_and_certificate.md)
- Increase security and establish a **Network policy** for
  - your postgres instance
  - the fortune cookies app
- Enable HTTPS connection by adding TLS certificates to your **Ingress**

