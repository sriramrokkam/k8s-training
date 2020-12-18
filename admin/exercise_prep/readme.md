# Scripts to prepare exercises

## bulletinboard.sh
For the day 4 exercises, you will need to build and push the images of bulletinboard-ads and bulletinboard-reviews. This can be done automatically using this [script](./bulletinboard.sh). 

**Important: this script requires a connection to github.wdf.sap.corp!**

It will clone:
- run `docker login` to the harbor registry using the `participant` credentials
- clone bulletinboard-reviews & bulletinboard-ads to `/tmp`
- build the Docker images for both components 
- push both images to the `training` project in Harbor
