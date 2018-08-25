repository = sjust
image = jupyter-all
tag = $(repository)/$(image)
JUPYTER_TOKEN=84a471ab58d5dbe8c23455b5b6a92f143cc871b1674a5457d83cbb377d06b18c

all: $(tag)

.DEFAULT: all
.PHONY: clean mrproper stop pull

# Build the docker image
$(tag): Dockerfile check-env
	$(info Building image with tag $(tag))
	@docker build --build-arg JUPYTER_TOKEN=$(JUPYTER_TOKEN) -t $(tag) .

# Deploy the image to docker.io
push: $(tag)
	$(info Deploying image with tag $(tag))
	@docker push $(tag)

# Fetch the image from docker.io (requires `docker login` for private repositories)
pull:
	$(info Pulling image with tag $(tag))
	@docker pull $(tag)

# Delete all images for $(tag)
mrproper: clean
	$(info Removing images for tag $(tag) and pruning related images.)
	-docker rmi $(tag) >/dev/null 2>&1
	-docker rmi $(shell docker images -a --filter=dangling=true -q) >/dev/null 2>&1

# Check environment variables
check-env:
# ifndef GITUSER
# $(error GITUSER is undefined)
# endif
# ifndef GITPASSWORD
# $(error GITPASSWORD is undefined)
# endif
ifndef HOST
HOST = localhost
endif
