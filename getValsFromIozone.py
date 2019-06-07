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

for line in lines:
    if re.match(r"^\s+([0-9]+\s+)+$", line) :
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

print(statistics.median(kb))
print(statistics.median(reclen))
print(statistics.median(write))
print(statistics.median(rewrite))
print(statistics.median(read))
print(statistics.median(reread))
print(statistics.median(random_read))
print(statistics.median(random_write))
