#!/bin/bash

deb_pkg () {
    local base=$1
    local v=$2
    local arch=$3
    local pkg_name="xarexec-static"
    local deb_name="${pkg_name}_${v}_${arch}.deb"

    mkdir -p "${base}/DEBIAN"
    cat <<EOF | tee "${base}/DEBIAN/control"
Package: ${pkg_name}
Version: ${v}
Section: devel
Priority: optional
Architecture: ${arch}
Depends:
Maintainer: Kirill Kouzoubov <kirill.kouzoubov@ga.gov.au>
Description: Static binaries for running python xar files
EOF

    if hash dpkg-deb fakeroot 2> /dev/null; then
        echo "Building ${deb_name}"
        fakeroot dpkg-deb --build "${base}" "${deb_name}"
    else
        echo "Need dpkg-dev and fakeroot to run"
        echo "   >>  fakeroot dpkg-deb --build ${base} ${deb_name}"
        exit 1
    fi
}

main () {
    local v=$1
    local arch=$2
    local base="_deb"
    local bin="${base}/usr/bin"

    mkdir -p "${bin}"
    tar xvzf ./out/xarexec-static.tgz -C "${bin}" xarexec_fuse squashfuse_ll
    deb_pkg "${base}" "${v}" "${arch}"
}

main "${1:-0.0.1}" "${2:-amd64}"
