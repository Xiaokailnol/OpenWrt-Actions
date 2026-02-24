#!/bin/bash -e
export RED_COLOR='\e[1;31m'
export GREEN_COLOR='\e[1;32m'
export YELLOW_COLOR='\e[1;33m'
export BLUE_COLOR='\e[1;34m'
export PINK_COLOR='\e[1;35m'
export SHAN='\e[1;33;5m'
export RES='\e[0m'

GROUP=
group() {
    endgroup
    echo "::group::  $1"
    GROUP=1
}
endgroup() {
    if [ -n "$GROUP" ]; then
        echo "::endgroup::"
    fi
    GROUP=
}

# check
if [ "$(whoami)" != "zhao" ] && [ -z "$git_name" ] && [ -z "$git_password" ]; then
    echo -e "\n${RED_COLOR} Not authorized. Execute the following command to provide authorization information:${RES}\n"
    echo -e "${BLUE_COLOR} export git_name=your_username git_password=your_password${RES}\n"
    exit 1
fi

#####################################
#        OpenWrt Build Script       #
#####################################

# script url
export mirror=http://127.0.0.1:8080

# github
export github="github.com"

# Check root
if [ "$(id -u)" = "0" ]; then
    export FORCE_UNSAFE_CONFIGURE=1 FORCE=1
fi

# Start time
starttime=`date +'%Y-%m-%d %H:%M:%S'`
CURRENT_DATE=$(date +%s)

# Cpus
cores=`expr $(nproc --all) + 1`

# $CURL_BAR
if curl --help | grep progress-bar >/dev/null 2>&1; then
    CURL_BAR="--progress-bar";
fi

SUPPORTED_BOARDS="nanopi-r2s nanopi-r3s nanopi-r4s nanopi-r5c nanopi-r5s nanopi-r6c nanopi-r6s nanopi-r76s x86_64"
if [ -z "$1" ] || ! echo "$SUPPORTED_BOARDS" | grep -qw "$2"; then
    echo -e "\n${RED_COLOR}Building type not specified or unsupported board: '$2'.${RES}\n"
    echo -e "Usage:\n"

    for board in $SUPPORTED_BOARDS; do
        echo -e "$board releases: ${GREEN_COLOR}bash build.sh v25 $board${RES}"
        echo -e "$board snapshots: ${GREEN_COLOR}bash build.sh dev $board${RES}"
    done
    echo
    exit 1
fi

# Source branch
if [ "$1" = "dev" ]; then
    export branch=openwrt-25.12
    export version=dev
elif [ "$1" = "v25" ]; then
    latest_release="v$(curl -s $mirror/tags/v25)"
    export branch=$latest_release
    export version=v25
fi

# lan
[ -n "$LAN" ] && export LAN=$LAN || export LAN=10.0.0.1

# platform
case "$2" in
    nanopi-r2s)
        platform="nanopi-r2s"
        toolchain_arch="aarch64_generic"
        ;;
    nanopi-r3s)
        platform="nanopi-r3s"
        toolchain_arch="aarch64_generic"
        ;;        
    nanopi-r4s)
        platform="nanopi-r4s"
        toolchain_arch="aarch64_generic"
        ;;
    nanopi-r5c)
        platform="nanopi-r5c"
        toolchain_arch="aarch64_generic"
        ;;        
    nanopi-r5s)
        platform="nanopi-r5s"
        toolchain_arch="aarch64_generic"
        ;;
    nanopi-r6c)
        platform="nanopi-r6c"
        toolchain_arch="aarch64_generic"
        ;;
    nanopi-r6s)
        platform="nanopi-r6s"
        toolchain_arch="aarch64_generic"
        ;;
    nanopi-r76s)
        platform="rk3576"
        toolchain_arch="aarch64_generic"
        ;;
    x86_64)
        platform="x86_64"
        toolchain_arch="x86_64"
        ;;
esac
export platform toolchain_arch

# gcc14 & 15
if [ "$USE_GCC13" = y ]; then
    export USE_GCC13=y gcc_version=13
