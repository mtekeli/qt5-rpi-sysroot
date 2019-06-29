ARG RPI_HOST
ARG RPI_DIR=/root/raspi
ARG SYS_ROOT=${RPI_DIR}/sysroot

FROM ubuntu:18.04 as intermediate
LABEL maintainer="Mustafa Tekeli <mustafatekeli.mt@gmail.com>"

RUN apt-get update && \
	apt-get install -y \
	python \
	rsync \
	wget \ 
    ssh \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

ARG RPI_HOST
ARG RPI_DIR
ARG SYS_ROOT

RUN echo ${RPI_HOST}

# copy over the ssh profile to connect to rpi
RUN rm -rf /root/.ssh/id_rsa
COPY .ssh/id_rsa /root/.ssh/id_rsa
RUN chmod 400 /root/.ssh/id_rsa

# make sure your domain is accepted
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan ${RPI_HOST} >> /root/.ssh/known_hosts

# uncomment deb-src to have access to dev packages
RUN ssh pi@${RPI_HOST} 'sudo sed -i '/deb-src/s/^#//g' /etc/apt/sources.list'

# install required libraries
RUN ssh pi@${RPI_HOST} 'sudo apt-get update'
RUN ssh pi@${RPI_HOST} 'sudo apt-get build-dep qt4-x11 -y'
RUN ssh pi@${RPI_HOST} 'sudo apt-get build-dep libqt5gui5 -y'
RUN ssh pi@${RPI_HOST} 'sudo apt-get install libudev-dev libinput-dev libts-dev libxcb-xinerama0-dev libxcb-xinerama0 -y'

# create a sysroot
RUN	mkdir -p ${SYS_ROOT}/usr ${SYS_ROOT}/opt
RUN rsync -avz --rsync-path="sudo rsync" pi@${RPI_HOST}:/lib ${SYS_ROOT}
RUN rsync -avz --rsync-path="sudo rsync" pi@${RPI_HOST}:/usr/lib ${SYS_ROOT}/usr
RUN rsync -avz --rsync-path="sudo rsync" pi@${RPI_HOST}:/usr/include ${SYS_ROOT}/usr
RUN rsync -avz --rsync-path="sudo rsync" pi@${RPI_HOST}:/opt/vc ${SYS_ROOT}/opt

# adjust symlinks to be relative
RUN cd ${RPI_DIR} \
	&& wget https://raw.githubusercontent.com/Kukkimonsuta/rpi-buildqt/master/scripts/utils/sysroot-relativelinks.py \
	&& chmod +x sysroot-relativelinks.py \
	&& python ./sysroot-relativelinks.py ${SYS_ROOT}

FROM ubuntu:18.04

ARG RPI_DIR
ARG SYS_ROOT

RUN mkdir -p ${RPI_DIR} 

# copy the repository form the previous image
COPY --from=intermediate ${SYS_ROOT} ${SYS_ROOT}

RUN apt-get update && \
	apt-get install -y \
	build-essential \
	ssh \
	rsync \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*
