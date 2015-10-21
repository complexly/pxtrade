__author__ = 'justindoghouse'

from os import walk
import os
import re

regexp = re.compile('(?:(?<=\A)|(?<=,))(\d+(?:\.\d+)?)(?=,|\Z)')
def remainNumbers(data_dir, filename):
    inputFile = open(data_dir+'/'+filename, 'r')
    if not os.path.exists(data_dir+'/output/'):
        os.makedirs(data_dir+'/output/')
    outputFile = open(data_dir+'/output/'+filename, 'w')
    for line in inputFile:

        matches = regexp.findall(line)
        outputFile.write(','.join(matches)+'\n')



if __name__ == "__main__":
    dir_with_char = './data'
    output_dir = './data_with_pure_number'
    for (dir_path, haha, filenames) in walk(dir_with_char):
        for fls in filenames:
            if not fls.startswith('.'):
                remainNumbers(dir_path, fls)