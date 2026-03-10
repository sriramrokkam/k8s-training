# Troubleshooting

## Error trying to pull image

### Symptoms

You try to pull an image (ex. `docker pull nginx:latest`) and receive an error.

- Authentication
- Cannot fetch from repository
- etc

### Possible Cause & Solution

If you have already used docker before, it is possible that the docker config have been modified or is missing repository information.

Docker config usually resides inside `~/.docker/` and is called `config.json`.

Insert the following properties:

```json
{
	"auths": {
		"https://index.docker.io/vi": {}
		// or
		"build-releases-sap-external.int.repositories.cloud.sap": {}
	}
}
```

And try again.

