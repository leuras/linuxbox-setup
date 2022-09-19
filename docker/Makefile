.PHONY: build start stop restart

suid = $(shell id -u | grep -E "^(0)$$")

build:
	$(call root_checker)
	@@echo "Building docker image"
	@@docker build -f ./Dockerfile ../ -t linuxbox-setup:latest

stop:
	$(call root_checker)
	@@echo "Stopping docker container"
	@@docker container stop linuxbox

start:
	$(call root_checker)
	@@echo "Starting docker container"
	@@docker run --rm --name linuxbox \
		-v $(call project_dir):/setup:ro \
		-d linuxbox-setup:latest \
		&& docker exec -it linuxbox /bin/bash

restart: stop start
	
root_checker = $(if $(suid), , $(call err_permission_denied))
err_permission_denied = @@echo "Permission denied!" && exit 1
project_dir = $(shell dirname $(shell pwd))