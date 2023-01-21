#!/bin/bash
# for ubuntu enable component multiverse and universe and dêpot update and security
# for debian enable component contrib non-free and dépot update security backport and debian multimedia
# DEPENDENCIES Ubuntu_Debian: 
apt-get -y install libssl-dev g++-multilib git mercurial curl wget ca-certificates tar gcc g++ make libtool automake zstd nettle-dev
apt-get -y install autoconf autogen build-essential pkg-config cmake bison flex gperf gettext autopoint texinfo texlive nasm yasm libunistring-dev
apt-get -y install libfontconfig-dev libfreetype-dev libbz2-dev librubberband-dev libsamplerate0-dev libgmp-dev libltdl-dev
apt-get -y install libffi-dev libgc-dev gtk-doc-tools libtasn1-6-dev libtasn1-bin librtmp-dev libfdk-aac-dev subversion
# DEPENDENCIES_Centos_Fedora: 
yum -y install epel-release
yum -y install dnf
dnf -y install git mercurial curl wget tar gcc gcc-c++ make libtool automake autoconf autogen pkgconfig cmake ca-certificates
dnf -y install  bison flex gperf gettext texinfo texlive yasm nasm gtk-doc libtasn1-devel libstdc++-devel
dnf -y install fontconfig-devel freetype-devel bzip2 bzip2-devel gmp-devel expat-devel libtool-ltdl-devel libunistring-devel gc-devel gettext-devel
dnf -y install zlib-devel librtmp-devel fdk-aac-devel nettle-devel openssl-devel unzip zip subversion byacc binutils-devel
dnf -y groupinstall 'Development Tools'
#update install caro
apt-get -y purge cargo
dnf -y remove cargo
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source "$HOME/.cargo/env"
rustup default stable

set -u
set -e
set -x


autogen_src()
{
    echo "AUTOGEN $1"

    ./autogen.sh
}

bootstrap_src()
{
    echo "BOOTSTRAP $1"

    ./bootstrap
}

dot_bootstrap_src()
{
    echo "BOOTSTRAP $1"

    ./.bootstrap
}

configure_src()
{
    echo "CONFIGURE $1"

    echo ./configure \
        --prefix=$OUT_PREFIX \
        "${@:2}"
    ./configure \
        --prefix=$OUT_PREFIX \
        "${@:2}"
}

config_src()
{
    echo "CONFIGURE $1"

    echo ./config \
         --prefix=$OUT_PREFIX \
         "${@:2}"
    ./config \
        --prefix=$OUT_PREFIX \
        "${@:2}"
}

cmake_src()
{
    echo "CMAKE $1"

    echo cmake . \
         -G "Unix Makefiles" \
         -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_INSTALL_PREFIX=$OUT_PREFIX \
         "${@:2}"
    cmake . \
          -G "Unix Makefiles" \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=$OUT_PREFIX \
          "${@:2}"
    echo "CMAKE $1"
}

cmake_sp_src()
{
    echo "CMAKE $1"

    echo cmake "$2" \
         -G "Unix Makefiles" \
         -DCMAKE_BUILD_TYPE=Release \
         -DCMAKE_INSTALL_PREFIX=$OUT_PREFIX \
         "${@:3}"
    cmake "$2" \
          -G "Unix Makefiles" \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX=$OUT_PREFIX \
          "${@:3}"
    echo "CMAKE $1"
}

make_src()
{
    echo "MAKE $1"

    make -j"${CPU_CORES}"
    make install
    echo "MAKE $1"
}

make_iie_src() # ignore install error
{
    echo "MAKE $1"

    make -j"${CPU_CORES}"
    make install || true
    echo "MAKE $1"
}

compile_with_configure()
{
if [ -d "$SRC/$1" ]; then    
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    configure_src "$@"
    make_src "$1"

    cd $CURRENT_DIR
    rm -rf $SRC/$1
fi    
}

compile_with_config_sp() # subpath, not necessarily needed
{
if [ -d "$SRC/$1" ]; then 
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1
    cd $2

    configure_src "$1" "${@:3}"
    make_src "$1"

    cd $CURRENT_DIR
    rm -rf $SRC/$1
fi
}

compile_with_config()
{
if [ -d "$SRC/$1" ]; then 
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    config_src "$@"
    make_src "$1"

    cd $CURRENT_DIR
    rm -rf $SRC/$1
fi
}

