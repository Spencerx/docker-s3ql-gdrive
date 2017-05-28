IMGNAME=s3ql-gdrive
VERSION=:$(TAG)
.PHONY: all build taglatest

all: build

build:
		@docker build -t $(IMGNAME)$(VERSION) --rm . && echo Buildname: $(IMAGENAME):$(VERSION)

run:
		docker-compose up

