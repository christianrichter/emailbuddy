TARGET_IMAGE_NAME = frontend
PROJECT_SCOPE = emailbuddy
COMMIT_HASH = $(shell git rev-parse --short HEAD)
TARGET_DOCKER_REGISTRY = 057809863814.dkr.ecr.eu-central-1.amazonaws.com
version ?= $(COMMIT_HASH)

DOCKER_LOGIN = $(shell aws ecr get-login --no-include-email --region eu-central-1)


.PHONY: build
build:
	docker build \
	-f Dockerfile \
	-t $(PROJECT_SCOPE)/$(TARGET_IMAGE_NAME):latest \
	-t $(PROJECT_SCOPE)/$(TARGET_IMAGE_NAME):$(COMMIT_HASH) .

.PHONY: login
login:
	@$(DOCKER_LOGIN)

.PHONY: upload
upload: login
	docker tag $(PROJECT_SCOPE)/$(TARGET_IMAGE_NAME):$(COMMIT_HASH) $(TARGET_DOCKER_REGISTRY)/$(PROJECT_SCOPE)/$(TARGET_IMAGE_NAME):$(COMMIT_HASH)
	docker push $(TARGET_DOCKER_REGISTRY)/$(PROJECT_SCOPE)/$(TARGET_IMAGE_NAME):$(COMMIT_HASH)

.PHONY: release
release: login
	docker pull $(TARGET_DOCKER_REGISTRY)/$(PROJECT_SCOPE)/$(TARGET_IMAGE_NAME):$(COMMIT_HASH)
	docker tag $(TARGET_DOCKER_REGISTRY)/$(PROJECT_SCOPE)/$(TARGET_IMAGE_NAME):$(COMMIT_HASH) $(TARGET_DOCKER_REGISTRY)/$(PROJECT_SCOPE)/$(TARGET_IMAGE_NAME):latest
	docker tag $(TARGET_DOCKER_REGISTRY)/$(PROJECT_SCOPE)/$(TARGET_IMAGE_NAME):$(COMMIT_HASH) $(TARGET_DOCKER_REGISTRY)/$(PROJECT_SCOPE)/$(TARGET_IMAGE_NAME):$(version)
	docker push $(TARGET_DOCKER_REGISTRY)/$(PROJECT_SCOPE)/$(TARGET_IMAGE_NAME):latest
	docker push $(TARGET_DOCKER_REGISTRY)/$(PROJECT_SCOPE)/$(TARGET_IMAGE_NAME):$(version)

.PHONY: all
all: build upload release
