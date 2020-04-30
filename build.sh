#!/bin/bash

packer build --on-error=abort vagrant.json
