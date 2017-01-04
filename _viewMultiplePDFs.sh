#!/bin/bash

## This script is to view pdf files interactively. Upon entering N, the script stops
## Else, it keeps viewing the files in pdfFiles
## Usage: _viewMultiplePDFs.sh Filenames (where Filenames contains the pdf files you want to view)
## pdfFiles should be a list of pdf file you want to view

pdfFiles=$1

Continue="YES"
for File in $(cat $pdfFiles) 
do 
    evince $File 2>/dev/null &
    echo "Continue? Y/N"
    read Continue
    if [ "$Continue" == "N" ]; then
	##rm -f pdfFiles
	exit 1
    fi
done