elif [ "$USE_GCC14" = y ]; then
    export USE_GCC14=y gcc_version=14
elif [ "$USE_GCC15" = y ]; then
    export USE_GCC15=y gcc_version=15
else
    export USE_GCC15=y gcc_version=15
fi
[ "$ENABLE_MOLD" = y ] && export ENABLE_MOLD=y

# build.sh flags
export \
    ENABLE_BPF=$ENABLE_BPF \
    ENABLE_LRNG=$ENABLE_LRNG \
    ROOT_PASSWORD=$ROOT_PASSWORD

# print version
echo -e "\r\n${GREEN_COLOR}Building $branch${RES}\r\n"
case "$platform" in
    x86_64)
        echo -e "${GREEN_COLOR}Model: x86_64${RES}"
        ;;
    nanopi-r2s)
        echo -e "${GREEN_COLOR}Model: nanopi-r2s${RES}"
        [ "$1" = "v25" ] && model="nanopi-r2s"
        ;;
    nanopi-r3s)
        echo -e "${GREEN_COLOR}Model: nanopi-r3s${RES}"
        [ "$1" = "v25" ] && model="nanopi-r3s"
        ;;
    nanopi-r4s)
        echo -e "${GREEN_COLOR}Model: nanopi-r4s${RES}"
        [ "$1" = "v25" ] && model="nanopi-r4s"
        ;;
    nanopi-r5c)
        echo -e "${GREEN_COLOR}Model: nanopi-r5c${RES}"
        [ "$1" = "v25" ] && model="nanopi-r5c"
        ;;
    nanopi-r5s)
        echo -e "${GREEN_COLOR}Model: nanopi-r5s${RES}"
        [ "$1" = "v25" ] && model="nanopi-r5s"
        ;;
    nanopi-r6c)
        echo -e "${GREEN_COLOR}Model: nanopi-r6c${RES}"
        [ "$1" = "v25" ] && model="nanopi-r6c"
        ;;
    nanopi-r6s)
        echo -e "${GREEN_COLOR}Model: nanopi-r6s${RES}"
        [ "$1" = "v25" ] && model="nanopi-r6s"
        ;;
    nanopi-r76s)
        echo -e "${GREEN_COLOR}Model: nanopi-r76s${RES}"
        [ "$1" = "v25" ] && model="nanopi-r76s"
        ;;        
esac

# print build opt
get_kernel_version=$(curl -s $mirror/tags/kernel-6.12)
kmod_hash=$(echo -e "$get_kernel_version" | awk -F'HASH-' '{print $2}' | awk '{print $1}' | tail -1 | md5sum | awk '{print $1}')
kmodpkg_name=$(echo $(echo -e "$get_kernel_version" | awk -F'HASH-' '{print $2}' | awk '{print $1}')~$(echo $kmod_hash)-r1)
echo -e "${GREEN_COLOR}Kernel: $kmodpkg_name ${RES}"
echo -e "${GREEN_COLOR}Date: $CURRENT_DATE${RES}\r\n"
echo -e "${GREEN_COLOR}SCRIPT_URL:${RES} ${BLUE_COLOR}$mirror${RES}\r\n"
echo -e "${GREEN_COLOR}GCC VERSION: $gcc_version${RES}"
print_status() {
    local name="$1"
    local value="$2"
    local true_color="${3:-$GREEN_COLOR}"
    local false_color="${4:-$YELLOW_COLOR}"
    local newline="${5:-}"
    if [ "$value" = "y" ]; then
        echo -e "${GREEN_COLOR}${name}:${RES} ${true_color}true${RES}${newline}"
    else
        echo -e "${GREEN_COLOR}${name}:${RES} ${false_color}false${RES}${newline}"
    fi
}
[ -n "$LAN" ] && echo -e "${GREEN_COLOR}LAN:${RES} $LAN" || echo -e "${GREEN_COLOR}LAN:${RES} 10.0.0.1"
[ -n "$ROOT_PASSWORD" ] \
    && echo -e "${GREEN_COLOR}Default Password:${RES} ${BLUE_COLOR}$ROOT_PASSWORD${RES}" \
    || echo -e "${GREEN_COLOR}Default Password:${RES} (${YELLOW_COLOR}No password${RES})"