compile_with_autogen()
{
if [ -d "$SRC/$1" ]; then
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    autogen_src "$1"
    configure_src "$@"
    make_src "$1"

    cd $CURRENT_DIR
    rm -rf $SRC/$1
fi
}

compile_with_bootstrap()
{
if [ -d "$SRC/$1" ]; then
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    bootstrap_src "$1"
    configure_src "$@"
    make_src "$1"

    cd $CURRENT_DIR
    rm -rf $SRC/$1
fi
}

compile_with_dot_bstrp()
{
if [ -d "$SRC/$1" ]; then
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    dot_bootstrap_src "$1"
    configure_src "$@"
    make_src "$1"

    cd $CURRENT_DIR
    rm -rf $SRC/$1
fi
}

compile_with_autog_iie()
{
if [ -d "$SRC/$1" ]; then
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    autogen_src "$1"
    configure_src "$@"
    make_iie_src "$1"

    cd $CURRENT_DIR
    rm -rf $SRC/$1
fi
}

compile_with_cmake()
{
if [ -d "$SRC/$1" ]; then
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    cmake_src "$@"
    make_src "$1"

    cd $CURRENT_DIR
    rm -rf $SRC/$1
fi
}
compile_with_cmake_sp()
{
if [ -d "$SRC/$1" ]; then
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd "$SRC/$1"
    mkdir -p "$2"
    cd "$2"

    cmake_sp_src "$1" "$3" "${@:4}"
    make_src "$1"

    cd $CURRENT_DIR
    rm -rf $SRC/$1
fi
}

compile_ffnvcodec()
{
if [ -d "$SRC/$1" ]; then
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    echo "MAKE $1"

    make install PREFIX=$OUT_PREFIX

    cd $CURRENT_DIR
    rm -rf $SRC/$1
fi
}

compile_c2man()
{
if [ -d "$SRC/$1" ]; then
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    echo "C2MAN CONFIGURE $1"

    ./Configure -dE

    echo "binexp=$OUT_BIN" >> config.sh
    echo "installprivlib=$OUT_PREFIX" >> config.sh
    echo "mansrc=$OUT_PREFIX" >> config.sh
    sh config_h.SH
    sh flatten.SH
    sh Makefile.SH

    echo "MAKE $1"

    make depend
    make -j"${CPU_CORES}"
    make install

    cd $CURRENT_DIR
    rm -rf $SRC/$1
fi
}

compile_alsa()
{
if [ -d "$SRC/$1" ]; then
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    echo "ALSA CONFIGURE $1"

    libtoolize --force --copy --automake
    aclocal
    autoheader
    automake --foreign --copy --add-missing
    autoconf
    ./configure \
        --prefix=$OUT_PREFIX \
        --enable-shared=no \
        --enable-static=yes

    echo "MAKE $1"

    make -j"${CPU_CORES}"
    make install

    cd $CURRENT_DIR
    rm -rf $SRC/$1
fi
}
compile_libass()
{
if [ -d "$SRC/$1" ]; then
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    echo "LIBASS CONFIGURE $1"

    autoreconf -fiv
    ./configure --prefix=$OUT_PREFIX --disable-shared
    echo "MAKE $1"

    make -j"${CPU_CORES}"
    make install

    cd $CURRENT_DIR
    rm -rf $SRC/$1
fi
}
compile_svtav1()
{
if [ -d "$SRC/$1" ]; then
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd "$SRC/$1"

    echo "SVT_AV1 BUILD $1"

    cd "Build/linux"
    ./build.sh \
        prefix="$OUT_PREFIX" \
        jobs="$CPU_CORES" \
        release \
        static \
        install

    cd $CURRENT_DIR
    rm -rf $SRC/$1
fi
}

