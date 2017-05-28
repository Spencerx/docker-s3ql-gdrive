FROM phusion/baseimage

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

MAINTAINER <sdelrio@users.noreply.github.com>

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y git pkg-config software-properties-common \
 && add-apt-repository -y ppa:nikratio/s3ql  \
 && apt-get install -y python3 python3-pip \
 && pip3 install --upgrade pip \
 && apt-get update \
 && apt-get install -y python3-llfuse \
 && pip3 install --upgrade google-api-python-client \
 && pip3 install llfuse \
\
 && apt-get -y install s3ql sqlite3 libsqlite3-dev cython \
 && git clone https://github.com/segator/s3ql.git -b gdrive \
 && cd s3ql \
\
 && python3 setup.py build_cython \
 && python3 setup.py build_ext --inplace \
 && python3 setup.py install \
\
 && apt-get autoremove -y \
 && apt-get remove --purge -y git libsqlite3-dev pkg-config software-properties-common \
 && apt-get remove --purge -y binutils build-essential bzip2 cpp cpp-5 dpkg-dev fakeroot g++ g++-5 gcc \
 && apt-get remove --purge -y gcc-5 git git-man ifupdown iproute2 isc-dhcp-client isc-dhcp-common \
 && apt-get remove --purge -y libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl \
 && apt-get remove --purge -y libasan2 libatm1 libatomic1 libc-dev-bin libc6-dev libcc1-0 libcilkrts5 \
 && apt-get remove --purge -y libdns-export162 libdpkg-perl liberror-perl libfakeroot \
 && apt-get remove --purge -y libfile-fcntllock-perl libgcc-5-dev libgdbm3 libgomp1 libisc-export160 \
 && apt-get remove --purge -y libisl15 libitm1 liblsan0 libmnl0 libmpc3 libmpfr4 libmpx0 libperl5.22 \
 && apt-get remove --purge -y libquadmath0 libstdc++-5-dev libtsan0 libubsan0 libxtables11 linux-libc-dev \
 && apt-get remove --purge -y make manpages manpages-dev netbase patch perl perl-modules-5.22 pkg-config \
 && apt-get remove --purge -y rename rsync xz-utils \
 && mkdir /mnt/data \
 && mkdir /tmp/data_cache \
\
 && apt-get install -y bash \
\
 && apt-get autoremove -y \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir /root/.s3ql
ADD config/authinfo2 /root/.s3ql/authinfo2
RUN chmod 600 /root/.s3ql/authinfo2

ADD etc/s3ql.run /etc/service/s3ql/run
ADD etc/s3ql.finish /etc/service/s3ql/finish
RUN chmod 755 /etc/service/s3ql/run
RUN chmod 755 /etc/service/s3ql/finish

VOLUME ["/mnt/data"]

ENTRYPOINT ["/sbin/my_init"]