[ "$ENABLE_GLIBC" = "y" ] && echo -e "${GREEN_COLOR}Standard C Library:${RES} ${BLUE_COLOR}glibc${RES}" || echo -e "${GREEN_COLOR}Standard C Library:${RES} ${BLUE_COLOR}musl${RES}"
print_status "ENABLE_OTA"        "$ENABLE_OTA"
print_status "ENABLE_MOLD"       "$ENABLE_MOLD"
print_status "ENABLE_BPF"        "$ENABLE_BPF" "$GREEN_COLOR" "$RED_COLOR"
print_status "ENABLE_LTO"        "$ENABLE_LTO" "$GREEN_COLOR" "$RED_COLOR"
print_status "ENABLE_LRNG"       "$ENABLE_LRNG" "$GREEN_COLOR" "$RED_COLOR"
print_status "ENABLE_LOCAL_KMOD" "$ENABLE_LOCAL_KMOD"
print_status "BUILD_FAST"        "$BUILD_FAST"
print_status "ENABLE_CCACHE"     "$ENABLE_CCACHE"
print_status "ENABLE_ISTORE"     "$ENABLE_ISTORE""\n"

# clean old files
rm -rf openwrt

# openwrt - releases
[ "$(whoami)" = "runner" ] && group "source code"
git clone --depth=1 https://$code_mirror/openwrt/openwrt -b $branch

[ "$(whoami)" = "runner" ] && endgroup
if [ -d openwrt ]; then
    cd openwrt
    curl -Os $mirror/openwrt/patch/key.tar.gz && tar zxf key.tar.gz && rm -f key.tar.gz
else
    echo -e "${RED_COLOR}Failed to download source code${RES}"
    exit 1
fi

# tags
if [ "$1" = "v25" ]; then
    git describe --abbrev=0 --tags > version.txt
else
    git branch | awk '{print $2}' > version.txt
fi

# feeds mirror
if [ "$1" = "v25" ]; then
    packages="^$(grep packages feeds.conf.default | awk -F^ '{print $2}')"
    luci="^$(grep luci feeds.conf.default | awk -F^ '{print $2}')"
    routing="^$(grep routing feeds.conf.default | awk -F^ '{print $2}')"
    telephony="^$(grep telephony feeds.conf.default | awk -F^ '{print $2}')"
else
    packages=";$branch"
    luci=";$branch"
    routing=";$branch"
    telephony=";$branch"
fi
cat > feeds.conf <<EOF
src-git packages https://$github/openwrt/packages.git$packages
src-git luci https://$github/openwrt/luci.git$luci
src-git routing https://$github/openwrt/routing.git$routing
src-git telephony https://$github/openwrt/telephony.git$telephony
EOF

# Init feeds
[ "$(whoami)" = "runner" ] && group "feeds update -a"
./scripts/feeds update -a
[ "$(whoami)" = "runner" ] && endgroup

[ "$(whoami)" = "runner" ] && group "feeds install -a"
./scripts/feeds install -a
[ "$(whoami)" = "runner" ] && endgroup

# loader dl
if [ -f ../dl.gz ]; then
    tar xf ../dl.gz -C .
fi

###############################################
echo -e "\n${GREEN_COLOR}Patching ...${RES}\n"

# scripts
scripts=(
  00-prepare_base.sh
  01-prepare_base-mainline.sh
  02-prepare_package.sh
  03-convert_translation.sh
  04-fix_kmod.sh
  05-fix-source.sh
  99_clean_build_cache.sh
)
for script in "${scripts[@]}"; do
  curl -sO "$mirror/openwrt/scripts/$script"
