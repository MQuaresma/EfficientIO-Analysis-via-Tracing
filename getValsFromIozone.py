#!/usr/bin/env python3

import sys, statistics
import regex as re

text = open(sys.argv[1],'r').read()
lines = text.split('\n')

kb = []
reclen = []
write = []
rewrite = []
read = []
reread = []
random_read = []
random_write = []

linesN = 0
for line in lines:
    if re.match(r"^\s+([0-9]+\s+)+$", line) :
        linesN += 1
        numbers = re.split(r"\s+",line)
        numbers = numbers[1:-1]
        numbers = list(map(int, numbers))
        kb.append(numbers[0])
        reclen.append(numbers[1])
        write.append(numbers[2])
        rewrite.append(numbers[3])
        read.append(numbers[4])
        reread.append(numbers[5])
        random_read.append(numbers[6])
        random_write.append(numbers[7])

kb = statistics.median(kb)
reclen = statistics.median(reclen)
write = statistics.median(write)
rewrite = statistics.median(rewrite)
read = statistics.median(read)
reread = statistics.median(reread)
random_read = statistics.median(random_read)
random_write = statistics.median(random_write)

print(kb)
print(reclen)
print(write)
print(rewrite)
print(read)
print(reread)
print(random_read)
print(random_write)
