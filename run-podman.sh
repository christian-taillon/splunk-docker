#!/bin/sh
set -eu

podman compose up -d "$@"
