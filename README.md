# qt5-rpi-sysroot
Create raspberry pi system root in Ubuntu which includes the necessary environment to cross-compile Qt from source.

## usage
```
SSH_KEY_FILE=~/.ssh/id_rsa RPI_HOST=192.168.1.6 make build
```

where `SSH_KEY_FILE` is the id that you have registered in your raspberry pi. It is necessary for Docker container to connect to your device without additional input from you. If you need a guide, see [passwordless access](https://www.raspberrypi.org/documentation/remote-access/ssh/passwordless.md). 
`RPI_HOST` is the ip address of your raspberry pi.

## builds images
visit my docker hub: https://cloud.docker.com/repository/docker/mustafatekeli/qt5-rpi-sysroot
