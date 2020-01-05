# static-xarexec

[![Build Status](https://github.com/Kirill888/static-xarexec/workflows/build/badge.svg)](https://github.com/Kirill888/static-xarexec/actions)

Docker for building tools needed to create and run python [xar](https://github.com/facebookincubator/xar) files.

Following tools are built as static executables:

- run
   - `xarexec_fuse` entry point that runs `xar` files
   - `squashfuse_ll` called by `xarexec_fuse` to mount `xar` files
- create
   - `mksquashfs` with `zstd` support built in, used for building `xar` files
   - `unsquashfs` reverse of `mksquashfs` included for convenience not used by `xar` toolchain
