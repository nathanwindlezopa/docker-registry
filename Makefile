IMAGE-NAME := docker-registry
CERT-DIR := $(shell pwd)/certs
.PHONY : build create-certs

create-certs:
	mkdir -p $(CERT-DIR)
	openssl req -new -newkey rsa:2048 -nodes -out $(CERT-DIR)/demo.lab1.test.com.csr -keyout $(CERT-DIR)/demo.lab1.test.com.key -subj "/C=GB/ST=G5/L=None/O=Zopa/OU=Dev/CN=demo.lab1.test.com"
	openssl x509 -req -days 365 -in $(CERT-DIR)/demo.lab1.test.com.csr -signkey $(CERT-DIR)/demo.lab1.test.com.key -out $(CERT-DIR)/demo.lab1.test.com.crt

build:
	docker build -rm -t $(IMAGE-NAME) .

.ONESHELL:
start-server: create-certs build
	docker run --rm \
		--volume $(CERT-DIR):/opt/docker/certs \
		-p 443:443  \
		$(IMAGE-NAME)