compile_rav1e()
{
if [ -d "$SRC/$1" ]; then
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd "$SRC/$1"

    #build require package cargo
    echo "install cargo-c (for rav1e)"
    rustup default stable
    RUST_BACKTRACE=1 PATH="$OUT_PREFIX/bin:$PATH" cargo install --root="$OUT_PREFIX" -j$(nproc --all) cargo-c
    echo "rav1e BUILD $1"
    RUST_BACKTRACE=1 PATH="$OUT_PREFIX/bin:$PATH" cargo build -j$(nproc --all) --release
    RUST_BACKTRACE=1 PATH="$OUT_PREFIX/bin:$PATH" cargo cinstall -j$(nproc --all) --release --prefix="$OUT_PREFIX"

    echo "FIX rav1e.pc file" # Hack
    sed -i "s/ -lgcc_s / /g" "$OUT_PREFIX/lib/pkgconfig/rav1e.pc"

    cd $CURRENT_DIR
    rm -rf $SRC/$1
fi
}

# get cpu count
CPU_CORES="$(grep ^processor /proc/cpuinfo | wc -l)"
# TODO: Let's see how GitHub Actions behaves
# CircleCI seems to report wrong cpu numbers
# The RAM to CPU_CORES ratio on CircleCI seems to be a problem or just the big number of generated jobs
#if [ "$CIRCLECI" = "true" ] && [ "$CPU_CORES" -gt 4 ]
#then
#    echo "Detected CircleCI and many parallel jobs => reducing parallel jobs"
#    CPU_CORES=4
#fi
echo "Building with ${CPU_CORES} parallel jobs"

# set path vars
WD=$(pwd)
SRC=$WD/src

OUT_PREFIX=$WD/ffmpeg_build
OUT_BIN=$WD/ffmpeg_bin
OUT_PKG_CONFIG=$OUT_PREFIX/lib/pkgconfig:$OUT_PREFIX/lib64/pkgconfig

export PATH="$OUT_BIN:$PATH"
export PKG_CONFIG_PATH=$OUT_PKG_CONFIG
export CFLAGS="$CFLAGS -I$OUT_PREFIX/include -L$OUT_PREFIX/lib -L$OUT_PREFIX/lib64"
export LD_LIBRARY_PATH="$OUT_PREFIX/lib:$OUT_PREFIX/lib64:$LD_LIBRARY_PATH"
# export CC="gcc"
# export CXX="g++"

rm -rf $OUT_PREFIX
rm -rf $OUT_BIN

mkdir -p $OUT_PKG_CONFIG
mkdir -p $OUT_PREFIX
mkdir -p $OUT_PREFIX/lib
mkdir -p $OUT_BIN
mkdir -p $SRC


cd $WD


git_clone_ie()
{
    git clone --quiet $1 $2 || true
}

git_get_fresh()
{
    echo "FETCH/CLEAN $1"
    git_clone_ie $2 $SRC/$1
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)
    cd $SRC/$1
    git fetch -p
    git clean -fdx
    git checkout -- .
    cd $CURRENT_DIR
}

git_get_frver() # fresh with version
{
    git_get_fresh $SRC/$1 $3
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)
    cd $SRC/$1
    git checkout $2
    cd $CURRENT_DIR
}

svn_clone_ie() # subversion ssl no check
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)
    cd $SRC/
    rm -rf $1
    svn --non-interactive --trust-server-cert checkout $2 $1
    cd $CURRENT_DIR
}

git_get_submd()
{
    git_get_fresh $1 $2

    echo "SUBMODULES $1"

    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    cd $SRC/$1

    git submodule deinit -f .
    git submodule init
    git submodule update

    cd $CURRENT_DIR
}

dl_tar_gz_fre()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    echo "CLEAN/DOWNLOAD/UNTAR $1"

    rm -rf "$SRC/$1"

    mkdir "$SRC/$1"
    cd "$SRC/$1"

    curl -s -o tmp.tar.gz -L "$2"
    tar -xzf tmp.tar.gz --strip-components=1
    rm tmp.tar.gz

    cd $CURRENT_DIR
}

dl_tar_xz_fre()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    echo "CLEAN/DOWNLOAD/UNTAR $1"

    rm -rf "$SRC/$1"

    mkdir "$SRC/$1"
    cd "$SRC/$1"

    curl -s -o tmp.tar.xz -L "$2"
    tar -xJf tmp.tar.xz --strip-components=1
    rm tmp.tar.xz

    cd $CURRENT_DIR
}