done
if [ -n "$git_password" ] && [ -n "$private_url" ]; then
    curl -u openwrt:$git_password -sO "$private_url"
else
    curl -sO $mirror/openwrt/scripts/10-custom.sh
fi
chmod 0755 *sh
[ "$(whoami)" = "runner" ] && group "patching openwrt"
bash 00-prepare_base.sh
bash 01-prepare_base-mainline.sh
bash 02-prepare_package.sh
bash 04-fix_kmod.sh
bash 05-fix-source.sh
[ -f "10-custom.sh" ] && bash 10-custom.sh
find feeds -type f -name "*.orig" -exec rm -f {} \;
[ "$(whoami)" = "runner" ] && endgroup

rm -f 0*-*.sh 10-custom.sh
rm -rf ../master

# Load devices Config
if [ "$platform" = "x86_64" ]; then
    curl -s $mirror/openwrt/25-config-musl-x86 > .config
elif [ "$platform" = "nanopi-r2s" ]; then
    curl -s $mirror/openwrt/25-config-musl-r2s > .config
elif [ "$platform" = "nanopi-r3s" ]; then
    curl -s $mirror/openwrt/25-config-musl-r3s > .config
elif [ "$platform" = "nanopi-r4s" ]; then
    curl -s $mirror/openwrt/25-config-musl-r4s > .config
elif [ "$platform" = "nanopi-r5c" ]; then
    curl -s $mirror/openwrt/25-config-musl-r5c > .config
elif [ "$platform" = "nanopi-r5s" ]; then
    curl -s $mirror/openwrt/25-config-musl-r5s > .config
elif [ "$platform" = "nanopi-r6c" ]; then
    curl -s $mirror/openwrt/25-config-musl-r6c > .config
elif [ "$platform" = "nanopi-r6s" ]; then
    curl -s $mirror/openwrt/25-config-musl-r6s > .config
else
    curl -s $mirror/openwrt/25-config-musl-r76s > .config
fi

# config-common
curl -s $mirror/openwrt/25-config-common >> .config

# ota
[ "$ENABLE_OTA" = "y" ] && [ "$version" = "v25" ] && echo 'CONFIG_PACKAGE_luci-app-ota=y' >> .config

# bpf
[ "$ENABLE_BPF" = "y" ] && curl -s $mirror/openwrt/generic/config-bpf >> .config

# LTO
export ENABLE_LTO=$ENABLE_LTO
[ "$ENABLE_LTO" = "y" ] && curl -s $mirror/openwrt/generic/config-lto >> .config

# istore
[ "$ENABLE_ISTORE" = "y" ] && {
    echo 'CONFIG_PACKAGE_luci-app-store=y' >> .config
    echo 'CONFIG_PACKAGE_luci-app-quickstart=y' >> .config
}

# mold
[ "$ENABLE_MOLD" = "y" ] && echo 'CONFIG_USE_MOLD=y' >> .config

# kernel - enable LRNG
if [ "$ENABLE_LRNG" = "y" ]; then
    echo -e "\n# Kernel - LRNG" >> .config
    echo "CONFIG_KERNEL_LRNG=y" >> .config
    echo "# CONFIG_PACKAGE_urandom-seed is not set" >> .config
    echo "# CONFIG_PACKAGE_urngd is not set" >> .config
fi

# local kmod
if [ "$ENABLE_LOCAL_KMOD" = "y" ]; then
    echo -e "\n# local kmod" >> .config
    echo "CONFIG_TARGET_ROOTFS_LOCAL_PACKAGES=y" >> .config
fi

# gcc config
echo -e "\n# gcc ${gcc_version}" >> .config
echo -e "CONFIG_DEVEL=y" >> .config
echo -e "CONFIG_TOOLCHAINOPTS=y" >> .config
echo -e "CONFIG_GCC_USE_VERSION_${gcc_version}=y\n" >> .config

# uhttpd
[ "$ENABLE_UHTTPD" = "y" ] && sed -i '/nginx/d' .config && echo 'CONFIG_PACKAGE_ariang=y' >> .config

