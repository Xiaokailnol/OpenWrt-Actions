#!/bin/bash -e

# autocore
git clone https://$github/sbwml/autocore-arm -b openwrt-25.12 package/system/autocore

# rockchip - target - r4s/r5s only
rm -rf target/linux/rockchip
if [ "$(whoami)" = "zhao" ]; then
    git clone https://$github/Xiaokailnol/target_linux_rockchip-6.x target/linux/rockchip -b openwrt-25.12 --depth=1
else
    git clone https://"$git_name":"$git_password"@$github/Xiaokailnol/target_linux_rockchip-6.x target/linux/rockchip -b openwrt-25.12 --depth=1
fi

## x86_64 - target 6.12
rm -rf target/linux/x86
if [ "$(whoami)" = "zhao" ]; then
    git clone https://$github/Xiaokailnol/target_linux_x86 target/linux/x86 -b openwrt-25.12 --depth=1
else
    git clone https://"$git_name":"$git_password"@$github/Xiaokailnol/target_linux_x86 target/linux/x86 -b openwrt-25.12 --depth=1
fi

# bpf-headers - 6.12
sed -ri "s/(PKG_PATCHVER:=)[^\"]*/\16.12/" package/kernel/bpf-headers/Makefile

# kernel - 6.12
curl -s $mirror/tags/kernel-6.12 > target/linux/generic/kernel-6.12

# kenrel Vermagic
sed -ie 's/^\(.\).*vermagic$/\1cp $(TOPDIR)\/.vermagic $(LINUX_DIR)\/.vermagic/' include/kernel-defaults.mk
grep HASH target/linux/generic/kernel-6.12 | awk -F'HASH-' '{print $2}' | awk '{print $1}' | md5sum | awk '{print $1}' > .vermagic

# kernel generic
rm -rf target/linux/generic
if [ "$(whoami)" = "zhao" ]; then
    git clone https://$github/Xiaokailnol/target_linux_generic -b openwrt-25.12 target/linux/generic --depth=1
else
    git clone https://"$git_name":"$git_password"@$github/Xiaokailnol/target_linux_generic -b openwrt-25.12 target/linux/generic --depth=1
fi

# kernel modules
rm -rf package/kernel/linux
git checkout package/kernel/linux
pushd package/kernel/linux/modules
    rm -f [a-z]*.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/block.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/bluetooth.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/can.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/crypto.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/firewire.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/fs.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/gpio.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/hwmon.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/i2c.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/iio.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/input.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/leds.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/lib.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/multiplexer.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/netdevices.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/netfilter.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/netsupport.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/nls.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/other.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/pcmcia.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/rtc.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/sound.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/spi.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/usb.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/video.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/virt.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/w1.mk
    curl -Os $mirror/openwrt/patch/openwrt-6.x/modules/wpan.mk
popd

# BBRv3 - linux-6.12
pushd target/linux/generic/backport-6.12
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-0001-net-tcp_bbr-broaden-app-limited-rate-sample-detectio.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-0002-net-tcp_bbr-v2-shrink-delivered_mstamp-first_tx_msta.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-0003-net-tcp_bbr-v2-snapshot-packets-in-flight-at-transmi.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-0004-net-tcp_bbr-v2-count-packets-lost-over-TCP-rate-samp.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-0005-net-tcp_bbr-v2-export-FLAG_ECE-in-rate_sample.is_ece.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-0006-net-tcp_bbr-v2-introduce-ca_ops-skb_marked_lost-CC-m.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-0007-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-merge-in.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-0008-net-tcp_bbr-v2-adjust-skb-tx.in_flight-upon-split-in.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-0009-net-tcp-add-new-ca-opts-flag-TCP_CONG_WANTS_CE_EVENT.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-0010-net-tcp-re-generalize-TSO-sizing-in-TCP-CC-module-AP.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-0011-net-tcp-add-fast_ack_mode-1-skip-rwin-check-in-tcp_f.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-0012-net-tcp_bbr-v2-record-app-limited-status-of-TLP-repa.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-0013-net-tcp_bbr-v2-inform-CC-module-of-losses-repaired-b.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-0014-net-tcp_bbr-v2-introduce-is_acking_tlp_retrans_seq-i.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-0015-tcp-introduce-per-route-feature-RTAX_FEATURE_ECN_LOW.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-0016-net-tcp_bbr-v3-update-TCP-bbr-congestion-control-mod.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-0017-net-tcp_bbr-v3-ensure-ECN-enabled-BBR-flows-set-ECT-.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-0018-tcp-export-TCPI_OPT_ECN_LOW-in-tcp_info-tcpi_options.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/bbr3/010-0019-x86-cfi-bpf-Add-tso_segs-and-skb_marked_lost-to-bpf_.patch
popd

