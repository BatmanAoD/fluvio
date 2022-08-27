#!/bin/bash
# set up sccache
set -e
if [[ $# -eq 1 ]]; then
    OS=${1}
else
    OS=$(uname)
fi

ZIG_VER=0.9.1
LLVM_VER=14
ARCH=x86_64
echo "installing zig matrix.os=$OS version=$ZIG_VER"

case "$OS" in
    # Install on Linux
    ubuntu-latest | Linux)
        echo "installing zig on Linux"
        # TODO `wget` to a tempdir (mktemp) and use `trap` to ensure it gets deleted
        # ....unless it fails, in which case, maybe keep it?
        # (only useful interactively)
        wget https://ziglang.org/download/$ZIG_VER/zig-linux-$ARCH-$ZIG_VER.tar.xz && \
            tar -xf zig-linux-$ARCH-$ZIG_VER.tar.xz && \
            sudo mv zig-linux-$ARCH-$ZIG_VER /usr/local && \
            pushd /usr/local/bin && \
            sudo ln -s ../zig-linux-$ARCH-$ZIG_VER/zig . && \
            popd && \
            rm zig-linux-x86_64-0.9.1.tar.*
        # TODO This doesn't belong here. Create a consolidated script to
        # install both lld and zig, on both Linux and Mac.
        echo "installing lld on Linux, using '${0%/*}/llvm.sh'"
        sudo ${0%/*}/llvm.sh $LLVM_VER && \
            echo "FLUVIO_BUILD_LLD=lld-14" | tee -a $GITHUB_ENV
        ;;
    # Install on MacOS
    "macos-12" | Darwin)
        echo "installing zig on mac"
        #   brew update
        brew install zig && \
            echo "FLUVIO_BUILD_LLD=/opt/homebrew/opt/llvm@13/bin/lld" | tee -a $GITHUB_ENV
        ;;
    # remove zig on Linux
    "ubuntu-cleanup" | "Linux-cleanup")
        echo "removing zig"
        sudo rm -rf /usr/local/zig-linux-$ARCH-$ZIG_VER && \
            sudo rm -rf /usr/local/bin/zig
        ;;
    # Remove zig on Mac
    "macos-cleanup" | "Darwin-cleanup")
        echo "removing zig"
        brew uninstall zig
        ;;
esac
