#!/bin/bash

packer build --on-error=abort -parallel=false vagrant.json
