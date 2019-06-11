#!/bin/bash

NUM=0
while [ $NUM -lt 15 ]; do
    iozone -i0 -i1 -i2 >> /dev/null
    let NUM=$NUM+1
done
