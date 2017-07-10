#!/usr/bin/env python
import sys

if len(sys.argv) != 4:
    print "not enough arguments"
    exit(1)

input_file = sys.argv[1]
bin_size = int(sys.argv[2])
bin_num = sys.argv[3]

binning_list = []
size_list = []
name_list = []

f = open("new_list/" + input_file + ".txt")
for item in f:
    tmp_line = item.strip().split()
    size_list.append(int(tmp_line[0]))
    name_list.append(tmp_line[1])

binning_size = []

for i, sizer in enumerate(size_list):
    put = False
    name = name_list[i]
    for j, filled in enumerate(binning_size):
        if sizer + filled < bin_size:
            binning_size[j] += sizer
            binning_list[j].append(name)
            put = True
            break
    if not put:
        binning_size.append(sizer)
        tmp_list = [name]
        binning_list.append(tmp_list)

if bin_num == "bins":
    print len(binning_list)
    exit(0)
else:
    bin_num = int(bin_num)
if len(binning_list) <= bin_num:
    print "bin_size smaller than bin_number"
    exit(2)

print binning_list[bin_num]
