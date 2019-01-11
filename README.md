# static-xarexec

[![Build Status](https://travis-ci.org/Kirill888/static-xarexec.svg?branch=master)](https://travis-ci.org/Kirill888/static-xarexec)

Docker for building tools needed to create and run python [xar](https://github.com/facebookincubator/xar) files.

Following tools are built as static executables:

- run
   - `xarexec_fuse` entry point that runs `xar` files
   - `squashfuse_ll` called by `xarexec_fuse` to mount `xar` files
- create
   - `mksquashfs` with `zstd` support built in, used for building `xar` files
   - `unsquashfs` reverse of `mksquashfs` included for convenience not used by `xar` toolchain
