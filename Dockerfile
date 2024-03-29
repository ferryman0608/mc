# Start with the base Alpine Linux image
FROM alpine:latest

# Set the maintainer label
LABEL maintainer "Your Name <your_email@example.com>"

# Set environment variable for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies
RUN apk add --no-cache \
glib \
libintl \
libssh2 \
ncurses-libs \
autoconf \
automake \
e2fsprogs-dev \
gettext-dev \
git \
glib-dev \
libtool \
pcre-dev \
gcc \
make \
&& apk add --update alpine-sdk

# Set terminal environment variable
ENV TERM xterm

# Add group and user for Midnight Commander
RUN addgroup -g 1001 -S mc \
&& adduser -u 1001 -SHG mc mc \
&& mkdir -p /home/mc/.mc

# Set the Midnight Commander version
ENV MC_VERSION 4.8.21

# Run necessary build steps and compile Midnight Commander
RUN set -x \
&& apk add --no-cache --virtual .build-deps \
aspell-dev \
libssh2-dev \
ncurses-dev \
&& git clone --depth 1 --branch "$MC_VERSION" https://github.com/MidnightCommander/mc.git /usr/src/mc \
&& ( \
cd /usr/src/mc \
&& ./autogen.sh \
&& ./configure \
--prefix=/usr \
--libexecdir=/usr/lib \
--mandir=/usr/share/man \
--sysconfdir=/etc \
--enable-background \
--enable-charset \
--enable-largefile \
--enable-vfs-sftp \
--with-internal-edit \
--with-mmap \
--with-screen=ncurses \
--with-subshell \
--without-gpm-mouse \
--without-included-gettext \
--without-x \
--enable-aspell \
&& make \
&& make install \
) \
&& curl -sSL "https://raw.githubusercontent.com/nkulikov/mc-solarized-skin/master/solarized.ini" > /home/mc/.mc/solarized.ini \
&& rm -rf /usr/src/mc \
&& apk del .build-deps \
&& chown -R mc:mc /home/mc

# Set environment variables
ENV HOME=/home/mc
ENV MC_SKIN=${HOME}/.mc/solarized.ini

# Set the working directory
WORKDIR ${HOME}

# Set the entry point to run Midnight Commander
ENTRYPOINT [ "mc" ]
