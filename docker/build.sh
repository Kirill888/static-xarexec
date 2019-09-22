#!/bin/sh

set -e

maybe_fetch() {
    file="$1"
    url="$2"

    if [ -e "${file}" ]
    then
        echo "Already in the cache: ${file}"
    else
        echo "Fetching ${url} -> ${file}"
        wget -q "${url}" -O "${file}"
    fi
}

out=$(readlink -f $(dirname $1))/$(basename $1)

mkdir -p /dl
cd /dl

maybe_fetch fuse.tar.gz            https://github.com/libfuse/libfuse/releases/download/fuse-2.9.9/fuse-2.9.9.tar.gz
maybe_fetch squashfuse.tar.gz      https://github.com/vasi/squashfuse/releases/download/0.1.103/squashfuse-0.1.103.tar.gz
maybe_fetch squashfs-tools.tar.gz  https://github.com/plougher/squashfs-tools/archive/4.4.tar.gz
maybe_fetch xar.tar.gz             https://github.com/facebookincubator/xar/archive/19.4.22.tar.gz
mkdir -p /src
cd /src

# build static/shared versions of libfuse
#  `apk add fuse-dev` only includes shared version
#
(mkdir fuse && cd fuse \
 && tar xvzf /dl/fuse.tar.gz --strip-components=1 \
 && mkdir B && cd B \
 && ../configure --enable-shared=yes --enable-static=yes --prefix=/usr \
 && make \
 && make install)


# squashfuse_ll as static binary
#
(mkdir squashfuse && cd squashfuse \
 && tar xvzf /dl/squashfuse.tar.gz --strip-components=1 \
 && mkdir B && cd B \
 && ../configure --prefix=/ --with-pic=no --disable-dependency-tracking --disable-demo --disable-high-level --enable-static=yes --enable-shared=no \
 && make LDFLAGS=-all-static \
 && make install-strip
)


# (mk|un)squashfs tools with all compressors enabled as a static binary
#
tar xzf /dl/squashfs-tools.tar.gz --strip-components=1
(cd squashfs-tools \
 && make ZSTD_SUPPORT=1 XZ_SUPPORT=1 LZO_SUPPORT=1 LZ4_SUPPORT=1 EXTRA_LDFLAGS=-static \
 && strip mksquashfs \
 && strip unsquashfs \
 && cp unsquashfs mksquashfs /bin
)


# xarexec_fuse as a static binary
#
(mkdir xar && cd xar \
 && tar xzf /dl/xar.tar.gz --strip-components=1 \
 && mkdir B && cd B \
 && cmake -DCMAKE_EXE_LINKER_FLAGS="-static" -DCMAKE_INSTALL_PREFIX:PATH=/ .. \
 && make && make install/strip
)


# package up
cd /bin/
echo "tar -> ${out}"
tar cvzf "${out}" mksquashfs unsquashfs squashfuse_ll xarexec_fuse
