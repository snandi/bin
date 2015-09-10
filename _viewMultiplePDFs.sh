#!/bin/bash

## This script is to view pdf files interactively. Upon entering N, the script stops
## Else, it keeps viewing the files in pdfFiles

ls */*Gaussian*.pdf > pdfFiles
Continue="YES"
for File in $(cat pdfFiles) 
do 
    evince $File &
    echo "Continue? Y/N"
    read Continue
    if [ "$Continue" == "N" ]; then
	rm -f pdfFiles
	exit 1
    fi
done

rm -f pdfFiles