# not all kmod
[ "$NO_KMOD" = "y" ] && sed -i '/CONFIG_ALL_KMODS=y/d; /CONFIG_ALL_NONSHARED=y/d' .config

# build wwan pkgs for openwrt_core
[ "$OPENWRT_CORE" = "y" ] && curl -s $mirror/openwrt/generic/config-wwan >> .config

# ccache
if [ "$USE_GCC15" = "y" ] && [ "$ENABLE_CCACHE" = "y" ]; then
    echo "CONFIG_CCACHE=y" >> .config
    [ "$(whoami)" = "runner" ] && echo "CONFIG_CCACHE_DIR=\"/builder/.ccache\"" >> .config
    [ "$(whoami)" = "zhao" ] && echo "CONFIG_CCACHE_DIR=\"/home/zhao/.ccache\"" >> .config
    tools_suffix="_ccache"
fi

# Toolchain Cache
if [ "$BUILD_FAST" = "y" ]; then
    echo -e "\n${GREEN_COLOR}Download Toolchain ...${RES}"
    PLATFORM_ID=""
    [ -f /etc/os-release ] && source /etc/os-release
    if [ "$PLATFORM_ID" = "platform:el9" ]; then
        TOOLCHAIN_URL="http://127.0.0.1:8080"
    else
        TOOLCHAIN_URL=https://"$github_proxy"github.com/Xiaokailnol/openwrt_caches/releases/download/openwrt-25.12
    fi
    curl -L ${TOOLCHAIN_URL}/toolchain_musl_${toolchain_arch}_gcc-${gcc_version}${tools_suffix}.tar.zst -o toolchain.tar.zst $CURL_BAR
    echo -e "\n${GREEN_COLOR}Process Toolchain ...${RES}"
    tar -I "zstd" -xf toolchain.tar.zst
    rm -f toolchain.tar.zst
    mkdir bin
    find ./staging_dir/ -name '*' -exec touch {} \; >/dev/null 2>&1
    find ./tmp/ -name '*' -exec touch {} \; >/dev/null 2>&1
fi

# init openwrt config
rm -rf tmp/*
if [ "$BUILD" = "n" ]; then
    exit 0
else
    make defconfig
fi

# Compile
if [ "$BUILD_TOOLCHAIN" = "y" ]; then
    echo -e "\r\n${GREEN_COLOR}Building Toolchain ...${RES}\r\n"
    make -j$cores toolchain/compile || make -j$cores toolchain/compile V=s || exit 1
    mkdir -p toolchain-cache
    tar -I "zstd -19 -T$(nproc --all)" -cf toolchain-cache/toolchain_musl_${toolchain_arch}_gcc-${gcc_version}${tools_suffix}.tar.zst ./{build_dir,dl,staging_dir,tmp}
    echo -e "\n${GREEN_COLOR} Build success! ${RES}"
    exit 0
else
    echo -e "\r\n${GREEN_COLOR}Building OpenWrt ...${RES}\r\n"
    sed -i "/BUILD_DATE/d" package/base-files/files/usr/lib/os-release
    sed -i "/BUILD_ID/aBUILD_DATE=\"$CURRENT_DATE\"" package/base-files/files/usr/lib/os-release
    make -j$cores IGNORE_ERRORS="n m"
fi

# Compile time
endtime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
SEC=$((end_seconds-start_seconds));

if [ -f bin/targets/*/*/sha256sums ]; then
    echo -e "${GREEN_COLOR} Build success! ${RES}"
    echo -e " Build time: $(( SEC / 3600 ))h,$(( (SEC % 3600) / 60 ))m,$(( (SEC % 3600) % 60 ))s"
else
    echo -e "\n${RED_COLOR} Build error... ${RES}"
    echo -e " Build time: $(( SEC / 3600 ))h,$(( (SEC % 3600) / 60 ))m,$(( (SEC % 3600) % 60 ))s"
    echo
    exit 1
fi
