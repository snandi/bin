#!/bin/bash

## This script collects page 8 from all pdf files and creates a new pdf file

pdfFiles=$1
outputFile=$2

#for File in $(cat $pdfFiles) 
#for file in *.pdf ; 
#do 
#      pdftk "$File" cat 8 output Temp1.pdf ; 
#      pdftk Temp1.pdf Temp.pdf cat output output.pdf
#      rm -f Temp1.pdf Temp.pdf
#      mv output.pdf Temp.pdf
#done
#
#pdftk *page8.pdf cat output $outputFile
#cp output.pdf $outputFile

LineNum=1
while read line;
do
      if [ "$LineNum" -gt "1" ]; then
            pdftk "$line" cat 8 output Temp1.pdf ; 
            pdftk Temp1.pdf Temp.pdf cat output output.pdf
            rm -f Temp1.pdf Temp.pdf
            mv output.pdf Temp.pdf
      else
            pdftk "$line" cat 8 output Temp.pdf ; 
      fi
      LineNum=$(( $LineNum + 1 ))

done < $pdfFiles

mv Temp.pdf $outputFile

