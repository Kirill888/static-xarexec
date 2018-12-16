#!/bin/sh

set -e

maybe_fetch() {
    file="$1"
    url="$2"

    if [ -e "${file}" ]
    then
        echo "Already in the cache: ${file}"
    else
        wget "${url}" -O "${file}"
    fi
}

out=$(readlink -f $(dirname $1))/$(basename $1)

mkdir -p /dl
cd /dl

maybe_fetch fuse-2.9.8.tar.gz         https://github.com/libfuse/libfuse/releases/download/fuse-2.9.8/fuse-2.9.8.tar.gz
maybe_fetch squashfuse-0.1.103.tar.gz https://github.com/vasi/squashfuse/releases/download/0.1.103/squashfuse-0.1.103.tar.gz
maybe_fetch squashfs-tools.tar.gz     https://github.com/plougher/squashfs-tools/tarball/6e242dc
maybe_fetch xar-18.07.12.tar.gz       https://github.com/facebookincubator/xar/archive/v18.07.12.tar.gz

mkdir -p /src
cd /src

# build static/shared versions of libfuse
#  `apk add fuse-dev` only includes shared version
tar xvzf /dl/fuse-2.9.8.tar.gz
(cd fuse-2.9.8 && mkdir B && cd B && \
     ../configure --enable-shared=yes --enable-static=yes --prefix=/usr && \
     make && \
     make install)


# squashfuse_ll as static binary
#
tar xvzf /dl/squashfuse-0.1.103.tar.gz
(cd squashfuse-0.1.103 && mkdir B && cd B && \
     ../configure --prefix=/ --with-pic=no --disable-dependency-tracking --disable-demo --disable-high-level --enable-static=yes --enable-shared=no &&\
     make LDFLAGS=-all-static && \
     make install-strip
)


# (mk|un)squashfs tools with all compressors enabled as a static binary
tar xvzf /dl/squashfs-tools.tar.gz
(cd plougher-squashfs-tools-6e242dc/squashfs-tools && \
     make ZSTD_SUPPORT=1 XZ_SUPPORT=1 LZO_SUPPORT=1 LZ4_SUPPORT=1 EXTRA_LDFLAGS=-static && \
     strip mksquashfs &&
     strip unsquashfs &&
     cp unsquashfs mksquashfs /bin
     )


# xarexec_fuse as a static binary
tar xvzf /dl/xar-18.07.12.tar.gz
(cd xar-18.07.12 && mkdir B && cd B && \
     cmake -DCMAKE_EXE_LINKER_FLAGS="-static" -DCMAKE_INSTALL_PREFIX:PATH=/ .. &&\
     make && make install/strip
)


# package up
cd /bin/
echo "tar -> ${out}"
tar cvzf "${out}" mksquashfs unsquashfs squashfuse_ll xarexec_fuse