dl_tar_bz2_fre()
{
    local CURRENT_DIR
    CURRENT_DIR=$(pwd)

    echo "CLEAN/DOWNLOAD/UNTAR $1"

    rm -rf "$SRC/$1"

    mkdir -p "$SRC/$1"
    cd "$SRC/$1"

    curl -s -o tmp.tar.bz2 -L "$2"
    tar -xjf tmp.tar.bz2 --strip-components=1
    rm tmp.tar.bz2

    cd $CURRENT_DIR
}


#compile_with_autog_iie nasm --bindir=$OUT_BIN

# compile_with_autogen   yasm --bindir=$OUT_BIN

git_get_fresh rav1e https://github.com/xiph/rav1e.git
compile_rav1e rav1e

svn_clone_ie xavs https://svn.code.sf.net/p/xavs/code/trunk
compile_with_configure xavs --bindir=$OUT_BIN --disable-shared

git_get_fresh c2man https://github.com/fribidi/c2man.git
compile_c2man c2man

# update table
hash -r

git_get_fresh alsa https://github.com/alsa-project/alsa-lib.git
compile_alsa alsa

git_get_fresh libx264 http://git.videolan.org/git/x264.git
compile_with_configure libx264 --bindir=$OUT_BIN --enable-static --enable-pic --bit-depth=all

git_get_fresh libx265 https://bitbucket.org/multicoreware/x265_git.git
#CFLAGS="$CFLAGS -static-libgcc" \
#CXXFLAGS="$CXXFLAGS -static-libgcc -static-libstdc++" \
compile_with_cmake_sp libx265 build/linux ../../source -DENABLE_SHARED:bool=off
if [ ! -f $OUT_PREFIX/lib/pkgconfig/x265.pc ]
then
mkdir -p $OUT_PREFIX/lib/pkgconfig/
cat > $OUT_PREFIX/lib/pkgconfig/x265.pc <<EOF
prefix=$OUT_PREFIX
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include

Name: x265
Description: H.265/HEVC video encoder
Version: 3.5
Libs: -L\${libdir} -lx265
Libs.private: -lstdc++ -lm -lrt -ldl
Cflags: -I\${includedir}
EOF
fi

git_get_fresh libaom-av1 https://aomedia.googlesource.com/aom
compile_with_cmake_sp libaom-av1 build .. -DBUILD_SHARED_LIBS=0

git_get_fresh svt_av1 https://gitlab.com/AOMediaCodec/SVT-AV1.git
compile_svtav1 svt_av1

git_get_fresh libopus https://github.com/xiph/opus.git
compile_with_autogen libopus --disable-shared

# compile libogg (dependency of libvorbis)
git_get_fresh libogg https://github.com/xiph/ogg.git
compile_with_autogen libogg --disable-shared

git_get_fresh libvorbis https://github.com/xiph/vorbis.git
compile_with_autogen libvorbis --with-ogg=$OUT_PREFIX --disable-shared

git_get_fresh libvpx https://chromium.googlesource.com/webm/libvpx
compile_with_configure libvpx --disable-examples --disable-unit-tests --enable-vp9-highbitdepth --as=yasm

dl_tar_gz_fre lame http://downloads.sourceforge.net/project/lame/lame/3.100/lame-3.100.tar.gz
compile_with_configure lame --bindir=$OUT_BIN --disable-shared --enable-nasm

git_get_fresh fribidi https://github.com/fribidi/fribidi.git
compile_with_autogen fribidi --bindir=$OUT_BIN --disable-shared

git_get_fresh libopenjpeg https://github.com/uclouvain/openjpeg.git
compile_with_cmake libopenjpeg -DBUILD_SHARED_LIBS=OFF

git_get_fresh libsoxr https://git.code.sf.net/p/soxr/code
compile_with_cmake libsoxr -Wno-dev -DBUILD_SHARED_LIBS:BOOL=OFF -DBUILD_TESTS:BOOL=OFF -DWITH_OPENMP=OFF

git_get_fresh libspeex https://github.com/xiph/speex.git
compile_with_autogen libspeex --disable-shared

git_get_fresh libtheora https://github.com/xiph/theora.git
compile_with_autogen libtheora --disable-shared

dl_tar_gz_fre xvidcore https://downloads.xvid.com/downloads/xvidcore-1.3.7.tar.gz
compile_with_config_sp xvidcore build/generic

git_get_fresh libvidstab https://github.com/georgmartius/vid.stab.git
compile_with_cmake libvidstab -DBUILD_SHARED_LIBS=OFF