# LRNG - 6.12
pushd target/linux/generic/hack-6.12
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0001-LRNG-Entropy-Source-and-DRNG-Manager.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0002-LRNG-allocate-one-DRNG-instance-per-NUMA-node.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0003-LRNG-proc-interface.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0004-LRNG-add-switchable-DRNG-support.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0005-LRNG-add-common-generic-hash-support.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0006-crypto-DRBG-externalize-DRBG-functions-for-LRNG.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0007-LRNG-add-SP800-90A-DRBG-extension.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0008-LRNG-add-kernel-crypto-API-PRNG-extension.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0009-LRNG-add-atomic-DRNG-implementation.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0010-LRNG-add-common-timer-based-entropy-source-code.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0011-LRNG-add-interrupt-entropy-source.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0012-scheduler-add-entropy-sampling-hook.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0013-LRNG-add-scheduler-based-entropy-source.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0014-LRNG-add-SP800-90B-compliant-health-tests.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0015-LRNG-add-random.c-entropy-source-support.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0016-LRNG-CPU-entropy-source.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0017-LRNG-add-Jitter-RNG-fast-noise-source.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0018-LRNG-add-option-to-enable-runtime-entropy-rate-c.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0019-LRNG-add-interface-for-gathering-of-raw-entropy.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0020-LRNG-add-power-on-and-runtime-self-tests.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0021-LRNG-sysctls-and-proc-interface.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0022-LRMG-add-drop-in-replacement-random-4-API.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0023-LRNG-add-kernel-crypto-API-interface.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0024-LRNG-add-dev-lrng-device-file-support.patch
    curl -Os $mirror/openwrt/patch/kernel-6.12/lrng/696-v59-0025-LRNG-add-hwrand-framework-interface.patch
popd

# linux-firmware
rm -rf package/firmware/linux-firmware
git clone https://"$git_name":"$git_password"@$github/Xiaokailnol/package_firmware_linux-firmware package/firmware/linux-firmware

# mt76
rm -rf package/kernel/mt76
git clone https://"$git_name":"$git_password"@$github/Xiaokailnol/package_kernel_mt76 package/kernel/mt76

# mac80211 - 6.18
rm -rf package/kernel/mac80211
git clone https://"$git_name":"$git_password"@$github/Xiaokailnol/package_kernel_mac80211 package/kernel/mac80211 -b openwrt-25.12

# ath10k-ct
rm -rf package/kernel/ath10k-ct
git clone https://"$git_name":"$git_password"@$github/Xiaokailnol/package_kernel_ath10k-ct package/kernel/ath10k-ct -b openwrt-25.12

# kernel patch
# set nf_conntrack_expect_max for fullcone
curl -s $mirror/openwrt/patch/kernel-6.12/net/001-netfilter-add-nf-conntrack-chain-events-support.patch | patch -p1
echo "net.netfilter.nf_conntrack_helper = 1" >>./package/kernel/linux/files/sysctl-nf-conntrack.conf
# btf: silence btf module warning messages
curl -s $mirror/openwrt/patch/kernel-6.12/btf/990-btf-silence-btf-module-warning-messages.patch > target/linux/generic/hack-6.12/990-btf-silence-btf-module-warning-messages.patch
curl -s $mirror/openwrt/patch/kernel-6.12/btf/991-skip-struct-module-size-validation.patch > target/linux/generic/hack-6.12/991-skip-struct-module-size-validation.patch
# cpu model
curl -s $mirror/openwrt/patch/kernel-6.12/arm64/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch > target/linux/generic/hack-6.12/312-arm64-cpuinfo-Add-model-name-in-proc-cpuinfo-for-64bit-ta.patch
# bcm-fullcone
curl -s $mirror/openwrt/patch/kernel-6.12/net/982-add-bcm-fullconenat-support.patch > target/linux/generic/hack-6.12/982-add-bcm-fullconenat-support.patch
curl -s $mirror/openwrt/patch/kernel-6.12/net/983-add-bcm-fullconenat-to-nft.patch > target/linux/generic/hack-6.12/983-add-bcm-fullconenat-to-nft.patch
# shortcut-fe
curl -s $mirror/openwrt/patch/kernel-6.12/net/613-netfilter_optional_tcp_window_check.patch > target/linux/generic/pending-6.12/613-netfilter_optional_tcp_window_check.patch
curl -s $mirror/openwrt/patch/kernel-6.12/net/952-add-net-conntrack-events-support-multiple-registrant.patch > target/linux/generic/hack-6.12/952-add-net-conntrack-events-support-multiple-registrant.patch
curl -s $mirror/openwrt/patch/kernel-6.12/net/953-net-patch-linux-kernel-to-support-shortcut-fe.patch > target/linux/generic/hack-6.12/953-net-patch-linux-kernel-to-support-shortcut-fe.patch

# rtl8822cs
git clone https://$github/sbwml/package_kernel_rtl8822cs package/kernel/rtl8822cs

# emmc-install
if [ "$platform" = "nanopi-r5s" ] || [ "$platform" = "nanopi-r76s" ]; then
    mkdir -p files/sbin
    curl -so files/sbin/emmc-install $mirror/openwrt/files/sbin/emmc-install
    chmod 755 files/sbin/emmc-install
fi
