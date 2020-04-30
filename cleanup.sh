#!/bin/bash

cd "$(dirname "$0")" || exit

rm -rf packer_cache
rm -rf output-virtualbox-iso
rm -rf k3os_virtualbox.box
rm -rf .vagrant
