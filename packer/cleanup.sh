#!/bin/bash

cd "$(dirname "$0")" || exit

rm -rf packer_cache
rm -rf output-qemu
rm -rf output-virtualbox-iso
rm -rf build/*
rm -rf .vagrant
