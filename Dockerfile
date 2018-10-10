FROM ubuntu:18.04
ENV DEBIAN_FRONTEND=noninteractive
SHELL ["/bin/bash", "-c"]

RUN apt-get update -y
RUN apt-get install -y eatmydata g++ zlib1g-dev build-essential git-core python rsync man-db libncurses5-dev gawk gettext unzip file libssl-dev wget zlib1g-dev flex file python2.7-dev automake bison patchelf findutils sudo squashfs-tools sudo time git-core subversion build-essential gcc-multilib libncurses5-dev zlib1g-dev gawk flex gettext wget unzip python
RUN apt-get clean

RUN adduser --disabled-password --gecos '' --shell /bin/bash --home /openwrt buildman
RUN adduser buildman sudo

RUN echo 'buildman ALL=NOPASSWD: ALL' > /etc/sudoers.d/buildman

RUN sudo -iu buildman git clone git://git.openwrt.org/openwrt/openwrt.git /openwrt/openwrt-project
RUN sudo -iu buildman bash -c "cd openwrt-project && git checkout openwrt-18.06"
RUN sudo -iu buildman bash -c "openwrt-project/scripts/feeds update -a"
RUN sudo -iu buildman bash -c "openwrt-project/scripts/feeds install -a"
#RUN sudo -iu buildman bash -c "cd openwrt-project && make menuconfig || true"

# This is the actual config file to use
ADD confg-c7v2 /openwrt/openwrt-project/.config
RUN chown buildman /openwrt/openwrt-project/.config
RUN sudo -iu buildman bash -c "cat /openwrt/openwrt-project/.config | grep -v \"^#\" | grep -v \"^$\" "
RUN sudo -iu buildman bash -c "cd openwrt-project && make defconfig"
RUN sudo -iu buildman bash -c "cat /openwrt/openwrt-project/.config | grep -v \"^#\" | grep -v \"^$\" "
RUN sudo -iu buildman bash -c "cd openwrt-project && make download -j 10"
RUN sudo -iu buildman bash -c "cd openwrt-project && eatmydata make -j 5"

USER buildman
WORKDIR /openwrt/openwrt-project

# Build this with:
# docker build -t openwrtmine:latest .

# Create a container so we can pick at the files inside
# docker create --name openwrtmine1 openwrtmine:latest

# After builds are done, you can extract the binaries produced with
# docker cp openwrtmine1:/openwrt/openwrt-project/bin bin

# Stop and remove the container
# docker rm --force openwrtmine1

# After build is done, you can rebuild with different configs by doing:
# docker run -it --name openwrtmine1 openwrtmine:latest bash -c "make menuconfig && make -j 5"

