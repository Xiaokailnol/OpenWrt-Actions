#!/bin/bash -e

# coova-chilli - fix gcc 15 c23
[ "$USE_GCC15" = y ] && sed -i '/TARGET_CFLAGS/s/$/ -std=gnu17/' feeds/packages/net/coova-chilli/Makefile
