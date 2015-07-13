FROM ubuntu:14.04
MAINTAINER Simon Johansson <simon@simonjohansson.com>

RUN dpkg --add-architecture i386
# The first apt-get install is for deps listed at
# https://developer.mozilla.org/zh-TW/Firefox_OS/Firefox_OS_build_prerequisites#Ubuntu_13.10
# The second are deps that are needed but not in the minimal ubuntu 14.04 base image.
RUN apt-get update && \
    apt-get install -y --no-install-recommends autoconf2.13 bison bzip2 ccache curl flex gawk gcc g++ g++-multilib gcc-4.7 g++-4.7 g++-4.7-multilib git lib32ncurses5-dev lib32z1-dev libgconf2-dev zlib1g:amd64 zlib1g-dev:amd64 zlib1g:i386 zlib1g-dev:i386 libgl1-mesa-dev libgl2ps-dev libx11-dev make zip libxml2-utils  lzop && \
    apt-get install -y python python-dev openjdk-7-jdk wget libdbus-glib-1-dev libxt-dev unzip cmake

RUN apt-get install -y x11proto-core-dev x11proto-gl-dev libxext-dev libxxf86vm-dev libgdk-pixbuf2.0-dev libcairo2-dev libpango1.0-dev libatk1.0-dev libghc-x11-dev libgtk2.0-dev build-essential

# We need to use gcc-4.6 to build, set that as default.
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.7 1
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 2
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.7 1
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 2
RUN update-alternatives --set gcc "/usr/bin/gcc-4.7"
RUN update-alternatives --set g++ "/usr/bin/g++-4.7"

#Setup environment and build that sucka!
RUN useradd -m build
# Sneaky sneaky hack ahead!
# When doing the initial ./config target-platform a file, ".config"
# will be created in the B2G root containing this line
# "GECKO_OBJDIR=/home/user/path/to/B2G/objdir-gecko"
# So when building at one stage, GECKO_OBJDIR is going to be created
# which will fail since we are running as a normal user, not root.
# To solve we simply give ownership to /home to build user.
RUN chown -R build:build /home
RUN ln -s /usr/lib/i386-linux-gnu/libX11.so.6 /usr/lib/i386-linux-gnu/libX11.so
RUN ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so
USER build
ENV SHELL /bin/bash
ENV HOME /home/build
VOLUME ["/B2G"]
WORKDIR /B2G

# Build :)
ENTRYPOINT ./build.sh
