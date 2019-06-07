#!/bin/bash


NUM=0
while [ $NUM -lt 15 ]; do
    iozone -i0 -i1 -i2 >> iozone_res.txt
    let NUM=$NUM+1
done
