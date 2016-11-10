#!/bin/bash
echo "Building MSP432 program. "
make  "$1" "$2" 2>&1  | tee build.log
echo "Build output saved to buil.log "