git_get_fresh libwebp https://chromium.googlesource.com/webm/libwebp
compile_with_autogen libwebp --disable-shared

git_get_fresh frei0r https://github.com/dyne/frei0r.git
compile_with_cmake frei0r

git_get_fresh ffnvcodec https://git.videolan.org/git/ffmpeg/nv-codec-headers.git
compile_ffnvcodec ffnvcodec

# if nettle error uncomment for build
# old system require example Centos 7
#git_get_fresh nettle https://git.lysator.liu.se/nettle/nettle
#compile_with_dot_bstrp nettle --bindir=$OUT_BIN --disable-shared

# autogen for gnutls (autogen is not on alpine?)
# as long as guile-3.0 is not supported by autogen, we cant use the system package
dl_tar_gz_fre guile https://ftp.gnu.org/pub/gnu/guile/guile-2.2.7.tar.gz
compile_with_configure guile
dl_tar_xz_fre autogen https://ftp.gnu.org/gnu/autogen/rel5.18.16/autogen-5.18.16.tar.xz
compile_with_configure autogen --bindir=$OUT_BIN --disable-dependency-tracking

git_get_submd gnutls https://gitlab.com/gnutls/gnutls.git
compile_with_bootstrap gnutls --bindir=$OUT_BIN --with-included-libtasn1 --with-included-unistring \
--without-p11-kit --disable-doc --disable-full-test-suite --disable-shared

git_get_fresh samplerate https://github.com/libsndfile/libsamplerate
compile_with_cmake samplerate -DBUILD_SHARED_LIBS=OFF

git_get_fresh libass https://github.com/libass/libass.git
compile_libass libass

dl_tar_bz2_fre ffmpeg https://ffmpeg.org/releases/ffmpeg-5.1.2.tar.bz2
compile_with_configure ffmpeg \
                       --bindir=$OUT_BIN \
                       --pkg-config-flags="--static" \
                       --extra-cflags="-I$OUT_PREFIX/include" \
                       --extra-ldflags="-L$OUT_PREFIX/lib" \
                       --extra-libs=-lpthread \
                       --extra-libs=-lm \
                       --extra-libs=-lfftw3 \
                       --extra-libs=-lsamplerate \
                       --extra-libs=-lstdc++ \
                       --extra-cflags="-static -static-libgcc" \
                       --extra-cxxflags="-static -static-libgcc -static-libstdc++" \
                       --extra-ldexeflags="-static -static-libgcc -static-libstdc++" \
                       --enable-pthreads \
                       --enable-gpl \
                       --enable-libx264 \
                       --enable-libx265 \
                       --enable-libopus \
                       --enable-libvorbis \
                       --enable-libvpx \
                       --enable-libmp3lame \
                       --enable-fontconfig \
                       --enable-libopenjpeg \
                       --enable-libspeex \
                       --enable-libaom \
                       --enable-libsvtav1 \
                       --enable-network \
                       --enable-libtheora \
                       --enable-libsoxr \
                       --enable-libxvid \
                       --enable-libvidstab \
                       --enable-libwebp \
                       --enable-libfreetype \
                       --enable-frei0r \
                       --enable-librubberband \
                       --enable-avfilter \
                       --enable-bzlib \
                       --enable-zlib \
                       --enable-hardcoded-tables \
                       --enable-iconv \
                       --enable-postproc \
                       --disable-debug \
                       --enable-runtime-cpudetect \
                       --enable-manpages \
                       --enable-nvenc \
                       --enable-gnutls \
                       --enable-nonfree \
                       --enable-version3 \
                       --enable-libfdk_aac \
                       --disable-ffplay \
                       --disable-doc \
                       --enable-gray \
                       --enable-runtime-cpudetect \
                       --enable-librtmp \
                       --enable-static \
		       --extra-libs='-lrtmp'  \
		       --extra-libs='-lgmp'  \
		       --extra-libs='-lssl'  \
		       --extra-libs='-lcrypto'  \
		       --extra-libs='-lz'  \
		       --extra-libs='-ldl'  \
		       --extra-libs='-lunistring'  \
		       --disable-debug  \
		       --disable-shared  \
		       --extra-version=Xtream-Codes \
                       --enable-libxavs


echo "DONE"
