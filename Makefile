.PHONY: all build clean login push

COMMIT     := $$(git log -1 --pretty=%H | cut -c 1-14)
GIT_TAG    := $$(git tag -l --points-at HEAD)

REPO       := jambonrose/django-20-simplelist-training

NAME       := ${REPO}
IMG        := ${NAME}:${COMMIT}
LATEST     := ${NAME}:latest
VERSION    := ${NAME}:${GIT_TAG}

all:
	@echo 'Available Commands:'
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null \
		| awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' \
		| sort \
		| egrep -v -e '^[^[:alnum:]]' -e '^$@$$' \
		| xargs -I {} echo '    {}'

build:
	@docker build --pull --no-cache -t ${IMG} .
	@docker tag ${IMG} ${LATEST}
	@if [ ${GIT_TAG} ]; then docker tag ${IMG} ${VERSION}; fi;

clean:
	@-docker container prune
	@-docker rmi ${NAME} 2>/dev/null # untag the latest
	@-if [ ${GIT_TAG} ]; then docker rmi ${VERSION}; fi;
	@-docker images | grep '${NAME}' | awk '{print $$3}' | xargs docker rmi
	@-docker image prune --force

login:
	@docker login -u '$(value DOCKER_USER)' -p '$(value DOCKER_PASSWORD)'

push: login
	@docker push ${NAME}
