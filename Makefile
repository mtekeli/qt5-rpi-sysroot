IMG := mustafatekeli/qt5-rpi-sysroot
TAG := rpi3B-10buster-4.19.56-1

.PHONY: build, clean, push

clean:
	@ rm -rf ./.ssh

build: clean
	@ mkdir ./.ssh
	@ cp ${SSH_KEY_FILE} ./.ssh/id_rsa
	@ docker build -t=${IMG}:${TAG} . \
		--build-arg RPI_HOST=${RPI_HOST}
	@ make clean

push:
	@ docker push ${IMG}:${TAG}
